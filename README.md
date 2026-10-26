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

2026-10-26 在 macOS 上启动补丁副本，并通过 Accessibility 树逐页检查：

- 主工作区：切换会话、命令面板、活动、新建标签页、分栏布局、移动窗格、向右/向下分栏、缩放窗格、关闭窗格、终端、隐藏侧边栏等已显示为简体中文。
- 设置侧栏：服务器、界面、主题、终端、快捷键、集成、通知、远程主机、开发者已覆盖。
- 设置内容：服务器页、界面页、主题页、终端页、快捷键页、集成页、通知页的标题、说明、按钮、帮助文本已覆盖；快捷键页的动态描述也会翻译。
- 更新提示：`Rex Beta is up to date` 已覆盖。
- 系统菜单：文件、编辑、显示、窗口、帮助、服务设置、隐藏/退出等已覆盖。

仍可见的英文是系统或第三方运行时生成的少数文本：主菜单中的 `Check for Updates...`、服务器页的动态运行时长前缀 `Rex Server Running for`、部分 SwiftUI 选择器的当前值（例如 `Always`、`Default`、`Dock and menu bar`）以及主题名称。这些不是资源键，当前补丁没有修改终端输出、主题品牌名或用户自己的会话/主机名称。
