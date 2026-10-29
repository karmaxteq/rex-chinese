#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
BUILD_DIR="$ROOT/build"
BIN_DIR="$ROOT/bin"
mkdir -p "$BUILD_DIR" "$BIN_DIR"

for arch in arm64 x86_64; do
  clang -arch "$arch" -isysroot "$SDKROOT" -mmacosx-version-min=13.0 \
    "$ROOT/RexLauncher.c" -o "$BUILD_DIR/RexLauncher-${arch}"

  swiftc -target "${arch}-apple-macos13.0" \
    -emit-object -parse-as-library -O \
    "$ROOT/RexTextHook.swift" \
    -o "$BUILD_DIR/RexTextHook-${arch}.o"

  clang -arch "$arch" -isysroot "$SDKROOT" -mmacosx-version-min=13.0 \
    -fblocks -c "$ROOT/RexTextHookInterpose.c" \
    -o "$BUILD_DIR/RexTextHookInterpose-${arch}.o"

  swiftc -target "${arch}-apple-macos13.0" \
    -emit-library -parse-as-library -O \
    "$BUILD_DIR/RexTextHook-${arch}.o" \
    "$BUILD_DIR/RexTextHookInterpose-${arch}.o" \
    -o "$BUILD_DIR/libRexTextHook-${arch}.dylib" \
    -framework Foundation -framework SwiftUI

  clang -arch "$arch" -isysroot "$SDKROOT" -mmacosx-version-min=13.0 \
    -fobjc-arc -fblocks -dynamiclib "$ROOT/RexZh.m" \
    -o "$BUILD_DIR/libRexChinese-${arch}.dylib" \
    -framework AppKit -framework CoreFoundation -framework CoreText -framework QuartzCore
done

lipo -create "$BUILD_DIR/RexLauncher-arm64" "$BUILD_DIR/RexLauncher-x86_64" \
  -output "$BUILD_DIR/RexLauncher"
lipo -create "$BUILD_DIR/libRexTextHook-arm64.dylib" \
  "$BUILD_DIR/libRexTextHook-x86_64.dylib" \
  -output "$BUILD_DIR/libRexTextHook.dylib"
lipo -create "$BUILD_DIR/libRexChinese-arm64.dylib" \
  "$BUILD_DIR/libRexChinese-x86_64.dylib" \
  -output "$BUILD_DIR/libRexChinese.dylib"

cp "$BUILD_DIR/libRexTextHook.dylib" "$BIN_DIR/libRexTextHook.dylib"
cp "$BUILD_DIR/libRexChinese.dylib" "$BIN_DIR/libRexChinese.dylib"
cp "$BUILD_DIR/RexLauncher" "$BIN_DIR/RexLauncher"

echo "已构建并同步: $BIN_DIR/RexLauncher"
echo "已构建并同步: $BIN_DIR/libRexTextHook.dylib"
echo "已构建并同步: $BIN_DIR/libRexChinese.dylib"
