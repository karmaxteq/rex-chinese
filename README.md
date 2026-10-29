# Rex Beta 简体中文补丁

适用于 **macOS Rex Beta 0.1.0 (1408)**。本项目开源翻译资源、注入代码及补丁工具，不分发原版 Rex 应用。当前已经实测部分页面；尚未证明全部界面和异常流程都已汉化，具体范围见 [COVERAGE.md](COVERAGE.md)。

安装脚本从用户已有原版生成 `~/Applications/Rex Beta 中文版.app`，保留 `/Applications/Rex Beta.app`。中文版采用独立标识 `com.superlogical.rex.chinese`，启动器加载 `libRexChinese.dylib` 和 `libRexTextHook.dylib`，分别处理 AppKit/辅助功能及 SwiftUI 文本，并安装中文资源。

## 安装、启动与卸载

需要 macOS、Xcode Command Line Tools，以及 Python 3（补丁与测试仅使用标准库）。从项目目录执行：

```sh
./build.sh
./patch.sh "/Applications/Rex Beta.app"
open -n "$HOME/Applications/Rex Beta 中文版.app"
```

`build.sh` 从源码生成 arm64/x86_64 通用启动器和动态库。`patch.sh` 校验版本与构建号、只读验证原版预览常量，再复制应用、安装当前 `bin/` 构建并签名；它不会自动编译源码。修改源码或资源后，应重新执行上述构建、安装步骤，并先正常退出旧中文版进程再启动。

补丁副本使用本机临时签名，不具有上游开发者签名或公证身份，当前用途是本机测试。应用更新到其他构建后需重新适配，脚本会拒绝非 0.1.0 (1408) 版本。

本机桌面已提供“Rex Beta 中文版.app”入口，指向上述安装副本。如果仍看到英文，先确认打开的是带“中文版”的副本。直接打开 `/Applications/Rex Beta.app` 会启动原版。终端真实命令输出、路径、主机名和用户会话名保留原文，不属于界面翻译失败。

可检查运行路径、签名及实际加载的动态库：

```sh
pgrep -fl 'Rex Beta 中文版.app/Contents/MacOS'
codesign --verify --deep --strict "$HOME/Applications/Rex Beta 中文版.app"
# 将下面的 PID 换成上一步读到的 RexCore 进程号：
vmmap PID | rg 'libRexChinese|libRexTextHook'
```

卸载只把中文版应用副本移入废纸篓：

```sh
./uninstall.sh
```

## 当前验证结果

2026-10-29 从当前源码构建、安装并退出旧进程后，已通过普通 `open -n` 冷启动正式中文版；运行进程实际加载两份补丁动态库，深度签名校验通过，原版可执行文件 SHA-256 前后相同。

本轮逐页查看了服务器、界面、主题、终端、快捷键、集成、通知、远程主机、开发者九个设置页的首屏截图，并向下滚动核验终端设置。截图证明其可见范围，不能证明全部弹层和异常流程。具体证据见 [覆盖记录](COVERAGE.md)。

本轮修复了通知位置说明和两个终端内置 GPU 示例的可见英文。通知六个位置逐项切换后均显示中文，随后恢复右下角；选择示例的分支名高亮也已截图核验。远程主机当前列表为空，尚未配置 用户指定的 SSH 主机。

终端字体设置的固定 GPU 示例已在实际截图中显示“警告”“已弃用”“构建完成！”和“秒”。它通过精确等长修改安装副本中的两个完整示例常量完成，保留原字体、粗斜体及 ANSI/GPU 渲染；该预览的固定覆盖层已移除。这项修改不处理用户终端输出。

## 回归与证据

```sh
python3 tests/translation-regressions.py
python3 tests/preview-patch.py
plutil -lint Resources/zh_CN.lproj/Localizable.strings
git diff --check
```

翻译回归直接编译调用两个生产函数：114 个用例检查结果、Swift/ObjC 一致性和重复稳定性。预览补丁有 14 组结构与 CLI 测试；原版只读 dry-run 确认 x86_64、arm64 各有两个精确样本。这些检查不能替代实际界面测试。

本地 `.artifacts/` 保存截图、AX 读回、构建及安装日志；其中可能包含主机名和用户配置，已被 Git 忽略，不作为公开仓库内容。请勿把字典键数当作覆盖率。真实 Tailscale 登录、更新安装、生产服务器重启/停止及全部异常路径尚未执行；Cursor SSH 用户指定的 SSH 主机 的同步结果也未核验。

补丁自身采用 [MIT 许可](LICENSE)；Rex 原应用及第三方组件不在本项目的授权或分发范围内。
