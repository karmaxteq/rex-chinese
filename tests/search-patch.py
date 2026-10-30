#!/usr/bin/env python3
"""Strict search callsite patch regressions; installed Rex is read-only."""
import hashlib
import importlib.util
import json
from pathlib import Path
import stat
import struct
import subprocess
import sys
import tempfile
import unittest
import uuid

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'tools' / 'patch-search.py'
ORIGINAL = Path('/Applications/Rex Beta.app/Contents/MacOS/Rex')
spec = importlib.util.spec_from_file_location('search_patch', SCRIPT)
patch = importlib.util.module_from_spec(spec)
spec.loader.exec_module(patch)


def thin(cpu=0x100000c, patched=False):
    evidence = patch.SPECS[cpu]
    instruction = bytes.fromhex(evidence['target' if patched else 'source'])
    payload = bytes.fromhex(evidence['before']) + instruction + bytes.fromhex(evidence['after'])
    stub = bytes.fromhex(evidence['stub_bytes'])
    commands = bytearray()
    for name, address, offset, content, flags, reserved2 in [
        (b'__text', evidence['call'] - 32, 512, payload, 0x80000400, 0),
        (b'__stubs', evidence['stub'], 1024, stub, 0x80000408, len(stub)),
    ]:
        commands.extend(struct.pack('<II16sQQQQiiII', 0x19, 152, b'__TEXT', address, len(content), offset, len(content), 5, 5, 1, 0))
        commands.extend(struct.pack('<16s16sQQ8I', name, b'__TEXT', address, len(content), offset, 2 if cpu == 0x100000c else 0, 0, 0, flags, 0, reserved2, 0))
    commands.extend(struct.pack('<II', 0x1b, 24) + uuid.UUID(evidence['uuid']).bytes)
    header = struct.pack('<8I', 0xfeedfacf, cpu, evidence['subtype'], 2, 3, len(commands), 0, 0)
    data = bytearray(1024 + len(stub))
    data[:len(header + commands)] = header + commands
    data[512:512 + len(payload)] = payload
    data[1024:] = stub
    return bytes(data)


def fat(parts, endian='>', wide=False):
    data = bytearray(4096 * (len(parts) + 1))
    struct.pack_into(endian + 'II', data, 0, 0xcafebabf if wide else 0xcafebabe, len(parts))
    for i, part in enumerate(parts):
        cpu, subtype = struct.unpack_from('<II', part, 4)
        values = (cpu, subtype, 4096 * (i + 1), len(part), 12)
        struct.pack_into(endian + ('IIQQII' if wide else 'IIIII'), data, 8 + i * (32 if wide else 20), *(values + (0,) if wide else values))
        data[4096 * (i + 1):4096 * (i + 1) + len(part)] = part
    return bytes(data)


def cli(path, *args):
    return subprocess.run([sys.executable, str(SCRIPT), str(path), *args], text=True, capture_output=True)


class SearchPatchTests(unittest.TestCase):
    def refused(self, data, pattern=None):
        with self.assertRaisesRegex(patch.PatchError, pattern or '.'):
            patch.plan_patch(bytes(data))

    def test_supported_thin_and_fat_formats(self):
        for cpu in patch.SPECS:
            original = thin(cpu)
            output, report = patch.plan_patch(original)
            self.assertEqual(report['replacements'], 1)
            self.assertEqual(output, thin(cpu, True))
            self.assertEqual(patch.plan_patch(output)[0], output)
        for endian in ('>', '<'):
            for wide in (False, True):
                data = fat([thin(), thin(0x1000007)], endian, wide)
                output, report = patch.plan_patch(data)
                self.assertEqual(report['replacements'], 2)
                self.assertEqual(output, fat([thin(patched=True), thin(0x1000007, True)], endian, wide))

    def test_uuid_context_call_and_stub_rejections(self):
        for cpu in patch.SPECS:
            data = thin(cpu)
            for offset, message in [(344, 'LC_UUID'), (512, 'context'), (511 + 32, 'context'),
                                    (544, 'instruction'), (544 + len(bytes.fromhex(patch.SPECS[cpu]['source'])), 'context'),
                                    (1024, 'stub bytes')]:
                with self.subTest(cpu=cpu, offset=offset):
                    bad = bytearray(data)
                    bad[offset] ^= 1
                    self.refused(bad, message)
            bad = bytearray(thin(cpu, True))
            bad[545] ^= 1
            self.refused(bad, 'instruction')

    def test_mixed_duplicate_unknown_architectures(self):
        self.refused(fat([thin(), thin(0x1000007, True)]), 'Mixed')
        self.refused(fat([thin(), thin()]), 'Duplicate architecture')
        bad = bytearray(thin())
        struct.pack_into('<I', bad, 4, 0x1234)
        self.refused(bad, 'Unknown architecture')
        bad = bytearray(fat([thin(), thin(0x1000007)]))
        struct.pack_into('>I', bad, 8, 0x1000007)
        self.refused(bad, 'Fat table architecture')

    def test_truncation_alignment_and_bounds(self):
        for data in (b'', b'not Mach-O', thin()[:20], thin()[:100], thin()[:-1], fat([thin(), thin(0x1000007)])[:5000]):
            self.refused(data)
        for offset, value in [(36, 151), (156, 5), (152, 513), (72, 0xffffffff), (20, 0xffffffff)]:
            bad = bytearray(thin())
            struct.pack_into('<I', bad, offset, value)
            self.refused(bad)
        bad = bytearray(fat([thin(), thin(0x1000007)]))
        struct.pack_into('>I', bad, 16, 4097)
        self.refused(bad, 'alignment')
        bad = bytearray(fat([thin(), thin(0x1000007)]))
        struct.pack_into('>I', bad, 36, 4096)
        self.refused(bad, 'Overlapping')
        self.refused(fat([thin(), thin(0x1000007)], wide=True)[:60])

    def test_reject_overlapping_virtual_segments(self):
        for cpu in patch.SPECS:
            call = patch.SPECS[cpu]['call']
            for address, length in [(call, 4), (call - 40, 16), (call + 33, 16)]:
                for backed in (False, True):
                    with self.subTest(cpu=cpu, address=hex(address), backed=backed):
                        data = bytearray(thin(cpu))
                        # A distinct file range must not hide a duplicate VM mapping.
                        extra = struct.pack('<II16sQQQQiiII', 0x19, 72, b'__OTHER',
                                            address, length, 1100 if backed else 0,
                                            length if backed else 0, 5, 5, 0, 0)
                        data[360:432] = extra
                        struct.pack_into('<II', data, 16, 4, 400)
                        if backed:
                            data.extend(b'\0' * (1100 + length - len(data)))
                        self.refused(data, 'Overlapping virtual segment ranges')

    def test_duplicate_uuid_and_sections(self):
        data = bytearray(thin())
        # Replace LC_UUID with a duplicate __text section by renaming __stubs.
        data[256:272] = b'__text'.ljust(16, b'\0')
        self.refused(data, 'Duplicate search code section')
        data = bytearray(thin())
        duplicate = bytes(data[336:360])
        data[360:384] = duplicate
        struct.pack_into('<II', data, 16, 4, 352)
        self.refused(data, 'LC_UUID')

    def test_call_decoder_rejects_bad_opcode_and_alignment(self):
        with self.assertRaises(patch.PatchError):
            patch.decode_call(0x100000c, 0x1000b2759, bytes.fromhex('4d6f4894'))
        with self.assertRaises(patch.PatchError):
            patch.decode_call(0x100000c, 0x1000b2758, b'\0' * 4)
        with self.assertRaises(patch.PatchError):
            patch.decode_call(0x1000007, 0x1000c0061, b'\0' * 5)

    def test_write_guard_directories_and_symlinks(self):
        with self.assertRaises(patch.PatchError):
            patch.validate_write_path(ORIGINAL)
        result = cli(ORIGINAL, '--write')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('/Applications', json.loads(result.stderr)['error'])
        with tempfile.TemporaryDirectory() as folder:
            folder = Path(folder)
            self.assertNotEqual(cli(folder, '--write').returncode, 0)
            target = folder / 'binary'
            target.write_bytes(thin())
            alias = folder / 'alias'
            alias.symlink_to(target)
            self.assertNotEqual(cli(alias, '--write').returncode, 0)
            installed = folder / 'installed'
            installed.symlink_to(ORIGINAL)
            self.assertNotEqual(cli(installed, '--write').returncode, 0)
            self.assertEqual(target.read_bytes(), thin())
            self.assertEqual(list(folder.glob('.rex-search-*')), [])

    def test_cli_default_dry_run_and_mode_validation(self):
        with tempfile.TemporaryDirectory() as folder:
            binary = Path(folder) / 'Rex'
            data = thin()
            binary.write_bytes(data)
            for args in ((), ('--dry-run',)):
                result = cli(binary, *args)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertFalse(json.loads(result.stdout)['written'])
                self.assertEqual(binary.read_bytes(), data)
            self.assertNotEqual(cli(binary, '--write', '--dry-run').returncode, 0)
            binary.write_bytes(b'broken')
            self.assertNotEqual(cli(binary, '--write').returncode, 0)
            self.assertEqual(binary.read_bytes(), b'broken')

    @unittest.skipUnless(ORIGINAL.is_file(), 'Rex 1408 upstream binary unavailable')
    def test_real_original_dry_run_and_one_copy_write(self):
        original = ORIGINAL.read_bytes()
        original_hash = hashlib.sha256(original).hexdigest()
        self.assertEqual(original_hash, '0fd11b7d5ca93b26a9df25d8b66995ceb17466372505d24ebf86fc0b01aa50a7')
        result = cli(ORIGINAL, '--dry-run')
        self.assertEqual(result.returncode, 0, result.stderr)
        report = json.loads(result.stdout)
        self.assertEqual(report['state'], 'original')
        self.assertEqual(report['replacements'], 2)
        self.assertFalse(report['written'])
        with tempfile.TemporaryDirectory() as folder:
            binary = Path(folder) / 'Rex'
            binary.write_bytes(original)
            binary.chmod(0o751)
            inode = binary.stat().st_ino
            result = cli(binary, '--write')
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertTrue(json.loads(result.stdout)['written'])
            self.assertNotEqual(binary.stat().st_ino, inode)
            self.assertEqual(stat.S_IMODE(binary.stat().st_mode), 0o751)
            expected = bytearray(original)
            for arch in report['architectures']:
                evidence = next(s for s in patch.SPECS.values() if s['architecture'] == arch['architecture'])
                offset = int(arch['call']['file_offset'], 16)
                target = bytes.fromhex(evidence['target'])
                expected[offset:offset + len(target)] = target
            written = binary.read_bytes()
            self.assertEqual(written, expected, 'Only the two independently located calls may change')
            inode = binary.stat().st_ino
            result = cli(binary, '--write')
            self.assertEqual(result.returncode, 0, result.stderr)
            again = json.loads(result.stdout)
            self.assertEqual((again['state'], again['replacements'], again['written']), ('patched', 0, False))
            self.assertEqual(binary.stat().st_ino, inode)
            self.assertEqual(binary.read_bytes(), written)
            self.assertEqual(list(Path(folder).glob('.rex-search-*')), [])
        self.assertEqual(hashlib.sha256(ORIGINAL.read_bytes()).hexdigest(), original_hash)


if __name__ == '__main__':
    unittest.main(verbosity=2)
