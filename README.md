# Rex Beta 简体中文补丁

适用于 Rex Beta 0.1.0（macOS）。补丁把原应用复制到
`~/Applications/Rex Beta 中文版.app`，不会修改 `/Applications/Rex Beta.app`。

补丁由三层组成：`zh_CN.lproj/Localizable.strings` 覆盖资源翻译，
`libRexChinese.dylib` 翻译 AppKit/SwiftUI 辅助功能、菜单、控件和动态文本，
`libRexTextHook.dylib` 翻译 SwiftUI 自绘文本。应用通过 `RexLauncher` 启动，
自动设置简体中文环境并加载两个动态库。补丁副本使用独立的
`com.superlogical.rex.chinese` bundle 标识，避免 Dock、Cursor 或 LaunchServices
把它误路由回未修改的原版。

## 安装和启动

```sh
./build.sh
./patch.sh "/Applications/Rex Beta.app"
open "$HOME/Applications/Rex Beta 中文版.app"
```

修改 `RexTextHook.swift`、`RexZh.m` 或资源翻译后，先运行 `./build.sh`；它会重新生成
`arm64`/`x86_64` universal 动态库并同步到 `bin/`，然后再运行 `./patch.sh`。`patch.sh`
只负责从原版复制并安装 `bin/` 中的当前构建，不会自动编译源码。

如果仍看到全英文，请确认打开的是上面的 `~/Applications/...` 副本；直接打开
`/Applications/Rex Beta.app` 是原版，不会加载补丁。也可以先退出两个 Rex 进程，
再用上述 `open` 命令启动副本。

快速确认当前打开的是补丁副本：

```sh
pgrep -af 'Rex Beta 中文版.app/Contents/MacOS/Rex'
```

输出中必须包含 `~/Applications/Rex Beta 中文版.app`。如果看到的是
`/Applications/Rex Beta.app`，请先退出原版，再重新运行上面的 `open` 命令。

补丁副本的 bundle 标识是 `com.superlogical.rex.chinese`；可以用下面的命令读取副本
自身的 plist，确认没有仍使用原版的 bundle 标识：

```sh
plutil -p "$HOME/Applications/Rex Beta 中文版.app/Contents/Info.plist" \
  | rg CFBundleIdentifier
```

主工作区里的终端内容（例如 `Last login`、Shell 提示符、命令输出）来自系统
Shell 或用户会话，补丁不会改写这些运行数据。要直接查看中文覆盖，请从菜单栏
打开“Rex Beta → 设置…”，或展开“文件”菜单；服务器、界面、主题、终端、快捷键、
集成、通知、远程主机和开发者页面的控件均在这里显示。

卸载补丁副本：

```sh
./uninstall.sh
```

## 当前实测覆盖

2026-10-29 在 macOS 上对补丁副本做了冷启动、像素截图和 Accessibility 树回归，确认补丁副本退出后重新启动仍会加载两个动态库，并确认：

当前工作树映射规模为：资源文件 1,343 条（键去重 1,337 条）、Swift 文本映射 1,555 条、AppKit 文本映射 1,572 条，三处合并去重后 1,701 个字面量键。这是补丁字典规模，不是应用全部文本的百分比；实际运行覆盖以 [COVERAGE.md](COVERAGE.md) 的“已实测覆盖”和“未执行路径”为准。

本轮还专门复测了终端设置“闪烁速度 → 自定义”：此前仍可见的 `Blink interval in milliseconds`
已修复，输入框和步进器现在都显示“闪烁间隔（毫秒）”。如果启动后仍看到整套英文，请检查进程
路径；必须启动 `~/Applications/Rex Beta 中文版.app`，直接启动 `/Applications/Rex Beta.app`
仍然是原版。

- 主工作区：会话、活动、新建标签页、分栏、移动窗格、缩放和关闭窗格。
- 活动面板：空活动状态、侧边栏标签页、筛选主机按钮、`All hosts` 菜单项和筛选框占位符均为中文；本轮补齐了 `Filter` 与 `All hosts`。
- 会话切换面板：新建会话、主机分组、断开连接状态、会话筛选和“筛选或创建…”均为中文。
- 插入路径入口：菜单标题、路径输入框和占位符均为中文；原生 macOS 文件选择器的目录行仍由系统 AX provider 返回 `folder` 角色文本，属于系统面板边界。
- 应用菜单及文件、编辑、显示、窗口、帮助菜单；窗口菜单中的“向左移动标签页”和“向右移动标签页”也已覆盖。
- “关于 Rex Beta”面板的标题和版本行；视觉显示为“Rex Beta / 版本 0.1.0 (1408)”，Accessibility 树显示为“Rex Beta 版本 0.1.0 (1408)”。
- 命令面板的空列表、`tab` 筛选结果和动态绘制的命令行；终端字体选择器的搜索框、字体筛选和字体列表。
- 设置侧栏和 9 个页面：服务器、界面、主题、终端、快捷键、集成、通知、远程主机、开发者。
- 终端页的预览、选项、说明、选择、链接、集成路径浏览器、标题和启动命令；`Default login shell` 的屏幕占位符已覆盖为“默认登录 Shell”。
- 快捷键页的筛选框、固定项目、动态“修改/录制快捷键”描述，以及“在网页上打开会话”“切换主机”“移除主机”等动态项目。
- 通知页位置说明、状态组合说明和命令面板的搜索占位符、默认列表及 `tab` 筛选列表；运行中、已阻塞、错误、已完成四个状态页及声音选项菜单也已逐项读回中文。
- 远程主机页的连接状态、连接警告、失败详情、错误标题、错误正文和“重试”按钮。
- 通知设置的“运行中”“已阻塞”“错误”“已完成”四个状态页，以及“提醒/警告/错误/成功/就绪/加载中/点击”声音菜单；界面设置的标签页图标颜色、Shell 图标主题、窗格淡化和程序坞/菜单栏显示菜单均已在冷启动进程中逐项读回中文。
- 远程主机失败弹层的可见标题和正文；动态刷新周期为 0.2 秒，重建副本后首个可见错误弹层也已显示中文。主机名、URL 等用户数据保持原文并嵌入中文句子。
- 无效主题导入流程：实际选取无效主题文件后，错误标题、缺失颜色列表和确认按钮均为中文（“无法导入主题 / 主题缺少有效颜色：… / 好”）。
- 停止服务器确认框：风险说明和“取消/停止”按钮均为中文；测试只打开并取消，没有停止服务器。
- 已回归检查设置页快速切换：通知页的视觉覆盖会在离开页面时立即移除，不会残留到远程主机或其他详情页。
- 快捷键录制按钮已实际验证：进入录制态显示“停止录制 / 停止录制。”，退出后恢复“录制 切换全屏的快捷键”。

本轮重新启动后的进程还确认加载了：

```text
~/Applications/Rex Beta 中文版.app/Contents/Frameworks/libRexChinese.dylib
~/Applications/Rex Beta 中文版.app/Contents/Frameworks/libRexTextHook.dylib
```

最近一次从源码重建后，已完全退出旧进程并重新启动副本复测；主工作区截图、应用菜单、命令面板和 9 个设置页均为简体中文。设置工具栏的两个 AX 描述也已从 `Back` / `Forward` 修复为“返回”/“前进”。终端中的登录提示、路径、主机名和命令属于真实运行数据，仍按原文显示。

本轮回归还确认窗口菜单中的两个原始英文项已显示为“向左移动标签页”和“向右移动标签页”，命令面板的 `tab` 筛选项和字体选择器的“搜索字体 / 等宽字体 / 所有字体”均显示为简体中文；主题编辑器、快捷键“配置”菜单、开发者“更新频道”菜单和 Rex 安装位置菜单也已实际打开并核验为中文。

本轮还重新构建了 `libRexChinese.dylib` 和 `libRexTextHook.dylib` 的 `arm64` / `x86_64` 二进制，并验证设置窗口、关于面板、活动面板和定时辅助功能刷新在重启后仍可用。动态映射 `Download Update` → `下载更新` 已写入资源和运行时；本轮检查更新时看到了中文的“有可用更新 / 下载”通知，但没有执行真实下载。

本轮还测试了“窗口 → 复制版本信息”和“窗口 → 复制调试信息”。通知的可见文本和 Accessibility 描述均为中文，版本号、提交号等技术载荷按原文保留。

2026-10-29 冷启动对照确认：`~/Applications/Rex Beta 中文版.app` 的主工作区、菜单、命令面板、设置搜索无匹配页、Tailscale 登录表单、服务器详情、停止确认框、远程主机添加/失败流程和九个设置页读回中文；直接打开 `/Applications/Rex Beta.app` 仍读回 `Tabs`、`Change Session`、`Command Palette` 等英文。请确认启动的是带“中文版”的副本路径。

当前工作树的最新现场复测还确认：服务器详情显示“服务器版本 … / API 版本 修订版 7”；设置搜索框右侧的 Accessibility 清除按钮已从 `Dismiss editing` 覆盖为“结束编辑”；Tailscale 登录表单、停止服务器确认框和远程主机连接失败弹层均已打开并读回中文，测试过程中没有提交登录、重试连接或停止服务器。

本轮继续测试了无效主题导入。旧版正文 `The theme is missing valid colors for...` 已覆盖为“主题缺少有效颜色：背景色、前景色、调色板 0…15”，弹窗确认按钮 `OK` 也覆盖为“好”。

当前已测试的 Rex 可见 UI 和 Accessibility 路径没有发现英文残留；设置工具栏的 AX 描述已验证为“返回”/“前进”。Tailscale 真实登录/失败和服务器重启后的动态状态没有执行，本轮只打开并取消了登录表单和停止确认框。用户创建的会话名、主机名、终端真实输出和运行时生成的 URL/路径属于用户数据或技术标识，按原文保留。

本轮最终冷启动复测还扫描了九个设置页的 Accessibility 树，并发现活动面板的主机筛选菜单中遗漏了 `All hosts`；该项已补为“所有主机”，并重新编译、签名和冷启动验证。命令面板入口和搜索框显示为中文；当前 CUA 树对弹出的动态结果列表只暴露搜索框，因此动态命令结果仍按此前已验证的路径记录。

macOS 原生文件选择器内部的系统 AX provider 可能仍返回 `Search` 等系统标签；选择器的可见“打开/取消/新建文件夹”按钮已中文化。这属于系统面板边界，Rex 自绘和 Rex 设置页面不受影响。

项目中的异常流程映射（例如主题导入失败、服务器兼容性错误、Tailscale 登录生命周期和工作区失败提示）已写入资源、SwiftUI 和 AppKit 三条路径，但没有逐一触发；它们属于静态覆盖，不能当作已经完成的运行时回归。

验证时确认补丁进程实际加载了：

```text
~/Applications/Rex Beta 中文版.app/Contents/Frameworks/libRexChinese.dylib
~/Applications/Rex Beta 中文版.app/Contents/Frameworks/libRexTextHook.dylib
```

## 有意保留的原文

品牌名和技术标识（例如 Rex、Tailscale、Shell、Menlo、Display P3、Option、
`ssh://`）保留原文；终端真实输出、用户创建的会话名、主机名和命令也不会被改写。
主题卡片的英文品牌名已在屏幕标题下提供中文名称，但无损保留主题本身的标识。

## 验证命令

```sh
codesign --verify --deep --strict "$HOME/Applications/Rex Beta 中文版.app"
lipo -info bin/libRexChinese.dylib
git diff --check
```

补丁使用本机临时签名，仅适合本机测试；原应用保持不变。
