#!/usr/bin/env python3
"""Patch two exact Rex GPU previews in an explicitly supplied local copy.

Defaults to a dry run. Never discovers or opens the installed application.
Only Python's standard library is required.
"""
import argparse
import json
import os
from pathlib import Path
import stat
import struct
import tempfile

SOURCE = ("~/rex \ue0a0 main $ swift build && swift test\r\n"
          "main.swift:4: warning: 'run() -> Bool' is deprecated\r\n"
          "\x1b[1mBuild complete!\x1b[0m \x1b[3m(1.24 sec)\x1b[0m").encode('utf-8')
_translated = (SOURCE.decode('utf-8').replace('warning', '警告')
               .replace('is deprecated', '已弃用').replace('Build complete!', '构建完成！')
               .replace('sec', '秒')).encode('utf-8')
if len(_translated) > len(SOURCE):
    raise RuntimeError('Translated preview exceeds the original byte length')
TARGET = _translated + b' ' * (len(SOURCE) - len(_translated))
SELECTION_SOURCE = b'On branch feature/tabs'
_selection_translated = '分支\t  feature/tabs'.encode('utf-8')
if len(_selection_translated) > len(SELECTION_SOURCE):
    raise RuntimeError('Translated selection preview exceeds the original byte length')
SELECTION_TARGET = _selection_translated + b' ' * (len(SELECTION_SOURCE) - len(_selection_translated))
PREVIEWS = [('font', SOURCE, TARGET), ('selection', SELECTION_SOURCE, SELECTION_TARGET)]


class PatchError(ValueError):
    pass


def validate_write_path(path):
    # The upstream app lives here. Patching belongs to an explicit user-owned
    # copy (for example ~/Applications/Rex Beta 中文版.app or a temporary file).
    if path.resolve().is_relative_to(Path('/Applications')):
        raise PatchError('Writing inside /Applications is forbidden; supply a local copy')


def unpack(data, offset, fmt, limit):
    size = struct.calcsize(fmt)
    if offset < 0 or offset + size > limit or limit > len(data):
        raise PatchError('Truncated Mach-O structure')
    return struct.unpack_from(fmt, data, offset)


def slices(data):
    magic = data[:4]
    fat = {b'\xca\xfe\xba\xbe': ('>', False), b'\xbe\xba\xfe\xca': ('<', False),
           b'\xca\xfe\xba\xbf': ('>', True), b'\xbf\xba\xfe\xca': ('<', True)}
    if magic not in fat:
        return [(0, len(data), None, None)]
    endian, wide = fat[magic]
    count, = unpack(data, 4, endian + 'I', len(data))
    entry_size = 32 if wide else 20
    header_end = 8 + count * entry_size
    if count == 0 or header_end > len(data):
        raise PatchError('Invalid fat architecture table')
    result = []
    for i in range(count):
        entry = unpack(data, 8 + i * entry_size,
                       endian + ('IIQQII' if wide else 'IIIII'), len(data))
        cpu, subtype, offset, size, alignment = entry[:5]
        if wide and entry[5] != 0:
            raise PatchError('Nonzero fat reserved field')
        if alignment > 63 or offset % (1 << alignment) or offset < header_end or size < 32 or offset + size > len(data):
            raise PatchError('Invalid fat slice bounds or alignment')
        if any(offset < prior + length and prior < offset + size for prior, length, _, _ in result):
            raise PatchError('Overlapping fat slices')
        result.append((offset, size, cpu, subtype))
    return result


def cstring_section(data, base, size, fat_cpu, fat_subtype):
    limit = base + size
    endian = {b'\xcf\xfa\xed\xfe': '<', b'\xfe\xed\xfa\xcf': '>'}.get(data[base:base + 4])
    if endian is None:
        raise PatchError('Only 64-bit Mach-O slices are supported')
    _, cpu, subtype, filetype, count, command_bytes, _, _ = unpack(data, base, endian + '8I', limit)
    if filetype != 2:
        raise PatchError('Expected an executable Mach-O copy')
    if fat_cpu is not None and (cpu != fat_cpu or subtype != fat_subtype):
        raise PatchError('Fat table architecture differs from slice header')
    command_end = base + 32 + command_bytes
    if command_end > limit or count > command_bytes // 8:
        raise PatchError('Invalid load command table')
    cursor = base + 32
    sections = []
    for _ in range(count):
        command, length = unpack(data, cursor, endian + 'II', command_end)
        if length < 8 or length % 8 or cursor + length > command_end:
            raise PatchError('Invalid load command size')
        if command == 0x19:  # LC_SEGMENT_64
            segment = unpack(data, cursor, endian + 'II16sQQQQiiII', cursor + length)
            _, _, name, _, _, file_offset, file_size, _, _, section_count, _ = segment
            if length != 72 + section_count * 80 or file_offset + file_size > size:
                raise PatchError('Invalid segment bounds or section table')
            for index in range(section_count):
                section = unpack(data, cursor + 72 + index * 80, endian + '16s16sQQ8I', cursor + length)
                section_name, segment_name, _, section_size, section_offset = section[:5]
                if section_name.rstrip(b'\0') == b'__cstring' and segment_name.rstrip(b'\0') == b'__TEXT':
                    if name.rstrip(b'\0') != b'__TEXT' or section[8] & 0xff != 2:
                        raise PatchError('Expected __TEXT,__cstring string literal section')
                    if section_offset < file_offset or section_offset + section_size > file_offset + file_size:
                        raise PatchError('String section lies outside its segment')
                    if section_offset < 32 + command_bytes:
                        raise PatchError('String section overlaps Mach-O commands')
                    sections.append((base + section_offset, section_size))
        cursor += length
    if cursor != command_end or len(sections) != 1:
        raise PatchError('Expected exactly one __TEXT,__cstring section per architecture')
    return cpu, sections[0]


def plan_patch(data):
    changes = []
    states = []
    architectures = []
    for base, size, cpu, subtype in slices(data):
        cpu, (offset, length) = cstring_section(data, base, size, cpu, subtype)
        section = data[offset:offset + length]
        architectures.append(hex(cpu))
        for name, source, target in PREVIEWS:
            original, patched = source + b'\0', target + b'\0'
            original_count, patched_count = section.count(original), section.count(patched)
            if (original_count, patched_count) not in [(1, 0), (0, 1)]:
                raise PatchError(f'Expected exactly one complete original or patched {name} preview in each string section')
            state = 'original' if original_count else 'patched'
            position = section.index(original if original_count else patched)
            if position and section[position - 1] != 0:
                raise PatchError(f'{name} preview is not a complete standalone C string')
            states.append(state)
            if state == 'original':
                changes.append((offset + position, original, patched))
    if len(set(states)) != 1:
        raise PatchError('Mixed original and patched previews or architectures; refusing partial mutation')
    output = bytearray(data)
    for offset, original, replacement in changes:
        output[offset:offset + len(original)] = replacement
    output = bytes(output)
    if len(output) != len(data):
        raise PatchError('Mach-O size changed')
    allowed = set()
    for offset, original, _ in changes:
        allowed.update(range(offset, offset + len(original) - 1))
    if any(a != b and index not in allowed for index, (a, b) in enumerate(zip(data, output))):
        raise PatchError('Unexpected mutation outside preview bytes')
    return output, {'state': states[0], 'architectures': architectures,
                    'replacements': len(changes), 'size': len(data),
                    'preview_bytes': len(SOURCE), 'padding_bytes': len(SOURCE) - len(_translated),
                    'selection_preview_bytes': len(SELECTION_SOURCE),
                    'selection_padding_bytes': len(SELECTION_SOURCE) - len(_selection_translated)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('binary', type=Path, help='explicit path to a local copy of the Rex executable')
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--write', action='store_true', help='atomically write the checked patch to this copy')
    mode.add_argument('--dry-run', action='store_true', help='validate only (default)')
    args = parser.parse_args()
    try:
        path = args.binary.absolute()
        if args.write:
            validate_write_path(path)
        info = path.lstat()
        if not stat.S_ISREG(info.st_mode) or path.is_symlink():
            raise PatchError('Expected a regular executable copy, not a symlink')
        data = path.read_bytes()
        output, report = plan_patch(data)
        if args.write and output != data:
            temporary = None
            try:
                with tempfile.NamedTemporaryFile(prefix='.rex-preview-', dir=path.parent, delete=False) as stream:
                    temporary = Path(stream.name)
                    stream.write(output)
                    stream.flush()
                    os.fsync(stream.fileno())
                    os.fchmod(stream.fileno(), stat.S_IMODE(info.st_mode))
                # Do not overwrite a copy changed after validation.
                current = path.lstat()
                stable_fields = ('st_dev', 'st_ino', 'st_mode', 'st_size', 'st_mtime_ns', 'st_ctime_ns')
                if any(getattr(current, field) != getattr(info, field) for field in stable_fields) or path.read_bytes() != data:
                    raise PatchError('Executable changed during validation')
                os.replace(temporary, path)
            finally:
                if temporary is not None and temporary.exists():
                    temporary.unlink()
        report['written'] = args.write and output != data
        print(json.dumps(report, ensure_ascii=False))
        return 0
    except (OSError, PatchError) as error:
        parser.exit(1, f'Preview patch refused: {error}\n')


if __name__ == '__main__':
    raise SystemExit(main())
