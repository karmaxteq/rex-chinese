# Rex Beta 简体中文补丁

适用于 Rex Beta 0.1.0（macOS）。补丁将应用复制到 `~/Applications/Rex Beta 中文版.app`，不会覆盖原应用；可用 `uninstall.sh` 删除补丁副本。

这是资源层补丁：只覆盖能通过 Apple 本地化资源读取的固定界面文本。终端输出、动态内容和未暴露本地化键的 SwiftUI 文本不会被修改。

## 使用

```sh
./patch.sh "/Applications/Rex Beta.app"
open "$HOME/Applications/Rex Beta 中文版.app"
```

补丁副本会使用本机临时签名，因此仅建议在本机测试；原应用保持不变，可随时删除副本恢复。

## 实测覆盖（Rex Beta 0.1.0）

2026-10-26 在 macOS 上启动补丁副本后确认：

- 已生效：系统菜单中的“文件、编辑、显示、窗口、帮助”；设置侧栏中的“服务器、界面、主题、终端、快捷键、集成、通知、远程主机、开发者”；服务器页中的部分状态和操作文本。
- 未生效：工作区主界面的 `Change Session`、`Command Palette`、`Activity`、`New Tab`、`Split Right`、`Split Down`、`Zoom Pane`、`Close Pane` 等文本，以及部分设置页说明文本。

原因是这些文本不是通过本地 `Localizable.strings` 键读取，或使用了不同的 SwiftUI 编译键。当前项目是资源覆盖补丁，不宣称完整汉化。
