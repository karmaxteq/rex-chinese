# Rex Beta 简体中文补丁

适用于 Rex Beta 0.1.0（macOS）。补丁将应用复制到 `~/Applications/Rex Beta 中文版.app`，不会覆盖原应用；可用 `uninstall.sh` 删除补丁副本。

补丁同时使用本地化资源和运行时翻译钩子：资源键由 `Localizable.strings` 覆盖，AppKit 控件、菜单和 SwiftUI 辅助功能文本由注入的动态库处理。Rex 的部分 SwiftUI 自绘文本不经过这些接口，因此当前版本只承诺已验证的部分视觉覆盖。原应用不会被覆盖。

## 使用

```sh
./patch.sh "/Applications/Rex Beta.app"
open "$HOME/Applications/Rex Beta 中文版.app"
```

补丁副本会使用本机临时签名，因此仅建议在本机测试；原应用保持不变，可随时删除副本恢复。

## 实测覆盖（Rex Beta 0.1.0）

2026-10-27 在 macOS 上启动补丁副本，并逐页用截图和 Accessibility 树复核。测试入口是
`~/Applications/Rex Beta 中文版.app`；`/Applications/Rex Beta.app` 保持未修改。

已确认的视觉覆盖：

- 主工作区的会话、活动、新建标签页、分栏、移动窗格、缩放和关闭窗格等固定文案。
- 文件、编辑、显示、窗口、帮助及 Rex Beta 应用菜单；窗口菜单的“进入全屏”、诊断和复制信息等项目也已覆盖。
- 设置侧栏和九个页面：服务器、界面、主题、终端、快捷键、集成、通知、远程主机、开发者。
- 终端页下半部分的内边距、选择、链接、集成路径浏览器、标题和大部分说明。
- 快捷键页的固定项目、深层会话/主机/标签页项目及辅助功能树中的动态“修改/录制快捷键”描述。
- 命令面板的搜索占位符、默认列表、底部“更改快捷键/操作”按钮，以及已实测的 `tab` 和 `settings` 筛选列表。

截图中仍能看到的英文或技术原文：

- 命令面板中未列入补丁静态命令表的新增或动态项目，以及用户会话名、主机名等动态内容。
- 服务器页的 `Tailscale`、`Access Rex securely from your other devices.`。
- 界面页应用图标选项中的 `Dynamic`；`Shell` 等技术名称。
- 主题页内置主题的品牌名，例如 `Merino`、`Alpine`、`Buttercream Diner`；其中文后缀已翻译。
- 终端页的字体名 `Menlo`、`Choose...`、`Display P3`、`Option`、`Shell`、占位符 `Default login shell`、`ssh://` 和终端示例输出。
- 快捷键筛选框占位符 `Filter Shortcuts...`，快捷键列表的部分自绘动态值，以及 `Command`、`Control` 等系统按键名称。
- 通知页的 `Displayed bottom right` 和 `Dock Badge and Sound` 组合说明。

这些残留文字来自 Rex 的 SwiftUI/SDF 自定义绘制、系统控件或品牌/用户内容。Accessibility 树中的对应说明可能已经是中文，但这不代表屏幕像素已替换；因此当前版本应称为“高覆盖的部分视觉汉化”，不能声称所有屏幕文字均已汉化。

## 测试入口

本次回归测试使用的是 `~/Applications/Rex Beta 中文版.app`，并确认两个注入库已加载：
`Contents/Frameworks/libRexChinese.dylib` 和 `Contents/Frameworks/libRexTextHook.dylib`。
`/Applications/Rex Beta.app` 是原应用，补丁不会修改它；打开原应用时不会看到中文覆盖。
