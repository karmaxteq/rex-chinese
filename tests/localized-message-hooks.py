#!/usr/bin/env python3
"""Exercise real Foundation resources through the built SwiftUI interpose library.

This constructs values only: it does not open windows or prove rendered pixels.
Expected Text values call the native constructor address exported by the production
library, so the same translation hook cannot translate both sides of a comparison.
"""
import hashlib
import json
import os
from pathlib import Path
import platform
import subprocess
import sys
import tempfile


ROOT = Path(__file__).resolve().parents[1]
LIBRARY = ROOT / 'bin/libRexTextHook.dylib'
ARTIFACTS = ROOT / '.artifacts/remaining-literals-1030'

RUNNER = r'''
import Darwin
import Foundation
import SwiftUI

private typealias NativeResourceText = @convention(thin) (consuming LocalizedStringResource, Text.Type) -> Text
private typealias OriginalAddress = @convention(c) () -> UnsafeRawPointer

@main struct LocalizedMessageHooks {
  static func require(_ condition: @autoclosure () -> Bool, _ reason: String) {
    if !condition() { fputs("FAIL: \(reason)\n", stderr); exit(2) }
  }

  static func resource(_ value: String) -> LocalizedStringResource {
    // This initializer is not the interposed resource string-literal initializer.
    LocalizedStringResource(String.LocalizationValue(value), table: nil,
      locale: Locale.current, bundle: .main, comment: nil)
  }

  static func main() {
    let injected = CommandLine.arguments[1] == "injected"
    let handle = dlopen(nil, RTLD_NOW)!
    defer { dlclose(handle) }
    let getter = dlsym(handle, "rxOrigTextLocalizedResourceAddress")
    require((getter != nil) == injected, "production native constructor export presence")
    let original: NativeResourceText?
    if let getter {
      let address = unsafeBitCast(getter, to: OriginalAddress.self)()
      var info = Dl_info()
      require(dladdr(getter, &info) != 0, "resolve production getter image")
      let actualPath = URL(fileURLWithPath: String(cString: info.dli_fname)).resolvingSymlinksInPath().path
      let expectedPath = URL(fileURLWithPath: CommandLine.arguments[2]).resolvingSymlinksInPath().path
      require(actualPath == expectedPath, "native getter belongs to requested production library")
      original = unsafeBitCast(address, to: NativeResourceText.self)
    } else {
      original = nil
    }

    func native(_ value: LocalizedStringResource) -> Text {
      if let original { return original(value, Text.self) }
      // No injected library is present in this baseline process.
      return Text(value)
    }

    var positives = 0
    var positiveFailures = 0
    var controls = 0
    var retained: [(Text, Text)] = []
    func check(_ name: String, _ input: LocalizedStringResource,
               _ english: String, _ expected: String, _ wrong: String) {
      require(String(localized: input) == english, "\(name): Foundation payload rendering")
      let referenceResource = resource(expected)
      require(String(localized: referenceResource) == expected, "\(name): native expected payload rendering")
      let reference = native(referenceResource)
      require(reference == native(referenceResource), "\(name): native reference equality")
      let nativeEnglish = native(input)
      require(nativeEnglish != reference, "\(name): bypass control was translated or equality is uninformative")
      require(native(resource(wrong)) != reference, "\(name): wrong expected control")
      let actual = Text(input)
      if actual != reference { positiveFailures += 1 }
      require(actual != native(resource(wrong)), "\(name): actual equals wrong expected")
      if injected {
        require(actual != nativeEnglish, "\(name): injected call bypassed translation")
      } else {
        require(actual == nativeEnglish, "\(name): baseline differs from native call")
      }
      retained.append((actual, reference))
      positives += 1
      controls += 5
    }

    let payloads = ["Filter Settings", "中文 😀 用户输入", "\u{0301}Settings",
                    "/tmp/Filter/Settings.txt", "%1$@"]
    for (index, payload) in payloads.enumerated() {
      let account = LocalizedStringResource("Rex will verify the caller is signed in as \(payload).",
        table: nil, locale: Locale.current, bundle: .main, comment: nil)
      check("account-\(index)", account,
        "Rex will verify the caller is signed in as \(payload).",
        "Rex 将验证调用者是否以 \(payload) 登录。",
        "Rex 将验证调用者是否以 \(payload)-wrong 登录。")

      let host = LocalizedStringResource("Tailscale assigned \(payload) for your address. The address may differ to keep it unique.",
        table: nil, locale: Locale.current, bundle: .main, comment: nil)
      check("host-\(index)", host,
        "Tailscale assigned \(payload) for your address. The address may differ to keep it unique.",
        "Tailscale 为你的地址分配了 \(payload)。为保持地址唯一，实际地址可能不同。",
        "Tailscale 为你的地址分配了 \(payload)-wrong。为保持地址唯一，实际地址可能不同。")

      let migration = LocalizedStringResource("Migrate my keybindings and settings from \(payload) to Rex. Run `rex skill show` to learn how Rex is configured.",
        table: nil, locale: Locale.current, bundle: .main, comment: nil)
      check("migration-\(index)", migration,
        "Migrate my keybindings and settings from \(payload) to Rex. Run `rex skill show` to learn how Rex is configured.",
        "将我的快捷键和设置从 \(payload) 迁移到 Rex。运行 `rex skill show` 了解 Rex 的配置方式。",
        "将我的快捷键和设置从 \(payload)-wrong 迁移到 Rex。运行 `rex skill show` 了解 Rex 的配置方式。")

      let serverRevision = payload
      let appRevision = "APP-\(index)-\(payload)"
      let support = LocalizedStringResource("Server supports \(serverRevision); Rex.app supports \(appRevision).",
        table: nil, locale: Locale.current, bundle: .main, comment: nil)
      check("support-\(index)", support,
        "Server supports \(serverRevision); Rex.app supports \(appRevision).",
        "服务器支持 \(serverRevision)；Rex.app 支持 \(appRevision)。",
        "服务器支持 \(appRevision)；Rex.app 支持 \(serverRevision)。")
    }
    check("sRGB-resource", resource("Six-digit sRGB hex color, for example #AABBCC"),
      "Six-digit sRGB hex color, for example #AABBCC",
      "六位 sRGB 十六进制颜色，例如 #AABBCC",
      "六位 sRGB 十六进制颜色，例如 #AABBCD")

    var negatives = 0
    for payload in payloads {
      let prefixed = LocalizedStringResource("Notes: Tailscale assigned \(payload) for your address. The address may differ to keep it unique.",
        table: nil, locale: Locale.current, bundle: .main, comment: nil)
      let literal = resource(payload)
      require(String(localized: prefixed) == "Notes: Tailscale assigned \(payload) for your address. The address may differ to keep it unique.",
        "negative interpolated payload rendering")
      require(String(localized: literal) == payload, "negative literal payload rendering")
      for input in [prefixed, literal] {
        let actual = Text(input)
        let reference = native(input)
        require(reference == native(input), "negative native equality")
        require(actual == reference, "unrelated text or payload was changed")
        require(actual != native(resource("WRONG unchanged-text control")), "negative wrong expected control")
        negatives += 1
        controls += 3
      }
    }
    require(positives == 21 && negatives == 10 && retained.count == 21,
      "fixed fixture inventory changed")
    require(controls == 135, "fixed comparison-control inventory changed")
    let retainedFailures = retained.filter { $0.0 != $0.1 }.count
    require(retainedFailures == positiveFailures, "retained values changed after construction")
    require(positiveFailures == (injected ? 0 : positives), "unexpected translation mismatch count")
    let report: [String: Any] = ["mode": injected ? "injected" : "baseline",
      "positiveCases": positives, "positiveFailures": positiveFailures,
      "negativeCases": negatives, "comparisonControls": controls,
      "retainedValues": retained.count, "nativeExpectedBypassesHook": true]
    let bytes = try! JSONSerialization.data(withJSONObject: report, options: [.sortedKeys])
    FileHandle.standardOutput.write(bytes)
    FileHandle.standardOutput.write(Data("\n".utf8))
  }
}
'''


def run():
    ARTIFACTS.mkdir(parents=True, exist_ok=True)
    log_path = ARTIFACTS / 'localized-message-hooks.log'
    report_path = ARTIFACTS / 'localized-message-hooks.json'
    transcript = []
    stage = 'library'
    try:
        before_sha = hashlib.sha256(LIBRARY.read_bytes()).hexdigest()
        # Ignore inherited injection settings: baseline and injected processes
        # differ only by the single requested production library.
        environment = {key: value for key, value in os.environ.items()
                       if not key.startswith(('DYLD_', 'RX_'))}
        environment['MallocScribble'] = '1'
        with tempfile.TemporaryDirectory(prefix='rex-localized-message-hooks-') as directory:
            tmp = Path(directory)
            source = tmp / 'main.swift'
            runner = tmp / 'runner'
            source.write_text(RUNNER)
            stage = 'compile'
            result = subprocess.run(['swiftc', '-parse-as-library', str(source), '-o', str(runner)],
                                    capture_output=True, text=True, timeout=120)
            transcript.append(f'compile exit={result.returncode}\n{result.stdout}{result.stderr}')
            if result.returncode:
                raise RuntimeError('Swift runner compilation failed')
            results = {}
            for mode in ['baseline', 'injected']:
                stage = mode
                env = dict(environment)
                if mode == 'injected':
                    env['DYLD_INSERT_LIBRARIES'] = str(LIBRARY)
                result = subprocess.run([str(runner), mode, str(LIBRARY)], env=env,
                                        capture_output=True, text=True, timeout=60)
                transcript.append(f'{mode} exit={result.returncode}\n{result.stdout}{result.stderr}')
                if result.returncode:
                    raise RuntimeError(f'{mode} runner failed')
                results[mode] = json.loads(result.stdout)
            stage = 'readback'
            after_sha = hashlib.sha256(LIBRARY.read_bytes()).hexdigest()
            if before_sha != after_sha:
                raise RuntimeError('Production library changed during test')
            report = {'status': 'pass', 'architecture': platform.machine(),
                      'library': str(LIBRARY), 'librarySHA256': before_sha,
                      'renderedPixelsVerified': False, **results}
            report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
            print(json.dumps(report, ensure_ascii=False, separators=(',', ':')))
            return 0
    except (OSError, RuntimeError, ValueError, subprocess.TimeoutExpired) as error:
        report = {'status': 'fail', 'stage': stage, 'reason': str(error), 'log': str(log_path)}
        report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
        print(json.dumps(report, ensure_ascii=False, separators=(',', ':')))
        return 1
    finally:
        log_path.write_text('\n'.join(transcript))


if __name__ == '__main__':
    sys.exit(run())
