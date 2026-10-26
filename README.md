# Rex Beta 简体中文补丁

适用于 Rex Beta 0.1.0（macOS）。补丁将应用复制到 `~/Applications/Rex Beta 中文版.app`，不会覆盖原应用；可用 `uninstall.sh` 删除补丁副本。

补丁同时使用本地化资源和运行时翻译钩子：资源键由 `Localizable.strings` 覆盖，AppKit 控件、菜单和 SwiftUI 辅助功能文本由注入的动态库处理。Rex 的 SwiftUI SDF 绘制文本不经过这些接口，因此当前版本只承诺已验证的部分视觉覆盖。原应用不会被覆盖。

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

- 主工作区的会话、命令面板、活动、新建标签页、分栏、移动窗格、缩放和关闭窗格等固定文案。
- 文件、编辑、显示、窗口、帮助及 Rex Beta 应用菜单；窗口菜单的“进入全屏”、诊断和复制信息等项目也已覆盖。
- 设置侧栏和九个页面：服务器、界面、主题、终端、快捷键、集成、通知、远程主机、开发者。
- 终端页下半部分的内边距、选择、链接、集成路径浏览器、标题和大部分说明。
- 快捷键页的固定项目、深层会话/主机/标签页项目及动态“修改/录制快捷键”描述。

截图中仍能看到的英文或技术原文：

- 服务器页的 `Tailscale`、`Access Rex securely from your other devices.`。
- 界面页应用图标选项中的 `Dynamic`；`Shell` 等技术名称。
- 主题页内置主题的品牌名，例如 `Merino`、`Alpine`、`Buttercream Diner`；其中文后缀已翻译。
- 终端页的字体名 `Menlo`、`Choose...`、`Display P3`、`Option`、`Shell`、占位符 `Default login shell`、`ssh://` 和终端示例输出。
- 快捷键筛选框占位符 `Filter Shortcuts...`，以及快捷键值中的 `Command`、`Control` 等系统按键名称。
- 通知页的 `Displayed bottom right` 和 `Dock Badge and Sound` 组合说明。

这些残留文字来自 Rex 的 SwiftUI/SDF 自定义绘制、系统控件或品牌/用户内容。Accessibility 树中的对应说明可能已经是中文，但这不代表屏幕像素已替换；因此当前版本应称为“高覆盖的部分视觉汉化”，不能声称所有屏幕文字均已汉化。
