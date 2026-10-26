# Rex Beta 简体中文补丁

适用于 Rex Beta 0.1.0（macOS）。补丁将应用复制到 `~/Applications/Rex Beta 中文版.app`，不会覆盖原应用；可用 `uninstall.sh` 删除补丁副本。

补丁同时使用本地化资源和运行时翻译钩子：资源键由 `Localizable.strings` 覆盖，未暴露本地化键的 AppKit/SwiftUI 辅助文本由注入的动态库处理。原应用不会被覆盖。

## 使用

```sh
./patch.sh "/Applications/Rex Beta.app"
open "$HOME/Applications/Rex Beta 中文版.app"
```

补丁副本会使用本机临时签名，因此仅建议在本机测试；原应用保持不变，可随时删除副本恢复。

## 实测覆盖（Rex Beta 0.1.0）

2026-10-26 在 macOS 上启动补丁副本，并通过 Accessibility 树逐页检查。测试入口是
`~/Applications/Rex Beta 中文版.app`；`/Applications/Rex Beta.app` 保持未修改。

- 主工作区：切换会话、命令面板、活动、新建标签页、分栏布局、移动窗格、向右/向下分栏、缩放窗格、关闭窗格、终端、隐藏侧边栏等已显示为简体中文。
- 设置侧栏：服务器、界面、主题、终端、快捷键、集成、通知、远程主机、开发者已覆盖。
- 设置内容：服务器页、界面页、主题页、终端页、快捷键页、集成页、通知页的标题、说明、按钮、帮助文本已覆盖；快捷键页的动态描述也会翻译。
- 更新提示：`Rex Beta is up to date` 已覆盖。
- 系统菜单的顶层名称已覆盖；菜单项仍有未覆盖项，见下方清单。

仍可见的英文来自系统菜单或 SwiftUI 生成的动态值：

- 应用菜单中的 `Check for Updates...`；文件、编辑、显示、窗口、帮助菜单中的部分命令项（例如 `New Window`、`Find`、`Split Left`、`Rex Help`）。
- 界面页的动态值 `Always`、`Default`、`Surface & Content`、`Dock and menu bar`，以及选项描述 `Above`、`Left Side`、`Right Side`、`Comfortable`、`Compact`。
- 终端页的动态值 `Regular`、`Block`、`Normal`、`Automatic (by keyboard layout)`、`Extend`、`Theme`、`Ask First`，以及启动命令占位符 `Default login shell`。
- 主题页内置主题名称（如 `Merino Light`、`Alpine Milk`）和终端输出、用户会话名、主机名。这些属于品牌或用户内容，当前补丁保留原文。
