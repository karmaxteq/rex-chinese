#!/usr/bin/env python3
"""Check the production accessibility-frame message ABI on both architectures.

Compile unchanged RexZh.m and a native SDK probe to LLVM. This checks code
generation, not execution on an Intel Mac or the correctness of AX coordinates.
Requires macOS and Xcode command-line tools; uses only the standard library.
"""
import argparse
from pathlib import Path
import re
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
PROBE = '''#import <AppKit/AppKit.h>
NSRect RXNativeAccessibilityFrame(id element) {
    return [element accessibilityFrame];
}
'''


def frame_message(ir, name):
    match = re.search(r'^define [^\n]*@' + re.escape(name) + r'\([^\n]*\{\n.*?^}',
                      ir, re.M | re.S)
    if not match:
        raise ValueError(f'LLVM function {name} was not found')
    # The old function already used stret later for NSValue.rectValue. Inspect
    # the first CGRect-returning message, rather than accepting any stret call.
    messages = [line.strip() for line in match.group(0).splitlines()
                if re.search(r'\bcall\b', line) and 'objc_msgSend' in line
                and '%struct.CGRect' in line]
    if not messages:
        raise ValueError(f'{name} has no CGRect Objective-C message')
    line = messages[0]
    return line, ('call %struct.CGRect ' in line,
                  'sret(%struct.CGRect)' in line, 'objc_msgSend_stret' in line)


def compile_ir(source, destination, arch):
    result = subprocess.run(['xcrun', 'clang', '-target', f'{arch}-apple-macos13.0',
                             '-O0', '-fobjc-arc', '-fblocks', '-S', '-emit-llvm',
                             str(source), '-o', str(destination)],
                            text=True, capture_output=True)
    if result.returncode:
        raise RuntimeError(f'{arch}: LLVM compilation failed:\n{result.stderr}')
    warnings = len(re.findall(r': warning:', result.stderr))
    print(f'{arch}: {source.name} compiled successfully ({warnings} warnings)')
    return destination.read_text()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=ROOT / 'RexZh.m',
                        help='production Objective-C source for regression comparison')
    args = parser.parse_args()
    if sys.platform != 'darwin':
        parser.exit(2, 'Frame ABI tests require macOS and Xcode command-line tools.\n')
    failures = []
    try:
        with tempfile.TemporaryDirectory(prefix='rex-frame-abi-') as directory:
            root = Path(directory)
            probe = root / 'native-frame.m'
            probe.write_text(PROBE)
            for arch in ('arm64', 'x86_64'):
                native = compile_ir(probe, root / f'native-{arch}.ll', arch)
                production = compile_ir(args.source.resolve(), root / f'production-{arch}.ll', arch)
                native_line, native_shape = frame_message(native, 'RXNativeAccessibilityFrame')
                actual_line, actual_shape = frame_message(production, 'RXAccessibilityFrame')
                expected = (True, False, False) if arch == 'arm64' else (False, True, True)
                if native_shape != expected or actual_shape != native_shape:
                    failures.append(f'{arch}: frame message ABI differs from SDK expectation\n'
                                    f'  native: {native_line}\n  production: {actual_line}')
                else:
                    print(f'{arch}: frame message ABI matches native SDK ({"objc_msgSend" if arch == "arm64" else "objc_msgSend_stret"})')
    except (OSError, RuntimeError, ValueError) as error:
        failures.append(str(error))
    if failures:
        print('FAIL: ' + '\n'.join(failures), file=sys.stderr)
        return 1
    print('PASS: production frame message preserves the native CGRect return ABI on both architectures.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
