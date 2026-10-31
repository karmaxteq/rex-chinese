#!/usr/bin/env python3
"""Compile and exercise the production translators without injecting the app.

Only the pure translation functions are extracted. The tests call those functions,
including their production dictionaries, so this also checks Swift/ObjC parity.
Requires the macOS Xcode command-line tools; no third-party dependencies.
"""
import json
from pathlib import Path
import subprocess
import tempfile
import sys

ROOT = Path(__file__).resolve().parents[1]
CASES = [
    # Native palette labels observed only after scrolling past the first page.
    ('Change Theme', '更改主题'),
    ('Select Theme...', '选择主题…'),
    ('Select Theme…', '选择主题…'),
    ('Auto Color Scheme', '自动配色方案'),
    ('Light Color Scheme', '浅色配色方案'),
    ('Dark Color Scheme', '深色配色方案'),
    ('Auto Color 方案', '自动配色方案'),
    ('Light Color 方案', '浅色配色方案'),
    ('Dark Color 方案', '深色配色方案'),
    ('/tmp/Change Theme/Settings.txt', '/tmp/Change Theme/Settings.txt'),
    ('Custom Change Theme', 'Custom Change Theme'),
    ('Change Theme-host.example', 'Change Theme-host.example'),
    ('Ready to Check for Updates · Preview', '可以检查更新 · 预览'),
    ('Ready to Check for Updates · Bleeding Edge', '可以检查更新 · 前沿版'),
    ('Ready to Check for Updates · 预览', '可以检查更新 · 预览'),
    ('Ready to Check for Updates · 前沿版', '可以检查更新 · 前沿版'),
    ('Ready to Check for Updates · Custom', 'Ready to Check for Updates · Custom'),
    ('/tmp/Ready to Check for Updates · Preview.txt', '/tmp/Ready to Check for Updates · Preview.txt'),
    # The sRGB theme-color help is a distinct literal from the Display P3 help.
    ('Six-digit sRGB hex color, for example #AABBCC', '六位 sRGB 十六进制颜色，例如 #AABBCC'),
    ('Cursor Text color', '光标文本颜色'),
    ('sRGB', 'sRGB'),
    ('#AABBCC', '#AABBCC'),
    ('/tmp/Six-digit sRGB hex color, for example #AABBCC.txt', '/tmp/Six-digit sRGB hex color, for example #AABBCC.txt'),
    ('Notes: Six-digit sRGB hex color, for example #AABBCC', 'Notes: Six-digit sRGB hex color, for example #AABBCC'),
    # Visible residuals found while sweeping the full shortcuts list.
    ('Split Pane', '分栏'),
    ('Split Pane Left', '向左分栏'),
    ('Split Pane Up', '向上分栏'),
    ('Split Pane Down', '向下分栏'),
    ('Focus Pane', '聚焦窗格'),
    ('Keys', '按键'),
    ('No GUI Overrides Yet', '尚未在此修改快捷键'),
    ('Connected', '已连接'),
    ('/tmp/Connected/Settings.txt', '/tmp/Connected/Settings.txt'),
    ('Connected-host', 'Connected-host'),
    # Actual remote-host status while the isolated server is disconnected.
    ('Reconnecting…', '正在重新连接…'),
    ('/tmp/Reconnecting…/Settings.txt', '/tmp/Reconnecting…/Settings.txt'),
    ('Settings Filter Reconnecting…', 'Settings Filter Reconnecting…'),
    ('正在重新连接…', '正在重新连接…'),
    ('Exited', '已退出'),
    ('Starting…', '正在启动…'),
    ('Starting...', '正在启动…'),
    ('Stopping…', '正在停止…'),
    ('Stopping...', '正在停止…'),
    ('Stopped', '已停止'),
    ('Downloading update 0%', '正在下载更新 0%'),
    ('Downloading update 42%', '正在下载更新 42%'),
    ('Downloading update 100%', '正在下载更新 100%'),
    ('正在下载更新 42%', '正在下载更新 42%'),
    ('Downloading update pending', 'Downloading update pending'),
    ('Update failed', '更新失败'),
    ('Update failed.', '更新失败。'),
    ('Update failed. 更新签名不正确，无法验证。请稍后重试，或联系应用开发者。',
     '更新失败。更新签名不正确，无法验证。请稍后重试，或联系应用开发者。'),
    ('The update is improperly signed and could not be validated. Please try again later or contact the app developer.',
     '更新签名不正确，无法验证。请稍后重试，或联系应用开发者。'),
    ('Update failed. The update is improperly signed and could not be validated. Please try again later or contact the app developer.',
     '更新失败。更新签名不正确，无法验证。请稍后重试，或联系应用开发者。'),
    ('登录 Tailscale、Start the Rex Server to sign in.', '登录 Tailscale、启动 Rex 服务器以登录。'),
    ('登录 Tailscale、Start the Rex server to sign in.', '登录 Tailscale、启动 Rex 服务器以登录。'),
    ('/tmp/Exited/Connected', '/tmp/Exited/Connected'),
    ('Action failed.', '操作失败。'),
    ('Action failed', '操作失败'),
    ('Expanded', '已展开'),
    ('Expanded-host', 'Expanded-host'),
    ('/tmp/Action failed/Settings.txt', '/tmp/Action failed/Settings.txt'),
    ('The tab could not be activated. On Settings Filter 中文验证1030: The server is not ready for this operation.',
     '无法激活标签页。主机 Settings Filter 中文验证1030：服务器尚未准备好执行此操作。'),
    ('无法激活标签页。On Settings Filter 中文验证1030: The server is not ready for this operation.',
     '无法激活标签页。主机 Settings Filter 中文验证1030：服务器尚未准备好执行此操作。'),
    ('无法激活标签页。 On Settings Filter 中文验证1030: The server is not ready for this operation.',
     '无法激活标签页。主机 Settings Filter 中文验证1030：服务器尚未准备好执行此操作。'),
    ('The tab could not be activated. On /tmp/Filter/Settings.txt: The server is not ready for this operation.',
     '无法激活标签页。主机 /tmp/Filter/Settings.txt：服务器尚未准备好执行此操作。'),
    # A leading combining mark is part of the host, not the preceding literal.
    ('Action failed. The tab could not be activated. On \u0301Settings: The server is not ready for this operation.',
     '操作失败。无法激活标签页。主机 \u0301Settings：服务器尚未准备好执行此操作。'),
    ('The tab could not be activated. On \u0301Settings: The server is not ready for this operation.',
     '无法激活标签页。主机 \u0301Settings：服务器尚未准备好执行此操作。'),
    ('无法激活标签页。On \u0301Settings: The server is not ready for this operation.',
     '无法激活标签页。主机 \u0301Settings：服务器尚未准备好执行此操作。'),
    ('无法激活标签页。 On \u0301Settings: The server is not ready for this operation.',
     '无法激活标签页。主机 \u0301Settings：服务器尚未准备好执行此操作。'),
    ('The tab could not be activated. On : The server is not ready for this operation.',
     '无法激活标签页。On : The server is not ready for this operation.'),
    ('The tab could not be activated. On Settings Filter 中文验证1030: diagnostics Filter Settings',
     '无法激活标签页。On Settings Filter 中文验证1030: diagnostics Filter Settings'),
    ('Action failed. The tab could not be activated. On 中文本机验证1030: The server is not ready for this operation.',
     '操作失败。无法激活标签页。主机 中文本机验证1030：服务器尚未准备好执行此操作。'),
    ('Action failed. The tab could not be activated. On Filter Settings 😀: The server is not ready for this operation.',
     '操作失败。无法激活标签页。主机 Filter Settings 😀：服务器尚未准备好执行此操作。'),
    ('Action failed. The tab could not be activated. On /tmp/Filter/Settings.txt: The server is not ready for this operation.',
     '操作失败。无法激活标签页。主机 /tmp/Filter/Settings.txt：服务器尚未准备好执行此操作。'),
    ('Notes: Action failed. The tab could not be activated. On demo: The server is not ready for this operation.',
     'Notes: Action failed. The tab could not be activated. On demo: The server is not ready for this operation.'),
    ('Action failed. The tab could not be activated. On : The server is not ready for this operation.',
     'Action failed. The tab could not be activated. On : The server is not ready for this operation.'),
    ('Action failed. The tab could not be activated. On demo: diagnostics Filter Settings',
     'Action failed. The tab could not be activated. On demo: diagnostics Filter Settings'),
    ('Change the shortcut for Split Pane Left', '修改 向左分栏 的快捷键'),
    ('Record a shortcut for Focus Pane', '录制 聚焦窗格 的快捷键'),
    ('See the keys bound to Split Pane and where each came from.', '查看绑定到 分栏 的按键及其来源。'),
    ('/tmp/Keys/Split Pane.txt', '/tmp/Keys/Split Pane.txt'),
    ('Custom Split Pane', 'Custom Split Pane'),
    ('Preview', '预览'),
    (' — Dynamic', ' — 动态'),
    ('0 results', '0 项结果'),
    ('1 result', '1 项结果'),
    ('91 results', '91 项结果'),
    ('999999 results', '999999 项结果'),
    ('user results', 'user results'),
    ('-1 results', '-1 results'),
    ('1.5 results', '1.5 results'),
    ('See the keys bound to Switch Appearance Mode and where each came from.', '查看绑定到 切换外观模式 的按键及其来源。'),
    ('See the keys bound to Toggle Activity and where each came from.', '查看绑定到 切换活动 的按键及其来源。'),
    ('See the keys bound to and where each came from.', 'See the keys bound to and where each came from.'),
    ('录制、移除或重置绑定到 Toggle Activity 的按键。', '录制、移除或重置绑定到 切换活动 的按键。'),
    ('录制、移除或重置绑定到 Toggle Activity 的按键', '录制、移除或重置绑定到 切换活动 的按键'),
    ('查看绑定到 Switch Appearance Mode 的按键及其来源。', '查看绑定到 切换外观模式 的按键及其来源。'),
    ('Record, remove, or reset the keys bound to Toggle Activity.', '录制、移除或重置绑定到 切换活动 的按键。'),
    ('录制、移除或重置绑定到 Toggle Activity. 的按键', '录制、移除或重置绑定到 切换活动 的按键。'),
    ('快捷键 › 快捷键、切换外观模式、See the keys bound to Switch Appearance Mode and where each came from.', '快捷键 › 快捷键、切换外观模式、查看绑定到 切换外观模式 的按键及其来源。'),
    ('快捷键 › 快捷键、复制配置文件路径、Record, remove, or reset the keys bound to Copy Config File Path.', '快捷键 › 快捷键、复制配置文件路径、录制、移除或重置绑定到 复制配置文件路径 的按键。'),
    ('快捷键 › 快捷键、切换活动、录制、移除或重置绑定到 Toggle Activity. 的按键', '快捷键 › 快捷键、切换活动、录制、移除或重置绑定到 切换活动 的按键。'),
    ('录制、移除或重置以下操作的按键：Toggle Activity.', '录制、移除或重置以下操作的按键：切换活动。'),
    ('录制、移除或重置以下操作的按键：my-task', '录制、移除或重置以下操作的按键：my-task'),
    ('Displayed top left', '显示在左上角'),
    ('Displayed top center', '显示在顶部居中'),
    ('Displayed top right', '显示在右上角'),
    ('Displayed bottom left', '显示在左下角'),
    ('Displayed bottom center', '显示在底部居中'),
    ('Displayed bottom right', '显示在右下角'),
    ('Press a shortcut for Toggle Full Screen', '按下用于切换全屏的快捷键'),
    ('example.com is not an HTTP or HTTPS address', 'example.com 不是 HTTP 或 HTTPS 地址'),
    ('ssh://demo-host is not an HTTP or HTTPS address', 'ssh://demo-host 不是 HTTP 或 HTTPS 地址'),
    ('/tmp/中文 😀.json is not a folder', '/tmp/中文 😀.json 不是文件夹'),
    ('Another client resized this terminal to 80x24', '另一个客户端已将此终端调整为 80x24'),
    ('The Rex server did not become ready: /tmp/中文 😀/rex', 'Rex 服务器未能就绪：/tmp/中文 😀/rex'),
    ('The Rex server working directory could not be prepared: /tmp/中文 😀/rex', 'Rex 服务器工作目录无法准备：/tmp/中文 😀/rex'),
    ('Connection attempt 123 failed. Choose to try again now.', '连接尝试 123 失败。请选择立即重试。'),
    ('Recently used path. Press ⌘⌫ to remove from recents.', '最近使用的路径。按下 ⌘⌫ 从最近记录中移除。'),
    ('Record a shortcut for Toggle Full Screen', '录制 切换全屏 的快捷键'),
    ('Change the shortcut for Toggle Full Screen', '修改 切换全屏 的快捷键'),
    ('Record, remove, or reset the keys bound to Toggle Full Screen', '录制、移除或重置绑定到 切换全屏 的按键'),
    ('Add a shortcut for Toggle Full Screen', '为 切换全屏 添加快捷键'),
    ('You don’t have permission to view /tmp/中文 😀', '你没有权限查看 /tmp/中文 😀'),
    ("You don't have permission to view /tmp/中文 😀", '你没有权限查看 /tmp/中文 😀'),
    ('No folders named test-123', '没有名为 test-123 的文件夹'),
    ('Couldn’t load this folder (/tmp/中文)', '无法加载此文件夹（/tmp/中文)'),
    ("Couldn't load this folder (/tmp/中文)", '无法加载此文件夹（/tmp/中文)'),
    ('No app is set to open ssh://demo-host', '没有设置用于打开的应用：ssh://demo-host'),
    ('Couldn’t Connect to demo-host', '无法连接到 demo-host'),
    ("Couldn't Connect to demo-host", '无法连接到 demo-host'),
    ('Rex.app includes version 0.1.0 (1408)', 'Rex.app 包含版本 0.1.0 (1408)'),
    ('Running server version: 0.1.0 (1408)', '运行中服务器版本：0.1.0 (1408)'),
    ('The server supports API revisions 7–9', '服务器支持 API 修订版 7–9'),
    ('session-中文 😀 was not found on this server', 'session-中文 😀未在此服务器上找到'),
    ('no host has a session 123-中文', '没有主机拥有会话 123-中文'),
    ('rex exited with status 127', 'rex 已退出，状态码 127'),
    ('Rex must be updated: 0.1.0', 'Rex 必须更新：0.1.0'),
    ('The Rex server command failed: /tmp/中文', 'Rex 服务器命令失败：/tmp/中文'),
    ('The Rex server could not be launched: /tmp/中文', 'Rex 服务器无法启动：/tmp/中文'),
    ('The durable host ID is 123-中文', '持久主机 ID 为 123-中文'),
    ('Set Cursor Blink Interval to 500', '将光标闪烁间隔设为 500'),
    ('Choose a preset or enter a whole number from 1–1000', '选择预设，或输入一个整数，范围为 1–1000'),
    ('Server supports 7–9', '服务器支持 7–9'),
    ('Rex.app supports 7–9', 'Rex.app 支持 7–9'),
    ('Rex.app uses Revision 7', 'Rex.app 使用修订版 7'),
    ('Couldn’t read Rex Server’s permissions: /tmp/中文', '无法读取 Rex 服务器的权限：/tmp/中文'),
    ("Couldn't read Rex Server's permissions: /tmp/中文", '无法读取 Rex 服务器的权限：/tmp/中文'),
    ('Unable to follow Rex server logs: /tmp/中文', '无法跟踪 Rex 服务器日志：/tmp/中文'),
    ('Unable to observe Rex server status: /tmp/中文', '无法观察 Rex 服务器状态：/tmp/中文'),
    ('status exited with 127', '状态退出，结果为 127'),
    ('Rex server status is ambiguous (127)', 'Rex 服务器状态不明确（127)'),
    ('Rex server status could not be verified. /tmp/中文', '无法验证 Rex 服务器状态。/tmp/中文'),
    ('Rex Server is running as part of /tmp/中文', 'Rex 服务器属于 /tmp/中文'),
    ('Rex server is running as part of /tmp/中文', 'Rex 服务器属于 /tmp/中文'),
    ('The running Rex server and this Rex.app share no version of the control API. 7–9', '正在运行的 Rex 服务器与此 Rex.app 没有共同的控制 API 版本。 7–9'),
    ('The running Rex server is older than this Rex.app. 7–9', '正在运行的 Rex 服务器版本低于此 Rex.app。7–9'),
    ('Signing out of Tailscale timed out. demo-host', '退出 Tailscale 超时。demo-host'),
    ('Changing Tailscale tags timed out. tag:test', '更改 Tailscale 标签超时。tag:test'),
    ('This app is older than Rex on demo-host', '此应用版本低于主机上的 Rex：demo-host'),
    ('This device is offline. Restore your network connection, then retry connecting to demo-host', '此设备处于离线状态。请恢复网络连接，然后重试连接到 demo-host'),
    ('Rex couldn’t start Tailscale to remove the saved login. /tmp/中文', 'Rex 无法启动 Tailscale 以移除保存的登录信息。/tmp/中文'),
    ("Rex couldn't start Tailscale to remove the saved login. /tmp/中文", 'Rex 无法启动 Tailscale 以移除保存的登录信息。/tmp/中文'),
    ('Running for 2d15h', '已运行2d15h'),
    ('Create a session on demo-host', '在 demo-host 上创建会话'),
    ('Connection warning for demo-host', '连接警告：demo-host'),
    ('Move 中文 😀 pane', '移动 中文 😀 窗格'),
    ('Remove “中文 😀”?', '移除“中文 😀”?'),
    ("Remove '中文 😀'?", "移除'中文 😀'?"),
    ('The theme is missing valid colors for: background, foreground, palette 15', '主题缺少有效颜色：背景色、前景色、调色板 15'),
    ('Drag into the list in System Settings to grant access.', '将其拖入系统设置中的列表以授予访问权限。'),
    ('Waiting for permission', '正在等待权限'),
    ('Unsupported block', '不支持的内容块'),
    ('The content environment does not provide the capabilities required by this block.', '当前内容环境不具备此内容块所需的功能。'),
    ('Type Shortcut...', '输入快捷键…'),
    ('Type Shortcut…', '输入快捷键…'),
]

for action_name in ['Rex Diagnostics', 'Rex 诊断']:
    for wrapper, expected in [
        ('Change the shortcut for ', '修改 Rex 诊断 的快捷键'),
        ('Record a shortcut for ', '录制 Rex 诊断 的快捷键'),
        ('Add a shortcut for ', '为 Rex 诊断 添加快捷键'),
        ('Press a shortcut for ', '按下用于Rex 诊断的快捷键'),
        ('Record, remove, or reset the keys bound to ', '录制、移除或重置绑定到 Rex 诊断 的按键'),
    ]:
        CASES.append((wrapper + action_name, expected))

# Installed display names are a closed allowlist, not a generic Quit/Hide/About rule.
for app_name in ['Rex', 'Rex Beta', 'Rex 中文版', 'Rex Beta 中文版']:
    for action, translated in [('Quit', '退出'), ('Hide', '隐藏'), ('About', '关于')]:
        CASES.append((f'{action} {app_name}', f'{translated} {app_name}'))
    for ellipsis in ['…', '...']:
        CASES.append((f'About {app_name}{ellipsis}', f'关于 {app_name}…'))

# Complete interpolated UI messages reconstructed from the original binary.
# Preserve payloads even when they resemble translation keys or begin with a
# combining mark; Swift and ObjC must use the same literal boundaries.
for account in ['Filter Settings', '中文 😀 用户输入', '\u0301Settings', 'user@example.invalid', '%1$@']:
    CASES.append((f'Rex will verify the caller is signed in as {account}.',
                  f'Rex 将验证调用者是否以 {account} 登录。'))
for host in ['Filter Settings', '中文 😀', '\u0301Settings', '/tmp/Filter/Settings.txt', '%@']:
    for prefix in ['Tailscale assigned ', 'Tailscale 已分配 ']:
        CASES.append((prefix + host + ' for your address. The address may differ to keep it unique.',
                      f'Tailscale 为你的地址分配了 {host}。为保持地址唯一，实际地址可能不同。'))
for source in ['Ghostty', 'Filter Settings', '中文 😀', '\u0301Settings', '/tmp/Filter/Settings.txt', '%@']:
    expected = f'将我的快捷键和设置从 {source} 迁移到 Rex。运行 `rex skill show` 了解 Rex 的配置方式。'
    for prefix in ['Migrate my keybindings and settings from ', '从以下来源迁移我的快捷键和设置：']:
        CASES.append((prefix + source + ' to Rex. Run `rex skill show` to learn how Rex is configured.', expected))
    CASES.append((f'从 {source} to Rex. Run `rex skill show` to learn how Rex is configured. 迁移我的快捷键和设置', expected))
for server, app in [('1–2', '2–3'), ('7', '9'), ('%@', '%@'), ('%1$@', '%2$@'), ('\u0301Settings', '/tmp/Filter/Settings.txt')]:
    for prefix in ['Server supports ', '服务器支持 ']:
        for separator in ['; Rex.app supports ', '; Rex.app 支持 ']:
            CASES.append((prefix + server + separator + app + '.',
                          f'服务器支持 {server}；Rex.app 支持 {app}。'))
for value in [
    'Rex will verify the caller is signed in as Settings',
    'Rex will verify the caller is signed in as .',
    'Notes: Rex will verify the caller is signed in as Settings.',
    'Notes: Tailscale assigned Settings for your address. The address may differ to keep it unique.',
    'Notes: Server supports 1–2; Rex.app supports 2–3.',
    'Notes: Migrate my keybindings and settings from Ghostty to Rex. Run `rex skill show` to learn how Rex is configured.',
]:
    CASES.append((value, value))

# Values without Rex UI sentence prefixes are user content and must survive intact.
for value in ['', '中文界面', '/tmp/中文 😀/rex', '80x24', 'ssh://demo-host', 'Tailscale', 'test-123', 'Already translated 已翻译', 'Quit Terminal', 'Quit Rex Beta task', 'Hide Rex Beta logs', 'About Rexology', 'Quit Rex Beta 中文版 session', 'About Rex Beta 中文版 notes']:
    CASES.append((value, value))

# Messages found in the original binary plus the actual mixed shortcut labels.
# Include payload and prefix boundaries, not just the newly added exact keys.
CASES.extend((case['input'], case['expected']) for case in json.loads(
    (ROOT / 'tests/data/dynamic-coverage.json').read_text()))

# Keep the high-confidence UI literals found by the version-specific binary
# audit in the ordinary translation regression. This protects the strings
# that are not present in the published .strings catalog but are still
# rendered by Rex's command palette, settings, status and error views.
CASES.extend((case['input'], case['expected']) for case in json.loads(
    (ROOT / 'tests/data/binary-ui-candidates.json').read_text())['cases'])

SWIFT_RUNNER = r'''
let inputs = try JSONSerialization.jsonObject(with: FileHandle.standardInput.readDataToEndOfFile()) as! [String]
let outputs = inputs.map { value -> [String] in
  let result = translate(value)
  return [result, translate(result)]
}
FileHandle.standardOutput.write(try JSONSerialization.data(withJSONObject: outputs, options: [.fragmentsAllowed]))
'''
OBJC_RUNNER = r'''
int main(void) { @autoreleasepool {
  NSArray *inputs = [NSJSONSerialization JSONObjectWithData:[[NSFileHandle fileHandleWithStandardInput] readDataToEndOfFile] options:0 error:NULL];
  NSMutableArray *outputs = [NSMutableArray array];
  for (NSString *value in inputs) { NSString *result = RXTranslate(value); [outputs addObject:@[result, RXTranslate(result)]]; }
  NSData *data = [NSJSONSerialization dataWithJSONObject:outputs options:0 error:NULL];
  [[NSFileHandle fileHandleWithStandardOutput] writeData:data];
} return 0; }
'''

def run():
    resources = json.loads(subprocess.check_output([
        'plutil', '-convert', 'json', '-o', '-',
        str(ROOT / 'Resources/zh_CN.lproj/Localizable.strings'),
    ]))
    # Resource translations are the published vocabulary. Exercise both the
    # source keys and already translated values through the production code.
    cases = list(resources.items()) + [(value, value) for value in resources.values()] + CASES
    swift = (ROOT / 'RexTextHook.swift').read_text()
    swift = swift[:swift.index('private typealias LocalizedStringKeyInit')]
    swift = swift.replace('import SwiftUI\n', '')
    objc = (ROOT / 'RexZh.m').read_text()
    start = objc.index('static NSString *RXTranslate(')
    end = objc.index('\nstatic CFStringRef (*RXOriginalCFBundleCopyLocalizedString)', start)
    objc = '#import <Foundation/Foundation.h>\n' + objc[start:end]
    with tempfile.TemporaryDirectory(prefix='rex-translator-tests-') as directory:
        tmp = Path(directory)
        (tmp / 'main.swift').write_text(swift + SWIFT_RUNNER)
        (tmp / 'main.m').write_text(objc + OBJC_RUNNER)
        subprocess.run(['swiftc', str(tmp / 'main.swift'), '-o', str(tmp / 'swift')], check=True)
        subprocess.run(['clang', '-fobjc-arc', '-fblocks', str(tmp / 'main.m'), '-framework', 'Foundation', '-o', str(tmp / 'objc')], check=True)
        payload = json.dumps([value for value, _ in cases], ensure_ascii=False).encode()
        outputs = {}
        for backend in ['swift', 'objc']:
            outputs[backend] = json.loads(subprocess.check_output([str(tmp / backend)], input=payload))
        failures = []
        for index, (value, expected) in enumerate(cases):
            for backend, rows in outputs.items():
                actual, repeated = rows[index]
                if actual != expected:
                    failures.append(f'{backend}: {value!r}\n  expected {expected!r}\n  actual   {actual!r}')
                if repeated != actual:
                    failures.append(f'{backend}: not idempotent {value!r}: {actual!r} -> {repeated!r}')
            if outputs['swift'][index][0] != outputs['objc'][index][0]:
                failures.append(f'backend mismatch: {value!r}')
        print(f'{len(resources)} resource keys + {len(resources)} translated values + {len(CASES)} dynamic/boundary cases.')
        print(f'{len(cases)} cases x 2 production translators; expected output, parity and repeat stability checked.')
        if failures:
            print('\n'.join(failures))
            return 1
        print('PASS')
        return 0

if __name__ == '__main__':
    sys.exit(run())
