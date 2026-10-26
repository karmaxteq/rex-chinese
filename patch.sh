#!/bin/sh
set -eu
SRC=${1:-/Applications/Rex\ Beta.app}
DST="$HOME/Applications/Rex Beta 中文版.app"
[ -d "$SRC" ] || { echo "找不到应用: $SRC" >&2; exit 1; }
mkdir -p "$HOME/Applications"
ditto "$SRC" "$DST"
mkdir -p "$DST/Contents/Resources/zh_CN.lproj"
cp "$(dirname "$0")/Resources/zh_CN.lproj/Localizable.strings" "$DST/Contents/Resources/zh_CN.lproj/Localizable.strings"
/usr/libexec/PlistBuddy -c 'Add :CFBundleLocalizations array' "$DST/Contents/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c 'Add :CFBundleLocalizations:0 string zh_CN' "$DST/Contents/Info.plist" 2>/dev/null || true
xattr -dr com.apple.quarantine "$DST" 2>/dev/null || true
codesign --force --deep --sign - "$DST" >/dev/null
echo "已生成: $DST"
