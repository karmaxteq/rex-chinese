#!/bin/sh
set -eu
SRC=${1:-/Applications/Rex\ Beta.app}
DST="$HOME/Applications/Rex Beta 中文版.app"
[ -d "$SRC" ] || { echo "找不到应用: $SRC" >&2; exit 1; }
mkdir -p "$HOME/Applications"
ditto "$SRC" "$DST"
# Launch through a local Objective-C shim so AppKit labels can be translated at runtime.
mv "$DST/Contents/MacOS/Rex" "$DST/Contents/MacOS/RexCore"
cp "$(dirname "$0")/bin/RexLauncher" "$DST/Contents/MacOS/Rex"
cp "$(dirname "$0")/bin/libRexChinese.dylib" "$DST/Contents/Frameworks/libRexChinese.dylib"
chmod +x "$DST/Contents/MacOS/Rex" "$DST/Contents/MacOS/RexCore"
mkdir -p "$DST/Contents/Resources/zh_CN.lproj"
cp "$(dirname "$0")/Resources/zh_CN.lproj/Localizable.strings" "$DST/Contents/Resources/zh_CN.lproj/Localizable.strings"
mkdir -p "$DST/Contents/Resources/RexApp_RexMacOS.bundle/Contents/Resources/zh_CN.lproj"
cp "$(dirname "$0")/Resources/zh_CN.lproj/Localizable.strings" "$DST/Contents/Resources/RexApp_RexMacOS.bundle/Contents/Resources/zh_CN.lproj/Localizable.strings"
for lang in zh-Hans zh-Hans-CN; do
  mkdir -p "$DST/Contents/Resources/RexApp_RexMacOS.bundle/Contents/Resources/$lang.lproj"
  cp "$(dirname "$0")/Resources/zh_CN.lproj/Localizable.strings" "$DST/Contents/Resources/RexApp_RexMacOS.bundle/Contents/Resources/$lang.lproj/Localizable.strings"
done
/usr/libexec/PlistBuddy -c 'Add :CFBundleLocalizations array' "$DST/Contents/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c 'Add :CFBundleLocalizations:0 string zh_CN' "$DST/Contents/Info.plist" 2>/dev/null || true
xattr -dr com.apple.quarantine "$DST" 2>/dev/null || true
codesign --force --deep --sign - "$DST" >/dev/null
echo "已生成: $DST"
