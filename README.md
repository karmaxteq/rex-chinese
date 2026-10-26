# Rex Beta 简体中文补丁

适用于 Rex Beta 0.1.0（macOS）。补丁将应用复制到 `~/Applications/Rex Beta 中文版.app`，不会覆盖原应用；可用 `uninstall.sh` 删除补丁副本。

这是资源层补丁：只覆盖能通过 Apple 本地化资源读取的固定界面文本。终端输出、动态内容和未暴露本地化键的 SwiftUI 文本不会被修改。

## 使用

```sh
./patch.sh "/Applications/Rex Beta.app"
open "$HOME/Applications/Rex Beta 中文版.app"
```

补丁副本会失去原始代码签名，因此仅建议在本机测试；原应用保持不变，可随时删除副本恢复。
