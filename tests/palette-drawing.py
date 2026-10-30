#!/usr/bin/env python3
"""Exercise production attributed drawing and native palette pixels in isolation.

The unchanged production library is loaded into a test process with no windows.
A native attributed-draw spy reads Core Foundation backing storage, while a
synthetic palette view paints a marker that a replacement row renderer must not
erase. Requires macOS and Xcode command-line tools; no third-party packages.
"""
import argparse
import json
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
RUNNER = r'''
#import <AppKit/AppKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <objc/runtime.h>
#include <dlfcn.h>

typedef CFAttributedStringRef (*AttributedCreate)(CFAllocatorRef, CFStringRef, CFDictionaryRef);
static AttributedCreate nativeAttributedCreate;
static NSMutableArray *failures, *draws;
static NSUInteger checks, paletteDraws;
static NSDictionary *fixtureAttributes;

static void check(BOOL condition, NSString *name, id actual) {
    checks++;
    if (!condition) [failures addObject:@{@"check": name, @"actual": actual ?: NSNull.null}];
}
static NSString *backing(NSAttributedString *value) {
    return [(__bridge NSString *)CFAttributedStringGetString((__bridge CFAttributedStringRef)value) copy];
}
static NSAttributedString *fixture(NSString *text, BOOL mutable) {
    NSAttributedString *value = CFBridgingRelease(nativeAttributedCreate(
        NULL, (__bridge CFStringRef)text, (__bridge CFDictionaryRef)fixtureAttributes));
    return mutable ? [value mutableCopy] : value;
}
static void drawSpy(id self, SEL selector, NSRect rect) {
    NSAttributedString *value = self;
    [draws addObject:@{@"text": backing(value),
                      @"attributes": [value attributesAtIndex:0 effectiveRange:NULL],
                      @"rect": [NSValue valueWithRect:rect]}];
}
static void nativePaletteDraw(id self, SEL selector, NSRect rect) {
    paletteDraws++;
    // A native row's selection/decorations must survive localization. This
    // marker sits inside the old hardcoded renderer's cleared text column.
    [[NSColor colorWithSRGBRed:1 green:0 blue:1 alpha:1] setFill];
    NSRectFill(NSMakeRect(100, 10, 8, 8));
    [fixture(@"Select Cursor Style…", NO) drawInRect:NSMakeRect(12, 80, 280, 24)];
}
static NSUInteger renderMarker(NSView *view) {
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc]
        initWithBitmapDataPlanes:NULL pixelsWide:330 pixelsHigh:160
        bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO
        colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:0 bitsPerPixel:0];
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap];
    [NSGraphicsContext saveGraphicsState];
    NSGraphicsContext.currentContext = context;
    [NSColor.whiteColor setFill]; NSRectFill(view.bounds);
    [view drawRect:view.bounds];
    [context flushGraphics];
    [NSGraphicsContext restoreGraphicsState];
    NSUInteger magenta = 0;
    for (NSInteger y = 0; y < bitmap.pixelsHigh; y++) {
        for (NSInteger x = 0; x < bitmap.pixelsWide; x++) {
            NSColor *color = [bitmap colorAtX:x y:y];
            if (color.redComponent > 0.95 && color.greenComponent < 0.05 && color.blueComponent > 0.95) magenta++;
        }
    }
    return magenta;
}

int main(int argc, const char **argv) { @autoreleasepool {
    if (argc != 2) return 2;
    [NSApplication sharedApplication];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyProhibited];
    failures = [NSMutableArray array]; draws = [NSMutableArray array];
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.alignment = NSTextAlignmentRight; paragraph.lineSpacing = 3.25;
    fixtureAttributes = @{NSFontAttributeName: [NSFont systemFontOfSize:17 weight:NSFontWeightBold],
                          NSForegroundColorAttributeName: [NSColor colorWithSRGBRed:0.2 green:0.4 blue:0.7 alpha:1],
                          NSParagraphStyleAttributeName: paragraph};
    nativeAttributedCreate = (AttributedCreate)dlsym(RTLD_DEFAULT, "CFAttributedStringCreate");
    if (!nativeAttributedCreate) return 3;
    Method drawMethod = class_getInstanceMethod(NSAttributedString.class, @selector(drawInRect:));
    method_setImplementation(drawMethod, (IMP)drawSpy);
    const char *paletteName = "_TtCE8RexMacOSO9RexShared9Workspace22CommandPaletteListView";
    Class paletteClass = objc_allocateClassPair(NSView.class, paletteName, 0);
    if (!paletteClass || !class_addMethod(paletteClass, @selector(drawRect:), (IMP)nativePaletteDraw,
        method_getTypeEncoding(class_getInstanceMethod(NSView.class, @selector(drawRect:))))) return 4;
    objc_registerClassPair(paletteClass);
    NSView *view = [[paletteClass alloc] initWithFrame:NSMakeRect(0, 0, 330, 160)];
    NSUInteger baseline = renderMarker(view);
    check(baseline == 64, @"native pixel fixture paints exactly 64 marker pixels", @(baseline));
    check(paletteDraws == 1, @"baseline invokes native palette renderer exactly once", @(paletteDraws));
    [draws removeAllObjects];
    if (!dlopen(argv[1], RTLD_NOW | RTLD_LOCAL)) {
        fprintf(stderr, "Could not load production library: %s\n", dlerror()); return 5;
    }
    // Exercise the real constructor and its lazy view-hook timer. No private
    // production installer is copied or invoked by a synthetic replacement.
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.45]];
    check(class_getMethodImplementation(NSAttributedString.class, @selector(drawInRect:)) != (IMP)drawSpy,
          @"production attributed drawing hook installed", nil);
    NSArray *cases = @[
        @[@"Select Terminal Font…", @"选择终端字体…", @NO],
        @[@"New Tab", @"新建标签页", @NO],
        @[@"New Tab", @"新建标签页", @YES],
        @[@"Change Theme", @"更改主题", @NO],
        @[@"Auto Color Scheme", @"自动配色方案", @NO],
        @[@"Light Color Scheme", @"浅色配色方案", @YES],
        @[@"Dark Color Scheme", @"深色配色方案", @NO],
        @[@"Ready to Check for Updates · Preview", @"可以检查更新 · 预览", @NO],
        @[@"Ready to Check for Updates · Bleeding Edge", @"可以检查更新 · 前沿版", @YES],
        @[@"/tmp/Filter/Settings.txt", @"/tmp/Filter/Settings.txt", @NO],
        @[@"Settings-host.example", @"Settings-host.example", @YES],
        @[@"中文 😀 用户输入", @"中文 😀 用户输入", @NO]
    ];
    NSRect target = NSMakeRect(17, 29, 271, 23);
    for (NSArray *item in cases) {
        NSAttributedString *value = fixture(item[0], [item[2] boolValue]);
        [draws removeAllObjects]; [value drawInRect:target];
        NSString *name = [NSString stringWithFormat:@"%@ mutable=%@", item[0], item[2]];
        check(draws.count == 1, [name stringByAppendingString:@" forwards one real draw"], @(draws.count));
        NSDictionary *draw = draws.firstObject ?: @{};
        check([draw[@"text"] isEqual:item[1]], [name stringByAppendingString:@" native backing text"], draw[@"text"]);
        for (NSString *key in @[NSFontAttributeName, NSForegroundColorAttributeName, NSParagraphStyleAttributeName]) {
            check([draw[@"attributes"][key] isEqual:fixtureAttributes[key]],
                  [name stringByAppendingFormat:@" preserves %@", key], [draw[@"attributes"][key] description]);
        }
        check([draw[@"rect"] isEqual:[NSValue valueWithRect:target]], [name stringByAppendingString:@" preserves native rect"],
              [draw[@"rect"] description]);
        check([backing(value) isEqual:item[0]], [name stringByAppendingString:@" does not mutate source storage"], backing(value));
    }
    paletteDraws = 0; [draws removeAllObjects];
    NSUInteger after = renderMarker(view);
    check(paletteDraws == 1, @"patched native palette renderer is invoked exactly once", @(paletteDraws));
    check(after == baseline, @"native palette selection pixels are not cleared or replaced", @(after));
    check([draws.firstObject[@"text"] isEqual:@"选择光标样式…"],
          @"arbitrary native palette row reaches original drawing as Chinese", draws.firstObject[@"text"]);
    NSDictionary *report = @{@"checks": @(checks), @"failures": failures,
        @"native_marker_pixels": @(baseline), @"patched_marker_pixels": @(after),
        @"scope": @"production dylib constructor, attributed backing/attributes/rect and synthetic native palette pixels; no windows or Rex process"};
    NSData *data = [NSJSONSerialization dataWithJSONObject:report options:NSJSONWritingPrettyPrinted error:NULL];
    fwrite(data.bytes, 1, data.length, stdout); putchar('\n');
    return failures.count ? 1 : 0;
}}
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    inputs = parser.add_mutually_exclusive_group()
    inputs.add_argument('--source', type=Path, help='compile this production source (default: current RexZh.m)')
    inputs.add_argument('--library', type=Path, help='test an already-built production dylib')
    args = parser.parse_args()
    if sys.platform != 'darwin':
        parser.exit(2, 'Requires macOS and Xcode command-line tools.\n')
    with tempfile.TemporaryDirectory(prefix='rex-palette-drawing-') as directory:
        root = Path(directory)
        runner, executable = root / 'main.m', root / 'palette-drawing'
        runner.write_text(RUNNER)
        base = ['xcrun', 'clang', '-fobjc-arc', '-fblocks', '-framework', 'AppKit', '-framework', 'CoreFoundation']
        library = args.library.resolve() if args.library else root / 'libRexChinese-test.dylib'
        if not args.library:
            source = (args.source or ROOT / 'RexZh.m').resolve()
            subprocess.run(base + ['-dynamiclib', str(source), '-framework', 'CoreText',
                                   '-framework', 'QuartzCore', '-o', str(library)], check=True)
        subprocess.run(base + [str(runner), '-o', str(executable)], check=True)
        result = subprocess.run([str(executable), str(library)], capture_output=True, text=True, timeout=20)
        if result.stderr:
            print(result.stderr, file=sys.stderr, end='')
        if not result.stdout:
            raise RuntimeError('Native drawing harness did not produce a report')
        report = json.loads(result.stdout)
        if report.get('checks') != 90 or not isinstance(report.get('failures'), list):
            raise RuntimeError('Native drawing harness did not execute every assertion')
        print(json.dumps(report, ensure_ascii=False, indent=2))
        return result.returncode


if __name__ == '__main__':
    raise SystemExit(main())
