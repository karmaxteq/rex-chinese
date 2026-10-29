#!/bin/sh
set -eu
SRC=${1:-/Applications/Rex\ Beta.app}
DST="$HOME/Applications/Rex Beta 中文版.app"
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
[ -d "$SRC" ] || { echo "找不到应用: $SRC" >&2; exit 1; }
[ ! -e "$SRC/Contents/MacOS/RexCore" ] || { echo "请提供未打补丁的 Rex Beta 原版。" >&2; exit 1; }
command -v python3 >/dev/null || { echo "需要 Python 3（仅使用标准库）以校验预览补丁。" >&2; exit 1; }
VERSION=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$SRC/Contents/Info.plist")
BUILD=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$SRC/Contents/Info.plist")
[ "$VERSION" = 0.1.0 ] && [ "$BUILD" = 1408 ] || { echo "仅支持 Rex Beta 0.1.0 (1408)，当前为 $VERSION ($BUILD)。" >&2; exit 1; }
# Validate the exact GPU demo constant before touching the installed copy.
python3 "$ROOT/tools/patch-preview.py" "$SRC/Contents/MacOS/Rex" --dry-run
mkdir -p "$HOME/Applications"
ditto "$SRC" "$DST"
# Launch through a local Objective-C shim so AppKit labels can be translated at runtime.
mv "$DST/Contents/MacOS/Rex" "$DST/Contents/MacOS/RexCore"
python3 "$ROOT/tools/patch-preview.py" "$DST/Contents/MacOS/RexCore" --write
cp "$(dirname "$0")/bin/RexLauncher" "$DST/Contents/MacOS/Rex"
cp "$(dirname "$0")/bin/libRexChinese.dylib" "$DST/Contents/Frameworks/libRexChinese.dylib"
cp "$(dirname "$0")/bin/libRexTextHook.dylib" "$DST/Contents/Frameworks/libRexTextHook.dylib"
chmod +x "$DST/Contents/MacOS/Rex" "$DST/Contents/MacOS/RexCore"
mkdir -p "$DST/Contents/Resources/zh_CN.lproj"
cp "$(dirname "$0")/Resources/zh_CN.lproj/Localizable.strings" "$DST/Contents/Resources/zh_CN.lproj/Localizable.strings"
mkdir -p "$DST/Contents/Resources/RexApp_RexMacOS.bundle/Contents/Resources/zh_CN.lproj"
cp "$(dirname "$0")/Resources/zh_CN.lproj/Localizable.strings" "$DST/Contents/Resources/RexApp_RexMacOS.bundle/Contents/Resources/zh_CN.lproj/Localizable.strings"
for lang in zh-Hans zh-Hans-CN; do
  mkdir -p "$DST/Contents/Resources/RexApp_RexMacOS.bundle/Contents/Resources/$lang.lproj"
  cp "$(dirname "$0")/Resources/zh_CN.lproj/Localizable.strings" "$DST/Contents/Resources/RexApp_RexMacOS.bundle/Contents/Resources/$lang.lproj/Localizable.strings"
done
# Give the patched copy its own LaunchServices identity.  The upstream app and
# the copy otherwise share com.superlogical.rex, so Dock/Cursor can reopen the
# unpatched app when the user selects the Chinese copy.
/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier com.superlogical.rex.chinese' "$DST/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleDisplayName Rex Beta 中文版' "$DST/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleName Rex Beta 中文版' "$DST/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Add :CFBundleLocalizations array' "$DST/Contents/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c 'Add :CFBundleLocalizations:0 string zh_CN' "$DST/Contents/Info.plist" 2>/dev/null || true
xattr -dr com.apple.quarantine "$DST" 2>/dev/null || true
codesign --force --sign - "$DST/Contents/MacOS/RexCore" >/dev/null
codesign --force --deep --sign - "$DST" >/dev/null
# Refresh LaunchServices after changing the bundle identity.  Without this,
# Finder/Dock can keep the source app's stale registration and reopen English
# Rex even when the user selects the Chinese copy.
LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
if [ -x "$LSREGISTER" ]; then
  "$LSREGISTER" -f "$DST" >/dev/null 2>&1 || true
fi
echo "已生成: $DST"
