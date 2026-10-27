# Rex Beta 简体中文补丁

适用于 Rex Beta 0.1.0（macOS）。补丁把原应用复制到
`~/Applications/Rex Beta 中文版.app`，不会修改 `/Applications/Rex Beta.app`。

补丁由三层组成：`zh_CN.lproj/Localizable.strings` 覆盖资源翻译，
`libRexChinese.dylib` 翻译 AppKit/SwiftUI 辅助功能、菜单、控件和动态文本，
`libRexTextHook.dylib` 翻译 SwiftUI 自绘文本。应用通过 `RexLauncher` 启动，
自动设置简体中文环境并加载两个动态库。

## 安装和启动

```sh
./patch.sh "/Applications/Rex Beta.app"
open "$HOME/Applications/Rex Beta 中文版.app"
```

如果仍看到全英文，请确认打开的是上面的 `~/Applications/...` 副本；直接打开
`/Applications/Rex Beta.app` 是原版，不会加载补丁。也可以先退出两个 Rex 进程，
再用上述 `open` 命令启动副本。

卸载补丁副本：

```sh
./uninstall.sh
```

## 当前实测覆盖

2026-10-28 在 macOS 上对补丁副本做了像素截图和 Accessibility 树回归，确认补丁副本退出后重新启动仍会加载两个动态库，并确认：

- 主工作区：会话、活动、新建标签页、分栏、移动窗格、缩放和关闭窗格。
- 应用菜单及文件、编辑、显示、窗口、帮助菜单；窗口菜单中的“向左移动标签页”和“向右移动标签页”也已覆盖。
- “关于 Rex Beta”面板的标题和版本行；视觉显示为“Rex Beta / 版本 0.1.0 (1408)”，Accessibility 树显示为“Rex Beta 版本 0.1.0 (1408)”。
- 命令面板的空列表、`tab` 筛选结果和动态绘制的命令行；终端字体选择器的搜索框、字体筛选和字体列表。
- 设置侧栏和 9 个页面：服务器、界面、主题、终端、快捷键、集成、通知、远程主机、开发者。
- 终端页的预览、选项、说明、选择、链接、集成路径浏览器、标题和启动命令；`Default login shell` 的屏幕占位符已覆盖为“默认登录 Shell”。
- 快捷键页的筛选框、固定项目、动态“修改/录制快捷键”描述，以及“在网页上打开会话”“切换主机”“移除主机”等动态项目。
- 通知页位置说明、状态组合说明和命令面板的搜索占位符、默认列表及 `tab` 筛选列表。
- 远程主机页的连接状态、连接警告、失败详情、错误标题、错误正文和“重试”按钮。
- 已回归检查设置页快速切换：通知页的视觉覆盖会在离开页面时立即移除，不会残留到远程主机或其他详情页。

本轮重新启动后的进程还确认加载了：

```text
~/Applications/Rex Beta 中文版.app/Contents/Frameworks/libRexChinese.dylib
~/Applications/Rex Beta 中文版.app/Contents/Frameworks/libRexTextHook.dylib
```

本轮回归还确认窗口菜单中的两个原始英文项已显示为“向左移动标签页”和“向右移动标签页”，命令面板的 `tab` 筛选项和字体选择器的“搜索字体 / 等宽字体 / 所有字体”均显示为简体中文；主题编辑器、快捷键“配置”菜单、开发者“更新频道”菜单和 Rex 安装位置菜单也已实际打开并核验为中文。

本轮还重新构建了 `libRexChinese.dylib` 的 `arm64` / `x86_64` 二进制，并验证设置窗口、关于面板和定时辅助功能刷新在重启后仍可用。动态映射 `Download Update` → `下载更新` 已写入资源和运行时；当前没有可用更新，因此没有执行真实下载。

仍存在的边界：设置窗口工具栏的两个图标按钮在 Accessibility 树中仍返回 `Back` 和 `Forward`；它们只有左右箭头图标，没有可见英文。Tailscale 真实登录/失败和服务器重启后的动态状态没有在本轮执行。用户创建的会话名、主机名、终端真实输出和运行时生成的 URL/路径属于用户数据或技术标识，按原文保留。

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
