#!/usr/bin/env python3
"""Check Swift hook ownership against the SDK and retain real SwiftUI values.

The production Swift source is compiled unchanged. Retention tests omit the C
shim's dyld table, so reference initializers remain native. A separate isolated
test executable uses the complete production interpose library; no Rex app is
launched or injected. Both supported architectures' method ABIs are inspected;
native lifetime tests execute only the current host architecture.
Requires macOS and Xcode command-line tools; uses no third-party dependencies.
"""
import argparse
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
KINDS = ('key-literal', 'key-init', 'interpolation', 'resource-literal', 'verbatim',
         'resource', 'attributed', 'generic')
PAIRS = (
    ('rxHookLKLiteral', 'originalLKLiteral', 'originalLiteral'),
    ('rxHookLKInit', 'originalLKInit', 'originalInit'),
    ('rxHookLKAppendLiteral', 'originalLKAppendLiteral', None),
    ('rxHookLR', 'originalLR', None),
    ('rxHookTextVerbatim', 'originalTextVerbatim', 'originalTextVerbatim'),
    ('rxHookTextLocalizedResource', 'originalTextLocalizedResource', 'originalTextLocalizedResource'),
    ('rxHookTextAttributedString', 'originalTextAttributedString', 'originalTextAttributedString'),
    ('rxHookTextGeneric', 'originalTextGeneric', None),
)

NATIVE_PROBE = r'''
import Foundation
import SwiftUI
func nativeKeyLiteral(_ value: String) -> LocalizedStringKey { LocalizedStringKey(stringLiteral: value) }
func nativeKeyInit(_ value: String) -> LocalizedStringKey { LocalizedStringKey(value) }
func nativeAppendLiteral(_ value: String, _ interpolation: inout LocalizedStringKey.StringInterpolation) { interpolation.appendLiteral(value) }
func nativeResourceLiteral(_ value: String) -> LocalizedStringResource { LocalizedStringResource(stringLiteral: value) }
func nativeVerbatim(_ value: String) -> Text { Text(verbatim: value) }
func nativeResource(_ value: LocalizedStringResource) -> Text { Text(value) }
func nativeAttributed(_ value: AttributedString) -> Text { Text(value) }
func nativeGeneric<S: StringProtocol>(_ value: S) -> Text { Text(value) }
'''

RUNNER = r'''
import Foundation
import SwiftUI

@main struct HookOwnershipTest {
  static let count = 10_000

  @inline(never) static func fixture(_ index: Int) -> (String, String) {
    let suffix = "/tmp/demo-host/样例-\(index)-😀/" + String(repeating: "generated long text ", count: 24)
    switch index % 3 {
    case 0: return (suffix, suffix)
    case 1: return ("Settings", "设置")
    default: return ("The Rex server did not become ready: " + suffix, "Rex 服务器未能就绪：" + suffix)
    }
  }

  @inline(never) static func keys(_ literal: Bool) -> Int {
    var values: [LocalizedStringKey] = []
    for index in 0..<count {
      let input = fixture(index).0
      values.append(literal ? rxHookLKLiteral(input, LocalizedStringKey.self) : rxHookLKInit(input, LocalizedStringKey.self))
    }
    var mismatches = 0
    for index in 0..<count {
      let expected = fixture(index).1
      let reference = literal ? LocalizedStringKey(stringLiteral: expected) : LocalizedStringKey(expected)
      if values[index] != reference { mismatches += 1 }
    }
    return mismatches // The retained values are destroyed before returning.
  }

  @inline(never) static func resources() -> Int {
    var values: [LocalizedStringResource] = []
    for index in 0..<count { values.append(rxHookLR(fixture(index).0, LocalizedStringResource.self)) }
    var mismatches = 0
    for index in 0..<count {
      if String(localized: values[index]) != fixture(index).1 { mismatches += 1 }
    }
    return mismatches
  }

  @inline(never) static func interpolation(_ index: Int, _ hooked: Bool, _ changedPayload: Bool = false) -> LocalizedStringKey.StringInterpolation {
    var value = LocalizedStringKey.StringInterpolation(literalCapacity: 512, interpolationCount: 2)
    let literal = fixture(index)
    if hooked { value.rxHookAppendLiteral(literal.0) }
    else { value.appendLiteral(literal.1) }
    // These values are interpolation payloads, even when they look like known
    // UI literals. Only appendLiteral is intercepted; they must stay intact.
    let payload = changedPayload ? "设置" : "Settings"
    value.appendInterpolation(payload + "/Filter/中文-😀-\(index)")
    if hooked { value.rxHookAppendLiteral(" / ") }
    else { value.appendLiteral(" / ") }
    value.appendInterpolation(changedPayload ? index + 1 : index)
    let unknown = "/tmp/unknown-literal-\(index)/" + String(repeating: "Settings Filter ", count: 24)
    if hooked { value.rxHookAppendLiteral(unknown) }
    else { value.appendLiteral(unknown) }
    return value
  }

  @inline(never) static func interpolations() -> Int {
    var retained: [LocalizedStringKey.StringInterpolation] = []
    for index in 0..<count { retained.append(interpolation(index, true)) }
    var keys: [LocalizedStringKey] = retained.map { LocalizedStringKey(stringInterpolation: $0) }
    // This SDK can report false for identical native interpolated keys during
    // first use of formatting patterns (the independent native control below
    // reproduces this). Compare complete reflected values in this test only,
    // against native references and changed-payload controls. Production never
    // inspects key storage. Every retained value, including zero, is compared.
    let nativeKeys = (0..<count).map { LocalizedStringKey(stringInterpolation: interpolation($0, false)) }
    var mismatches = 0
    var nativeEqualityDiscrepancies = 0
    for index in 0..<count {
      let expected = nativeKeys[index]
      let freshNative = LocalizedStringKey(stringInterpolation: interpolation(index, false))
      if expected != freshNative { nativeEqualityDiscrepancies += 1 }
      let expectedRepresentation = String(reflecting: expected)
      if expectedRepresentation != String(reflecting: freshNative) { print("native interpolation representation mismatch at \(index)"); mismatches += 1 }
      let changedPayload = LocalizedStringKey(stringInterpolation: interpolation(index, false, true))
      if String(reflecting: keys[index]) != expectedRepresentation { print("interpolation key mismatch at \(index)"); mismatches += 1 }
      // A negative control proves the comparison observes payload changes.
      if expectedRepresentation == String(reflecting: changedPayload) { print("interpolation payload negative control failed at \(index)"); mismatches += 1 }
    }
    // Retain copies after clearing the original interpolations and keys, then
    // verify again before every buffer and associated argument is destroyed.
    let copied = keys
    retained.removeAll()
    keys.removeAll()
    for index in 0..<count {
      if String(reflecting: copied[index]) != String(reflecting: nativeKeys[index]) { print("interpolation copied key mismatch at \(index)"); mismatches += 1 }
    }
    print("native complex-key equality discrepancies: \(nativeEqualityDiscrepancies); all values also checked against stable complete native representations")
    return mismatches
  }

  @inline(never) static func texts(_ kind: String) -> Int {
    var values: [Text] = []
    for index in 0..<count {
      let input = fixture(index).0
      switch kind {
      case "verbatim": values.append(rxHookTextVerbatim(input, Text.self))
      case "resource": values.append(rxHookTextLocalizedResource(LocalizedStringResource(String.LocalizationValue(input)), Text.self))
      case "attributed": values.append(rxHookTextAttributedString(AttributedString(input), Text.self))
      case "generic":
        // Exercise both String and Substring generic metadata/witness tables.
        #if LEGACY_GENERIC_INOUT
        if index % 2 == 0 {
          var value = input
          values.append(rxHookTextGeneric(&value, Text.self))
        } else {
          var value = ("!" + input).dropFirst()
          values.append(rxHookTextGeneric(&value, Text.self))
        }
        #else
        values.append(index % 2 == 0 ? rxHookTextGeneric(input, Text.self) : rxHookTextGeneric(("!" + input).dropFirst(), Text.self))
        #endif
      default: fatalError("Unknown text constructor")
      }
    }
    var mismatches = 0
    for index in 0..<count {
      let expected = fixture(index).1
      let reference: Text
      switch kind {
      case "resource": reference = Text(LocalizedStringResource(String.LocalizationValue(expected)))
      case "attributed": reference = Text(AttributedString(expected))
      default: reference = Text(verbatim: expected)
      }
      if values[index] != reference { mismatches += 1 }
    }
    return mismatches
  }

  static func main() {
    let kind = CommandLine.arguments[1]
    let mismatches: Int
    switch kind {
    case "key-literal": mismatches = keys(true)
    case "key-init": mismatches = keys(false)
    case "interpolation": mismatches = interpolations()
    case "resource-literal": mismatches = resources()
    default: mismatches = texts(kind)
    }
    print("\(kind): \(count) retained values, \(mismatches) mismatches; destruction completed")
    if mismatches != 0 { exit(1) }
  }
}
'''

INTERPOSE_RUNNER = r'''
import Foundation
import SwiftUI

@main struct InterpolationInterposeTest {
  static let count = 10_000

  @inline(never) static func key(_ index: Int, _ expected: Bool, _ changedString: Bool = false, _ changedNumber: Bool = false) -> LocalizedStringKey {
    var value = LocalizedStringKey.StringInterpolation(literalCapacity: 512, interpolationCount: 2)
    switch index % 3 {
    case 0: value.appendLiteral(expected ? "设置" : "Settings")
    case 1: value.appendLiteral(expected ? "筛选" : "Filter")
    default: value.appendLiteral("/tmp/unknown-\(index)/" + String(repeating: "Settings Filter 中文 😀 ", count: 24))
    }
    value.appendInterpolation(changedNumber ? index + 1 : index)
    value.appendLiteral(" / ")
    value.appendInterpolation(changedString ? "设置" : "Settings")
    return LocalizedStringKey(stringInterpolation: value)
  }

  static func main() {
    var retained: [LocalizedStringKey] = []
    for index in 0..<count { retained.append(key(index, false)) }
    let warmNative = key(-1, true)
    _ = warmNative == key(-1, true)
    let initializedNative = key(-1, true)
    guard initializedNative == key(-1, true) else { print("Native equality initialization failed"); exit(2) }
    var mismatches = 0
    for index in 0..<count {
      let expected = key(index, true)
      if retained[index] != expected { if mismatches < 10 { print("interpose key mismatch at \(index)") }; mismatches += 1 }
      if expected == key(index, true, true, false) { print("interpose String negative control failed at \(index)"); mismatches += 1 }
      if expected == key(index, true, false, true) { print("interpose number negative control failed at \(index)"); mismatches += 1 }
    }
    retained.removeAll()
    print("interpose: \(count) retained keys, \(mismatches) mismatches; destruction completed")
    if mismatches != 0 { exit(1) }
  }
}
'''

NATIVE_EQUALITY_CONTROL = r'''
import SwiftUI

@main struct NativeEqualityControl {
  static func key(_ index: Int) -> LocalizedStringKey {
    var value = LocalizedStringKey.StringInterpolation(literalCapacity: 64, interpolationCount: 2)
    value.appendLiteral("设置")
    value.appendInterpolation(index)
    value.appendLiteral(" / ")
    value.appendInterpolation("Settings")
    return LocalizedStringKey(stringInterpolation: value)
  }
  static func main() {
    let retained = (0..<10_000).map { key($0) }
    let firstEqual = retained[0] == key(0)
    let mismatches = (0..<10_000).filter { retained[$0] != key($0) }.count
    print("native equality control: first comparison equal=\(firstEqual); all 10000 retained native keys after initialization: \(mismatches) mismatches")
    if mismatches != 0 { exit(1) }
  }
}
'''


def first_ownership(signature):
    match = re.search(r'@convention\(\w+\)(?: <[^\n]*?>)? \((@\w+)', signature)
    if not match:
        raise ValueError('Cannot read ownership from SIL: ' + signature)
    return match.group(1)


def check_abi(production_sil, native_sil, shim):
    symbols = dict(re.findall(r'extern void (original\w+)\([^;]*?__asm__\("_(\$[^"\n]+)"\);', shim))
    failures = []
    for hook, original, cache in PAIRS:
        native = next(line for line in native_sil.splitlines() if line.startswith('sil ') and '@' + symbols[original] + ' :' in line)
        replacement = next((line for line in production_sil.splitlines() if line.startswith('sil ') and '@' + hook + ' :' in line), None)
        if replacement is None:
            failures.append(f'{hook}: production replacement is missing')
            continue
        expected = first_ownership(native)
        actual = first_ownership(replacement)
        if actual != expected:
            failures.append(f'{hook}: native input is {expected}, replacement is {actual}')
        if hook == 'rxHookLKAppendLiteral':
            # Mutating struct self uses swiftself, unlike an ordinary thin
            # function's inout parameter. Check the complete method signature,
            # not just the first argument ownership used for constructors.
            expected_method = '$@convention(method) (@guaranteed String, @inout LocalizedStringKey.StringInterpolation) -> ()'
            for label, line in [('native', native), ('replacement', replacement)]:
                if line.split(' : ', 1)[1].removesuffix(' {') != expected_method:
                    failures.append(f'{hook}: unexpected {label} method signature: {line}')
        if cache:
            cached = next(line for line in production_sil.splitlines() if line.startswith('sil_global ') and cache in line and '@convention(thin)' in line)
            cached_ownership = first_ownership(cached)
            if cached_ownership != expected:
                failures.append(f'{cache}: native input is {expected}, cached function type is {cached_ownership}')
    return failures


def check_method_ir(production_ir, native_ir, shim):
    symbol = re.search(r'extern void originalLKAppendLiteral\([^;]*?__asm__\("_(\$[^"\n]+)"\);', shim).group(1)
    failures = []
    for label, ir, declaration in [
        ('native', native_ir, 'declare swiftcc void @"' + symbol + '"'),
        ('replacement', production_ir, 'define swiftcc void @rxHookLKAppendLiteral'),
        ('original-method alias', production_ir, 'declare swiftcc void @"' + symbol + '"'),
    ]:
        line = next((line for line in ir.splitlines() if line.startswith(declaration + '(')), '')
        parameters = line.partition('(')[2].partition(')')[0].split(',')
        if (len(parameters) != 3 or not parameters[0].strip().startswith('i64') or
                not parameters[1].strip().startswith('ptr') or
                not parameters[2].strip().startswith('ptr swiftself')):
            failures.append(f'appendLiteral: unexpected {label} LLVM signature: {line}')
    body = re.search(r'define swiftcc void @rxHookLKAppendLiteral\(.*?^}', production_ir, re.M | re.S)
    if not body or 'call swiftcc void @"' + symbol + '"' not in body.group(0):
        failures.append('appendLiteral: replacement does not call the native method directly')
    return failures


def run():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=ROOT / 'RexTextHook.swift', help='Alternate production Swift file for regression comparison')
    args = parser.parse_args()
    source = args.source.resolve()
    shim = (ROOT / 'RexTextHookInterpose.c').read_text()
    # Keep every production address getter and declaration, but never install
    # the interpose table in this isolated lifetime test.
    getters, marker, _ = shim.partition('__attribute__((used))')
    if not marker:
        raise ValueError('Production interpose table marker was not found')
    with tempfile.TemporaryDirectory(prefix='rex-hook-ownership-') as directory:
        tmp = Path(directory)
        (tmp / 'getters.c').write_text(getters)
        (tmp / 'runner.swift').write_text(RUNNER)
        (tmp / 'native.swift').write_text(NATIVE_PROBE)
        subprocess.run(['clang', '-c', str(tmp / 'getters.c'), '-o', str(tmp / 'getters.o')], check=True)
        subprocess.run(['swiftc', '-emit-silgen', '-parse-as-library', str(source), '-o', str(tmp / 'production.sil')], check=True)
        subprocess.run(['swiftc', '-emit-silgen', '-parse-as-library', str(tmp / 'native.swift'), '-o', str(tmp / 'native.sil')], check=True)
        failures = check_abi((tmp / 'production.sil').read_text(), (tmp / 'native.sil').read_text(), shim)
        if failures:
            print('ABI ownership mismatches:\n' + '\n'.join(failures), flush=True)
        else:
            print('ABI: 8 replacement inputs and 5 cached original function types match the native SDK; appendLiteral borrows String with mutating self.', flush=True)
        if any('production replacement is missing' in failure for failure in failures):
            print('FAIL: required production hook is absent; the new path cannot be exercised.', flush=True)
            return 1
        (tmp / 'equality-control.swift').write_text(NATIVE_EQUALITY_CONTROL)
        subprocess.run(['swiftc', '-parse-as-library', str(tmp / 'equality-control.swift'), '-o', str(tmp / 'equality-control')], check=True)
        control = subprocess.run([str(tmp / 'equality-control')], capture_output=True, text=True, timeout=60)
        print(control.stdout.strip(), flush=True)
        if control.returncode:
            failures.append('native equality control did not stabilize for retained keys')
        for arch in ('arm64', 'x86_64'):
            production_ir, native_ir = tmp / f'production-{arch}.ll', tmp / f'native-{arch}.ll'
            common = ['swiftc', '-target', f'{arch}-apple-macos13.0', '-emit-ir', '-parse-as-library']
            subprocess.run(common + [str(source), '-o', str(production_ir)], check=True)
            subprocess.run(common + [str(tmp / 'native.swift'), '-o', str(native_ir)], check=True)
            method_failures = check_method_ir(production_ir.read_text(), native_ir.read_text(), shim)
            failures.extend(f'{arch}: {failure}' for failure in method_failures)
            print(f'appendLiteral LLVM ABI ({arch}): ' + ('FAIL' if method_failures else 'native, replacement and original alias preserve swiftself'), flush=True)
        command = ['swiftc', '-O', str(source), str(tmp / 'runner.swift'), str(tmp / 'getters.o'), '-o', str(tmp / 'runner')]
        if re.search(r'rxHookTextGeneric[^\n]*_ value: inout S', source.read_text()):
            command.extend(['-D', 'LEGACY_GENERIC_INOUT'])
        subprocess.run(command, check=True)
        for kind in KINDS:
            result = subprocess.run([str(tmp / 'runner'), kind], env={**os.environ, 'MallocScribble': '1'}, capture_output=True, text=True, timeout=60)
            print(result.stdout.strip() or f'{kind}: process exit {result.returncode}', flush=True)
            if result.returncode:
                failures.append(f'{kind}: process exit {result.returncode}')
                if result.stderr:
                    print('\n'.join(result.stderr.splitlines()[:12]), flush=True)
        # Unlike the retained-value checks above, this isolated executable uses
        # the complete production interpose table. Prove ordinary native calls
        # are intercepted, while calls originating inside the replacement dylib
        # reach the original method instead of recursively interposing itself.
        (tmp / 'interpose-runner.swift').write_text(INTERPOSE_RUNNER)
        subprocess.run(['swiftc', '-parse-as-library', str(tmp / 'interpose-runner.swift'), '-o', str(tmp / 'interpose-runner')], check=True)
        baseline = subprocess.run([str(tmp / 'interpose-runner')], capture_output=True, text=True, timeout=60)
        print('without interpose: ' + baseline.stdout.strip(), flush=True)
        if baseline.returncode != 1 or '6667 mismatches' not in baseline.stdout:
            failures.append('interpolation baseline did not expose the missing literal interception')
        (tmp / 'interpose.c').write_text(shim)
        subprocess.run(['clang', '-c', str(tmp / 'interpose.c'), '-o', str(tmp / 'interpose.o')], check=True)
        library = tmp / 'libRexTextHook-test.dylib'
        subprocess.run(['swiftc', '-O', '-emit-library', '-parse-as-library', str(source), str(tmp / 'interpose.o'), '-o', str(library)], check=True)
        injected = subprocess.run([str(tmp / 'interpose-runner')], env={**os.environ, 'DYLD_INSERT_LIBRARIES': str(library), 'MallocScribble': '1'}, capture_output=True, text=True, timeout=60)
        print('with production interpose: ' + injected.stdout.strip(), flush=True)
        if injected.returncode or '0 mismatches' not in injected.stdout:
            failures.append(f'interpolation interpose: process exit {injected.returncode}')
            if injected.stderr:
                print('\n'.join(injected.stderr.splitlines()[:12]), flush=True)
        if failures:
            print('FAIL: ' + '; '.join(failures))
            return 1
        print('PASS: constructors and literal interpolation preserved translations and payloads across retention and destruction; isolated production interposition also passed.')
        return 0


if __name__ == '__main__':
    sys.exit(run())
