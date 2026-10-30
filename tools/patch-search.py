#!/usr/bin/env python3
"""Redirect only Rex 1408's native search candidate-title call to lowercased.

An explicit binary path is required. Validation is the default; --write patches
an owned copy atomically. The installed /Applications tree is never writable.
This callsite requires the separate ownership/Double-preserving runtime bridge.
"""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import stat
import struct
import sys
import tempfile
import uuid

sys.dont_write_bytecode = True
_spec = importlib.util.spec_from_file_location('rex_preview_patch', Path(__file__).with_name('patch-preview.py'))
_preview = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_preview)
PatchError = _preview.PatchError
unpack = _preview.unpack
slices = _preview.slices
validate_write_path = _preview.validate_write_path

# Frozen evidence: .artifacts/search-binary-title-redirect-evidence.json.
SPECS = {
    0x100000c: dict(architecture='arm64', subtype=0,
        uuid='D229E6F2-6FA4-3BEF-925D-8D3F8A28501B', call=0x1000b2758,
        source='fd42fd97', target='4d6f4894', original_target=0x10000334c,
        before='081480b98802088b165d40a9e00317aaa47c489400106e1ee00316aae10317aa',
        after='600602a9601a00fda81a80b98802088b160540f9760200b4170140f9f10a0094',
        stub=0x1012ce48c, stub_bytes='b0230090100644f900021fd6'),
    0x1000007: dict(architecture='x86_64', subtype=3,
        uuid='413C177A-F1BF-3980-BA9E-F31886649F5C', call=0x1000c0061,
        source='e85e440900', target='e8a4c25e01', original_target=0x1001544c4,
        before='4d8b7c05004d8b6405084c89e7e863dd5e01f20f1005ad2063014c89ff4c89e6',
        after='4989d84889432048895328f20f114330496346184d8b7c05084d85ff0f84a500',
        stub=0x1016ac30a, stub_bytes='ff25b8e94100'),
}


def sections_for_slice(data, base, size, fat_cpu, fat_subtype):
    limit = base + size
    if data[base:base + 4] != b'\xcf\xfa\xed\xfe':
        raise PatchError('Expected little-endian 64-bit Mach-O')
    _, cpu, subtype, kind, count, command_bytes, _, _ = unpack(data, base, '<8I', limit)
    if cpu not in SPECS or subtype != SPECS[cpu]['subtype']:
        raise PatchError('Unknown architecture or subtype')
    if fat_cpu is not None and (cpu, subtype) != (fat_cpu, fat_subtype):
        raise PatchError('Fat table architecture differs from slice header')
    command_end = base + 32 + command_bytes
    if kind != 2 or command_end > limit or count > command_bytes // 8:
        raise PatchError('Invalid executable or load command table')
    cursor = base + 32
    uuids, sections, segments, virtual_segments = [], {}, [], []
    for _ in range(count):
        command, length = unpack(data, cursor, '<II', command_end)
        if length < 8 or length % 8 or cursor + length > command_end:
            raise PatchError('Invalid load command size or alignment')
        if command == 0x1b:  # LC_UUID
            if length != 24:
                raise PatchError('Invalid LC_UUID length')
            uuids.append(str(uuid.UUID(bytes=bytes(data[cursor + 8:cursor + 24]))).upper())
        elif command == 0x19:  # LC_SEGMENT_64
            seg = unpack(data, cursor, '<II16sQQQQiiII', cursor + length)
            _, _, name, va, vsize, offset, fsize, _, protection, nsects, _ = seg
            if length != 72 + 80 * nsects or offset + fsize > size or fsize > vsize:
                raise PatchError('Invalid segment bounds or section table')
            if vsize:
                if any(va < prior + length and prior < va + vsize for prior, length in virtual_segments):
                    raise PatchError('Overlapping virtual segment ranges')
                virtual_segments.append((va, vsize))
            if fsize:
                if any(offset < p + n and p < offset + fsize for p, n in segments):
                    raise PatchError('Overlapping file-backed segments')
                segments.append((offset, fsize))
            for index in range(nsects):
                sec = unpack(data, cursor + 72 + 80 * index, '<16s16sQQ8I', cursor + length)
                sn, sg, sva, ssize, soff, align = sec[:6]
                sn, sg = sn.rstrip(b'\0'), sg.rstrip(b'\0')
                if sn not in (b'__text', b'__stubs') or sg != b'__TEXT':
                    continue
                if sn in sections:
                    raise PatchError('Duplicate search code section')
                if (name.rstrip(b'\0') != b'__TEXT' or not protection & 4
                        or align > 63 or soff % (1 << align) or sva % (1 << align)
                        or soff < 32 + command_bytes or soff < offset
                        or soff + ssize > offset + fsize or sva < va
                        or sva + ssize > va + vsize or sva - va != soff - offset):
                    raise PatchError('Invalid code section bounds, mapping or alignment')
                if sn == b'__stubs' and (sec[8] & 0xff != 8 or sec[10] != len(bytes.fromhex(SPECS[cpu]['stub_bytes']))):
                    raise PatchError('Invalid symbol stub section')
                if sn == b'__text' and (sec[8] & 0xff != 0 or not sec[8] & 0x80000000):
                    raise PatchError('Invalid instruction section')
                if any(soff < p + n and p < soff + ssize for _, p, n in sections.values()):
                    raise PatchError('Overlapping code sections')
                sections[sn] = (sva, soff, ssize)
        cursor += length
    if cursor != command_end or uuids != [SPECS[cpu]['uuid']]:
        raise PatchError('Expected exactly one matching Rex 1408 LC_UUID')
    if set(sections) != {b'__text', b'__stubs'}:
        raise PatchError('Expected unique __TEXT code and symbol stub sections')
    return cpu, sections


def mapped_offset(section, address, length):
    va, offset, size = section
    if address < va or address + length > va + size:
        raise PatchError('Call or stub address lies outside expected section')
    return offset + address - va


def decode_call(cpu, address, instruction):
    if cpu == 0x100000c:
        word, = struct.unpack('<I', instruction)
        if address % 4 or word & 0xfc000000 != 0x94000000:
            raise PatchError('Invalid or unaligned arm64 BL')
        displacement = word & 0x3ffffff
        if displacement & 0x2000000:
            displacement -= 0x4000000
        return address + displacement * 4
    if len(instruction) != 5 or instruction[0] != 0xe8:
        raise PatchError('Invalid x86_64 CALL')
    return address + 5 + struct.unpack('<i', instruction[1:])[0]


def plan_patch(data):
    changes, architectures, seen = [], [], set()
    for base, size, fat_cpu, subtype in slices(data):
        cpu, sections = sections_for_slice(data, base, size, fat_cpu, subtype)
        if cpu in seen:
            raise PatchError('Duplicate architecture')
        seen.add(cpu)
        spec = SPECS[cpu]
        source, target, before, after, stub = [bytes.fromhex(spec[key]) for key in ('source', 'target', 'before', 'after', 'stub_bytes')]
        offset = base + mapped_offset(sections[b'__text'], spec['call'] - 32, 64 + len(source)) + 32
        if data[offset - 32:offset] != before or data[offset + len(source):offset + len(source) + 32] != after:
            raise PatchError('Search call context differs from Rex 1408 evidence')
        instruction = data[offset:offset + len(source)]
        if instruction not in (source, target):
            raise PatchError('Unknown search call instruction or target')
        state = 'original' if instruction == source else 'patched'
        expected_target = spec['original_target'] if state == 'original' else spec['stub']
        if decode_call(cpu, spec['call'], instruction) != expected_target or decode_call(cpu, spec['call'], target) != spec['stub']:
            raise PatchError('Search call target mismatch')
        stub_relative = mapped_offset(sections[b'__stubs'], spec['stub'], len(stub))
        if (spec['stub'] - sections[b'__stubs'][0]) % len(stub):
            raise PatchError('Misaligned lowercased symbol stub')
        stub_offset = base + stub_relative
        if data[stub_offset:stub_offset + len(stub)] != stub:
            raise PatchError('Lowercased symbol stub bytes differ from evidence')
        if state == 'original':
            changes.append((offset, target))
        architectures.append(dict(architecture=spec['architecture'], state=state, uuid=spec['uuid'],
            call=dict(vmaddr=hex(spec['call']), file_offset=hex(offset), bytes=instruction.hex(), target=hex(expected_target)),
            stub=dict(vmaddr=hex(spec['stub']), file_offset=hex(stub_offset), bytes=stub.hex())))
    if len({item['state'] for item in architectures}) != 1:
        raise PatchError('Mixed original and patched architectures')
    output = bytearray(data)
    for offset, target in changes:
        output[offset:offset + len(target)] = target
    return bytes(output), dict(state=architectures[0]['state'], architectures=architectures,
                               replacements=len(changes), size=len(data), written=False)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('binary', type=Path)
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument('--write', action='store_true')
    modes.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()
    try:
        path = args.binary.absolute()
        if args.write:
            validate_write_path(path)
        info = path.lstat()
        if path.is_symlink() or not stat.S_ISREG(info.st_mode):
            raise PatchError('Expected a regular binary copy, not a symlink or directory')
        data = path.read_bytes()
        output, report = plan_patch(data)
        if args.write and output != data:
            temporary = None
            try:
                with tempfile.NamedTemporaryFile(prefix='.rex-search-', dir=path.parent, delete=False) as stream:
                    temporary = Path(stream.name)
                    stream.write(output)
                    stream.flush()
                    os.fsync(stream.fileno())
                    os.fchmod(stream.fileno(), stat.S_IMODE(info.st_mode))
                current = path.lstat()
                fields = ('st_dev', 'st_ino', 'st_mode', 'st_size', 'st_mtime_ns', 'st_ctime_ns')
                if any(getattr(info, key) != getattr(current, key) for key in fields) or path.read_bytes() != data:
                    raise PatchError('Binary changed during validation')
                validate_write_path(path)
                os.replace(temporary, path)
                report['written'] = True
            finally:
                if temporary is not None and temporary.exists():
                    temporary.unlink()
        print(json.dumps(report))
        return 0
    except (OSError, PatchError) as error:
        print(json.dumps(dict(error=str(error), written=False)), file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
