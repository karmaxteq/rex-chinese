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

`build.sh` 从源码生成 arm64/x86_64 通用启动器和动态库。`patch.sh` 校验版本与构建号、只读验证原版的三个固定界面常量和精确搜索调用点，再复制应用、安装当前 `bin/` 构建并签名；它不会自动编译源码。修改源码或资源后，应重新执行上述构建、安装步骤，并先正常退出旧中文版进程再启动。

安装脚本还会刷新 LaunchServices 注册并请求 Spotlight 重新索引该副本，避免复制后残留原版的 bundle 标识；Spotlight 索引为异步过程。

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

### 正式副本的可见覆盖（2026-10-30）

我在正式中文版进程 `76842` 上重新读取并截图了九个设置页首屏：服务器、界面、主题、终端、快捷键、集成、通知、远程主机和开发者。可见文案均为中文；`Tailscale`、`Shell`、`Menlo`、`Display P3`、协议、主题品牌名和智能体名称等技术标识保留原文。AX 唯一文本统计和截图文件名见 [COVERAGE.md](COVERAGE.md) 的“正式中文版现场复测”小节。

这组证据只覆盖当前首屏。滚动区、扩展调色板、颜色弹窗、全部菜单、命令动作、异常流程、真实 Tailscale 授权、跨机器连接和更新安装仍分别按证据记录或保持未验证。当前正式副本加载的是已安装旧库；工作区新构建尚未安装，不能把源码测试结果当成正式副本画面。

本轮在临时候选中逐一查看九个设置页首屏、主题编辑器和扩展调色板，并将命令面板滚动到最底部。实际找到主题、配色方案和带更新频道的状态漏译；补齐精确词条、重新构建并冷启动后，同一面板实际显示“更改主题”“自动/浅色/深色配色方案”“可以检查更新 · 预览”。英文查询 `Change Theme` 保持原样，真实结果为中文；未保存主题或改变配色。

正式中文版确实已加载汉化补丁，桌面入口、独立标识和签名均正确，但仍使用 8717334/1e6120e 的库。**2faf604 的颜色/完整消息修复及本轮命令修复尚未安装到正式副本。** CUA 不能准确选中正式中文版；候选通过临时使用原版标识恢复测试，其截图不代表正式副本的当前画面。两候选已正常退出，正式客户端、生产服务和终端草稿保留，详见 [COVERAGE.md](COVERAGE.md)。

最新源码另补齐 sRGB 帮助、Tailscale 账户/地址说明、服务器支持版本和首次迁移完整提示，保留插入值与 `rex skill show`。3,414 × 2 翻译回归、90 项绘制检查、80 项输入保真检查及双架构构建通过；不代表这些消息的全部真实授权、版本或迁移流程已验证。

2026-10-30 已在正式中文版中逐页查看九个设置页首屏：服务器、界面、主题、终端、快捷键、集成、通知、远程主机、开发者。可见的设置文案为中文；品牌、字体名、主机名和用户输入保留原文。进程 70247 的九页再次截图查看，随后又实际查看界面/终端共 12 个原生下拉菜单，包括字体样式、光标、Option 键、选择颜色与链接策略；展开选项均为中文，原设置值已核对保持不变。“自定义”闪烁间隔也已展开查看并恢复。两补丁库实际加载，安装/构建双架构 UUID 一致，深度签名通过，原版可执行文件 SHA-256 不变。

其后直接 AX 工具遇到跨应用窗口识别异常；正常重启同一正式副本后，进程 76842 仍加载补丁且签名通过，但未把未完成的菜单滚动测试计为通过。原版对照也复现该 AX 现象，未据此修改生产 hook；诊断、截图范围和恢复记录见 [COVERAGE.md](COVERAGE.md)。

继续滚动实际找到并修复了 `Split Pane`、左/上/下分栏、`Focus Pane`、`Keys` 六处漏译。独立本机服务连接又找到 `Connected` 和终端进程状态 `Exited`，安装后已分别实际显示“已连接”和“已退出”；终端真实输出 `Filter Settings`、中文和表情保持原样。停止独立服务后，实际显示“无法连接”。测试主机已移除、本地会话恢复，原生产服务器未停止。

命令面板保留真实候选、原生选择与快捷键，沿用原生富文本绘制翻译。新搜索补丁仅在已验证标题调用点为临时搜索字段加入精确中文别名。正式副本中“字体、设置、标签页、光标”四个中文查询均有结果，英文 `font` 仍可搜索；中文搜索后实际进入字体子菜单、打开设置窗口，未更改字体。最初实测仍无结果，随后定位并修复了注入库顺序导致主模块识别失败的问题；失败与最终成功证据分别保留。本机连接不等于跨机器 SSH/Tailscale 验证；每组截图的实际查看范围见 [COVERAGE.md](COVERAGE.md)。

另修复了已安装 SwiftUI AX getter 时原文定位丢失的问题，生产 hook 组合回归由修复前 8 项失败变为 37 项全过；实际颜色弹层已显示“背景”“色相”“色度”“亮度”，测试主题取消未保存。通知的四种活动详情和七项声音菜单也已实际查看。

独立本机服务的真实断线测试又找到 `Reconnecting…` 和错误通知分片漏译：最初完整 AX 已是中文，画面仍有英文标题和正文。现按实际标题、完整正文边界补齐翻译；最终副本实际显示“正在重新连接…”、“操作失败”和完整中文正文，折叠/展开通知均已截图查看，主机名原样保留。没有泛化替换 `On `，并覆盖主机以组合字符开头的 Swift/ObjC 边界差异。测试服务和测试主机已清理，本地会话恢复；范围与失败记录见 [COVERAGE.md](COVERAGE.md)。

当前仍是部分实测覆盖，没有可靠的全量覆盖百分比。其余中文查询、全部子菜单/命令动作/异常流程、真实 Tailscale 授权和跨机器连接、更新安装、生产服务启停与全部外观组合尚未完成。此前终端 GPU 示例偶发空白的原因及长期 CPU/内存表现也仍未确定。搜索桥接在 arm64 实际执行；x86_64 已编译与静态核验，尚未实机运行。

## 回归与证据

```sh
python3 tests/translation-regressions.py
python3 tests/localized-message-hooks.py
python3 tests/translation-cache.py
python3 tests/palette-drawing.py
python3 tests/preview-patch.py
python3 tests/search-patch.py
python3 tests/search-bridge.py
python3 tests/hook-ownership.py
python3 tests/placeholder-storage.py
python3 tests/accessibility-walk.py
python3 tests/raw-ax-receiver.py
python3 tests/frame-abi.py
plutil -lint Resources/zh_CN.lproj/Localizable.strings
git diff --check
```

翻译回归直接编译调用两个生产函数，遍历 1,526 个发布资源键、对应译文及 362 个动态/用户文本边界用例，共 3,414 用例，检查预期结果、Swift/ObjC 一致性和重复稳定性。动态边界用例位于 `tests/translation-regressions.py` 和 `tests/data/dynamic-coverage.json`，包含完整错误消息、通知分片、插值内容保留及快捷键分片修复。此前发现的 116 个词表差异已统一。固定界面常量补丁有 17 组结构与 CLI 测试；原版只读 dry-run 确认 x86_64、arm64 各有三个精确样本。

`localized-message-hooks.py` 使用当前 `bin/` 正式库测试真实 Foundation 插值资源到原生 SwiftUI Text 的构造路径：21 个正例在未注入基线全部不匹配中文，注入后全部匹配；10 个保留负例与 135 次比较控制通过。中文期望调用原始构造器旁路翻译 hook，防止两侧同时翻译产生假通过。该测试在 arm64 执行，不代替 Rex 真实界面截图。

`palette-drawing.py` 直接加载完整生产库，90 项检查覆盖富文本 backing storage、字体/颜色/段落、绘制矩形及原生标记像素。旧列表重画版确实擦掉标记，当前版保留；测试不证明所有真实命令与动作均匹配。`raw-ax-receiver.py` 的 37 项覆盖 AppKit 类型边界以及已安装生产 SwiftUI getter 的 NSObject/继承节点，保留原始文本与颜色/保存帧，避免对不兼容 receiver 调用原生 IMP。

`translation-cache.py` 的 24 项断言与 16,000 次并发迭代检查动态命中、未命中缓存、递归、可变输入快照、长文本绕过、主动清空后重算及容量配置。旧实现原生运行后有 10 项预期失败；该测试不证明真实应用的性能。

`hook-ownership.py` 对照本机 SDK 的 SIL 检查 Swift 输入所有权，并保留、比较、销毁七条构造路径及一条字面量插值路径各 10,000 个值；另以完整生产库在独立测试进程验证 10,000 个插值键，包含字符串和数字负对照。复杂键首次原生 equality 存在 SDK 差异，生命周期测试以完整原生反射值辅助比较，反射仅用于测试。该测试捕获了原补丁的重复释放缺陷；修复后，正式中文版的颜色选择器已完成 10 次开关测试。这些测试不能代替真实界面或证明全部系统/架构兼容性。

`placeholder-storage.py` 的 80 项原生存储检查验证四条占位写入路径、样式保留与用户输入不被翻译，旧源对照有 31 项失败。`accessibility-walk.py` 的 71 项检查验证遍历次数、现代 AX 独有节点、精确 frame、深度限制和补丁视图排除；旧源对照确实捕获了重复扫描。它们均使用生产源码，无第三方依赖。

`frame-abi.py` 对照原生 SDK 检查两个架构的 LLVM，验证读取 `NSRect` 时由编译器选择正确的消息调用。它捕获了旧代码在 x86_64 中直接调用 `objc_msgSend` 的结构体返回缺陷；不代替 Intel Mac 实机测试。

本地 `.artifacts/` 保存截图、AX 读回、构建及安装日志；其中可能包含主机名和用户配置，已被 Git 忽略，不作为公开仓库内容。请勿把字典键数当作覆盖率。最终副本的 CPU 开销仍偏高，具体样本见覆盖记录，性能未视为全面解决。真实 Tailscale 登录、更新安装、生产服务器重启/停止及全部异常路径尚未执行；项目可同步到 SSH 工作区供 Cursor 编辑；Linux 工作区中的源码副本不表示能够运行此 macOS 补丁，也不表示 Rex 远程服务已经配置。

补丁自身采用 [MIT 许可](LICENSE)；Rex 原应用及第三方组件不在本项目的授权或分发范围内。
