#!/usr/bin/env python3
"""Synthetic Mach-O and CLI regressions; no upstream binaries are distributed."""
import importlib.util
import json
from pathlib import Path
import struct
import subprocess
import sys
import tempfile
import unittest
import unicodedata

sys.dont_write_bytecode = True
SCRIPT = Path(__file__).resolve().parents[1] / 'tools' / 'patch-preview.py'
spec = importlib.util.spec_from_file_location('preview_patch', SCRIPT)
patch = importlib.util.module_from_spec(spec)
spec.loader.exec_module(patch)


def thin(payload=None, endian='<', cpu=0x100000c, section_name=b'__cstring', segment_name=b'__TEXT', flags=2):
    if payload is None:
        payload = b'other\0' + patch.SOURCE + b'\0' + patch.SELECTION_SOURCE + b'\0untouched\0'
    offset = 256
    header = struct.pack(endian + '8I', 0xfeedfacf, cpu, 0, 2, 1, 152, 0, 0)
    segment = struct.pack(endian + 'II16sQQQQiiII', 0x19, 152, segment_name, 0, 4096, 0, offset + len(payload), 7, 5, 1, 0)
    section = struct.pack(endian + '16s16sQQ8I', section_name, segment_name, 0, len(payload), offset, 0, 0, 0, flags, 0, 0, 0)
    return (header + segment + section).ljust(offset, b'\0') + payload


def fat(parts, endian='>', wide=False):
    cpu_types = [0x100000c, 0x1000007]
    header = struct.pack(endian + 'II', 0xcafebabf if wide else 0xcafebabe, len(parts))
    entries = b''
    result = bytearray(4096 * (len(parts) + 1))
    for i, part in enumerate(parts):
        offset = 4096 * (i + 1)
        entry = (cpu_types[i], 0, offset, len(part), 12)
        entries += struct.pack(endian + ('IIQQII' if wide else 'IIIII'), *(entry + (0,) if wide else entry))
        result[offset:offset + len(part)] = part
    result[:len(header + entries)] = header + entries
    return bytes(result)


class PreviewPatchTests(unittest.TestCase):
    def test_upstream_write_guard(self):
        with self.assertRaises(patch.PatchError):
            patch.validate_write_path(Path('/Applications/Rex Beta.app/Contents/MacOS/Rex'))
        patch.validate_write_path(Path.home() / 'Applications/Rex Beta 中文版.app/Contents/MacOS/RexCore')

    def assert_patch(self, data, architectures):
        result, report = patch.plan_patch(data)
        self.assertEqual(report['replacements'], architectures * 2)
        self.assertEqual(len(result), len(data))
        self.assertEqual(result.count(patch.TARGET + b'\0'), architectures)
        self.assertEqual(result.count(patch.SOURCE + b'\0'), 0)
        self.assertEqual(result.count(patch.SELECTION_TARGET + b'\0'), architectures)
        self.assertEqual(result.count(patch.SELECTION_SOURCE + b'\0'), 0)
        again, second = patch.plan_patch(result)
        self.assertEqual(again, result)
        self.assertEqual(second['state'], 'patched')
        self.assertEqual(second['replacements'], 0)
        # Prove exact changed ranges independently of the production verifier.
        expected = data.replace(patch.SOURCE + b'\0', patch.TARGET + b'\0')
        expected = expected.replace(patch.SELECTION_SOURCE + b'\0', patch.SELECTION_TARGET + b'\0')
        self.assertEqual(result, expected)

    def test_thin_endianness(self):
        for endian in ['<', '>']:
            with self.subTest(endian=endian):
                self.assert_patch(thin(endian=endian), 1)

    def test_fat_formats(self):
        for endian in ['<', '>']:
            for wide in [False, True]:
                with self.subTest(endian=endian, wide=wide):
                    self.assert_patch(fat([thin(), thin(cpu=0x1000007)], endian, wide), 2)

    def test_translation_preserves_command_path_and_ansi(self):
        decoded = patch.TARGET.decode('utf-8')
        self.assertTrue(decoded.startswith('~/rex \ue0a0 main $ swift build && swift test\r\nmain.swift:4: '))
        self.assertIn("警告: 'run() -> Bool' 已弃用", decoded)
        self.assertIn('\x1b[1m构建完成！\x1b[0m \x1b[3m(1.24 秒)\x1b[0m', decoded)
        self.assertEqual(len(patch.TARGET), len(patch.SOURCE))
        self.assertEqual(decoded.count('\x1b'), 4)
        self.assertEqual(len(patch.SELECTION_SOURCE), 22)
        self.assertEqual(len(patch.SELECTION_TARGET), 22)
        self.assertEqual(patch.SELECTION_TARGET.decode('utf-8'), '分支\t  feature/tabs ')
        self.assertEqual(len('分支\t  feature/tabs'.encode('utf-8')), 21)

    def test_selection_identifier_column_with_eight_column_tabs(self):
        # Independent terminal-column model: CJK is double-width; a TAB moves
        # to the next multiple of 8. This proves the intended text layout,
        # while the actual renderer/highlight still needs a screenshot check.
        def identifier_column(text):
            prefix = text[:text.index('feature/tabs')]
            column = 0
            for character in prefix:
                if character == '\t':
                    column = (column // 8 + 1) * 8
                else:
                    column += 2 if unicodedata.east_asian_width(character) in ('W', 'F') else 1
            return column
        self.assertEqual(identifier_column(patch.SELECTION_SOURCE.decode('utf-8')), 10)
        self.assertEqual(identifier_column(patch.SELECTION_TARGET.decode('utf-8')), 10)

    def test_reject_samples(self):
        samples = [b'missing\0', patch.SOURCE, patch.SOURCE + b'\0' + patch.SOURCE + b'\0',
                   b'prefix' + patch.SOURCE + b'\0', patch.SOURCE + b'\0' + patch.TARGET + b'\0',
                   patch.SOURCE.replace(b'warning', '警告'.encode()) + b'\0']
        for sample in samples:
            with self.subTest(sample=repr(sample[:20])):
                with self.assertRaises(patch.PatchError):
                    patch.plan_patch(thin(sample + patch.SELECTION_SOURCE + b'\0'))

    def test_reject_missing_either_preview(self):
        for sample in [patch.SOURCE, patch.SELECTION_SOURCE]:
            with self.subTest(sample=sample):
                with self.assertRaises(patch.PatchError):
                    patch.plan_patch(thin(sample + b'\0'))

    def test_reject_partial_translation_within_architecture(self):
        for font, selection in [(patch.SOURCE, patch.SELECTION_TARGET), (patch.TARGET, patch.SELECTION_SOURCE)]:
            with self.subTest(font=font):
                with self.assertRaises(patch.PatchError):
                    patch.plan_patch(thin(font + b'\0' + selection + b'\0'))

    def test_reject_bad_selection_preview(self):
        for selection in [patch.SELECTION_SOURCE, b'prefix' + patch.SELECTION_SOURCE + b'\0',
                          patch.SELECTION_SOURCE + b'\0' + patch.SELECTION_SOURCE + b'\0',
                          patch.SELECTION_SOURCE + b'\0' + patch.SELECTION_TARGET + b'\0']:
            with self.subTest(selection=selection):
                with self.assertRaises(patch.PatchError):
                    patch.plan_patch(thin(patch.SOURCE + b'\0' + selection))

    def test_reject_wrong_sections(self):
        for options in [dict(section_name=b'__const'), dict(segment_name=b'__DATA'), dict(flags=0)]:
            with self.subTest(options=options):
                with self.assertRaises(patch.PatchError):
                    patch.plan_patch(thin(**options))

    def test_reject_mixed_architectures(self):
        data = fat([thin(), thin(patch.TARGET + b'\0' + patch.SELECTION_TARGET + b'\0', cpu=0x1000007)])
        with self.assertRaises(patch.PatchError):
            patch.plan_patch(data)

    def test_reject_bad_macho(self):
        fixtures = [b'', b'not macho', thin()[:100], fat([thin(), thin(cpu=0x1000007)])[:5000]]
        for index, replacement in [(16, 0xffffffff), (20, 0xffffffff), (36, 7), (152, 0xffffffff)]:
            malformed = bytearray(thin())
            struct.pack_into('<I', malformed, index, replacement)
            fixtures.append(bytes(malformed))
        overlapping = bytearray(fat([thin(), thin(cpu=0x1000007)]))
        struct.pack_into('>I', overlapping, 36, 4096)
        fixtures.append(bytes(overlapping))
        for data in fixtures:
            with self.subTest(length=len(data)):
                with self.assertRaises(patch.PatchError):
                    patch.plan_patch(data)

    def test_cli_dry_run_write_repeat_and_refusal(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / '中文 Rex copy'
            original = thin()
            path.write_bytes(original)
            path.chmod(0o755)
            def invoke(*options):
                return subprocess.run([sys.executable, str(SCRIPT), str(path), *options], capture_output=True, text=True)
            result = invoke()
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertFalse(json.loads(result.stdout)['written'])
            self.assertEqual(path.read_bytes(), original)
            result = invoke('--write')
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertTrue(json.loads(result.stdout)['written'])
            self.assertEqual(path.stat().st_mode & 0o777, 0o755)
            expected = patch.plan_patch(original)[0]
            self.assertEqual(path.read_bytes(), expected)
            result = invoke('--write')
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertFalse(json.loads(result.stdout)['written'])
            self.assertEqual(path.read_bytes(), expected)
            invalid = thin(patch.SOURCE + b'\0' + patch.SOURCE + b'\0')
            path.write_bytes(invalid)
            result = invoke('--write')
            self.assertEqual(result.returncode, 1)
            self.assertEqual(path.read_bytes(), invalid)
            self.assertEqual(list(Path(directory).glob('.rex-preview-*')), [])

    def test_cli_rejects_symlink(self):
        with tempfile.TemporaryDirectory() as directory:
            original = Path(directory) / 'original'
            original.write_bytes(thin())
            link = Path(directory) / 'link'
            link.symlink_to(original)
            result = subprocess.run([sys.executable, str(SCRIPT), str(link), '--write'], capture_output=True)
            self.assertEqual(result.returncode, 1)
            self.assertEqual(original.read_bytes(), thin())


if __name__ == '__main__':
    unittest.main()
