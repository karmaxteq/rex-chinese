#!/usr/bin/env python3
"""Exercise production AppKit placeholder hooks in an isolated test process.

Compile RexZh.m unchanged as a dylib, capture native getters and the native
attributed-string constructor before dlopen, then exercise real AppKit controls.
No Rex application is launched or injected, and no window is opened. Requires
macOS and Xcode command-line tools; no third-party dependencies are used.
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

typedef id (*Getter)(id, SEL);
typedef CFAttributedStringRef (*AttributedCreate)(CFAllocatorRef, CFStringRef, CFDictionaryRef);
static Getter nativePlaceholder, nativeAttributedPlaceholder, nativeString, nativeTextViewString;
static AttributedCreate nativeAttributedCreate;
static NSMutableArray *failures;
static NSUInteger checks;

static void check(BOOL condition, NSString *name, id actual) {
    checks++;
    if (!condition) {
        // NSTextStorage can return a mutable backing string. Snapshot failures
        // before a later assignment changes the same object in place.
        id snapshot = [actual isKindOfClass:[NSString class]] ? [actual copy] : actual;
        [failures addObject:@{@"check": name, @"actual": snapshot ?: [NSNull null]}];
    }
}
static NSString *rawAttributed(NSAttributedString *value) {
    return value ? (__bridge NSString *)CFAttributedStringGetString((__bridge CFAttributedStringRef)value) : nil;
}
static NSString *rawPlaceholder(NSTextFieldCell *cell) {
    return nativePlaceholder(cell, @selector(placeholderString));
}
static NSAttributedString *rawAttributedPlaceholder(NSTextFieldCell *cell) {
    return nativeAttributedPlaceholder(cell, @selector(placeholderAttributedString));
}
static NSString *rawInput(NSTextField *field) {
    return nativeString(field.cell, @selector(stringValue));
}
static NSAttributedString *fixture(NSDictionary *attributes) {
    CFAttributedStringRef value = nativeAttributedCreate(NULL, CFSTR("Filter"), (__bridge CFDictionaryRef)attributes);
    NSAttributedString *result = CFBridgingRelease(value);
    // The fixture must be genuinely English in storage, despite production's
    // translated NSAttributedString.string getter and CF constructor shim.
    check([rawAttributed(result) isEqualToString:@"Filter"], @"fixture starts as raw English", rawAttributed(result));
    return result;
}
static void checkAttributed(NSTextFieldCell *cell, NSDictionary *attributes, NSString *name) {
    NSAttributedString *value = rawAttributedPlaceholder(cell);
    NSString *stored = rawAttributed(value);
    check([stored isEqualToString:@"筛选"], [name stringByAppendingString:@" backing text"], stored);
    NSDictionary *actual = value.length ? [value attributesAtIndex:0 effectiveRange:NULL] : @{};
    for (NSString *key in @[NSFontAttributeName, NSForegroundColorAttributeName]) {
        check([actual[key] isEqual:attributes[key]], [name stringByAppendingFormat:@" retains %@", key],
              [actual[key] description]);
    }
}

int main(int argc, const char **argv) {
    @autoreleasepool {
        if (argc != 2) return 2;
        // Initialize AppKit without opening a window or entering an app loop.
        [NSApplication sharedApplication];
        nativePlaceholder = (Getter)class_getMethodImplementation([NSTextFieldCell class], @selector(placeholderString));
        nativeAttributedPlaceholder = (Getter)class_getMethodImplementation([NSTextFieldCell class], @selector(placeholderAttributedString));
        nativeString = (Getter)class_getMethodImplementation([NSTextFieldCell class], @selector(stringValue));
        nativeTextViewString = (Getter)class_getMethodImplementation([NSTextView class], @selector(string));
        nativeAttributedCreate = (AttributedCreate)dlsym(RTLD_DEFAULT, "CFAttributedStringCreate");
        if (!nativePlaceholder || !nativeAttributedPlaceholder || !nativeString || !nativeTextViewString || !nativeAttributedCreate) return 3;
        if (!dlopen(argv[1], RTLD_NOW | RTLD_LOCAL)) {
            fprintf(stderr, "Could not load production hook: %s\n", dlerror());
            return 4;
        }
        failures = [NSMutableArray array];
        NSDictionary *attributes = @{NSFontAttributeName: [NSFont systemFontOfSize:17.0 weight:NSFontWeightBold],
                                     NSForegroundColorAttributeName: [NSColor colorWithSRGBRed:0.2 green:0.4 blue:0.7 alpha:1.0]};
        NSTextField *field = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 240, 30)];
        field.editable = YES;
        field.placeholderString = @"Filter";
        check([rawPlaceholder(field.cell) isEqualToString:@"筛选"], @"field plain setter backing text", rawPlaceholder(field.cell));
        field.placeholderString = nil;
        check(rawPlaceholder(field.cell) == nil, @"field plain nil clears", rawPlaceholder(field.cell));
        field.placeholderAttributedString = fixture(attributes);
        checkAttributed(field.cell, attributes, @"field attributed setter");
        field.placeholderAttributedString = nil;
        check(rawAttributedPlaceholder(field.cell) == nil, @"field attributed nil clears", rawAttributed(rawAttributedPlaceholder(field.cell)));

        NSTextFieldCell *cell = [[NSTextFieldCell alloc] initTextCell:@""];
        cell.placeholderString = @"Filter";
        check([rawPlaceholder(cell) isEqualToString:@"筛选"], @"cell plain setter backing text", rawPlaceholder(cell));
        cell.placeholderString = nil;
        check(rawPlaceholder(cell) == nil, @"cell plain nil clears", rawPlaceholder(cell));
        cell.placeholderAttributedString = fixture(attributes);
        checkAttributed(cell, attributes, @"cell attributed setter");
        cell.placeholderAttributedString = nil;
        check(rawAttributedPlaceholder(cell) == nil, @"cell attributed nil clears", rawAttributed(rawAttributedPlaceholder(cell)));

        // Replacing the cell after field construction must not require a timer
        // or a visibility/accessibility walk to repair its placeholder storage.
        NSTextFieldCell *replacement = [[NSTextFieldCell alloc] initTextCell:@""];
        replacement.placeholderAttributedString = fixture(attributes);
        field.cell = replacement;
        check(field.cell == replacement, @"replacement cell remains installed", NSStringFromClass(field.cell.class));
        checkAttributed(field.cell, attributes, @"replacement attributed cell");
        ((NSTextFieldCell *)field.cell).placeholderString = @"Filter";
        check([rawPlaceholder(field.cell) isEqualToString:@"筛选"], @"replacement plain setter backing text", rawPlaceholder(field.cell));

        // Exercise public user-value assignment, not a native bypass that could
        // hide existing NSControl/NSCell value-mutation defects.
        for (NSString *input in @[@"Filter", @"Settings", @"/tmp/Filter/Settings.txt", @"中文 😀 用户输入"]) {
            field.editable = YES;
            field.stringValue = input;
            check([rawInput(field) isEqualToString:input], [@"user input assignment: " stringByAppendingString:input], rawInput(field));
            check([field.stringValue isEqualToString:input], [@"public field getter: " stringByAppendingString:input], field.stringValue);
            check([field.accessibilityValue isEqual:input], [@"field accessibility value: " stringByAppendingString:input], field.accessibilityValue);
            field.placeholderString = @"Filter";
            check([rawInput(field) isEqualToString:input], [@"user input after field plain: " stringByAppendingString:input], rawInput(field));
            field.placeholderAttributedString = fixture(attributes);
            check([rawInput(field) isEqualToString:input], [@"user input after field attributed: " stringByAppendingString:input], rawInput(field));
            ((NSTextFieldCell *)field.cell).placeholderString = @"Filter";
            check([rawInput(field) isEqualToString:input], [@"user input after cell plain: " stringByAppendingString:input], rawInput(field));
            ((NSTextFieldCell *)field.cell).placeholderAttributedString = fixture(attributes);
            check([rawInput(field) isEqualToString:input], [@"user input after cell attributed: " stringByAppendingString:input], rawInput(field));
            field.placeholderAttributedString = nil;
            ((NSTextFieldCell *)field.cell).placeholderString = nil;
            check([rawInput(field) isEqualToString:input], [@"user input after clearing: " stringByAppendingString:input], rawInput(field));
            check([field.stringValue isEqualToString:input], [@"public field getter after clearing: " stringByAppendingString:input], field.stringValue);
            check([field.accessibilityValue isEqual:input], [@"field accessibility after clearing: " stringByAppendingString:input], field.accessibilityValue);
        }
        NSTextView *textView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 240, 100)];
        textView.editable = YES;
        for (NSString *input in @[@"Filter", @"Settings", @"/tmp/Filter/Settings.txt", @"中文 😀 用户输入"]) {
            textView.string = input;
            NSString *nativeValue = nativeTextViewString(textView, @selector(string));
            NSString *storage = rawAttributed(textView.textStorage);
            check([nativeValue isEqualToString:input], [@"native text-view getter: " stringByAppendingString:input], nativeValue);
            check([storage isEqualToString:input], [@"text-view backing storage: " stringByAppendingString:input], storage);
            check([textView.string isEqualToString:input], [@"public text-view getter: " stringByAppendingString:input], textView.string);
        }
        NSDictionary *report = @{@"checks": @(checks), @"failures": failures,
                                  @"storage_readback": @"pre-hook native getters and CFAttributedStringGetString"};
        NSData *data = [NSJSONSerialization dataWithJSONObject:report options:NSJSONWritingPrettyPrinted error:NULL];
        fwrite(data.bytes, 1, data.length, stdout); putchar('\n');
        return failures.count ? 1 : 0;
    }
}
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=ROOT / 'RexZh.m',
                        help='production Objective-C source (default: current RexZh.m)')
    args = parser.parse_args()
    if sys.platform != 'darwin':
        parser.exit(2, 'AppKit placeholder storage tests require macOS and Xcode command-line tools.\n')
    with tempfile.TemporaryDirectory(prefix='rex-placeholder-storage-') as directory:
        root = Path(directory)
        runner = root / 'main.m'
        runner.write_text(RUNNER)
        library, executable = root / 'libRexChinese-test.dylib', root / 'placeholder-storage'
        base = ['xcrun', 'clang', '-fobjc-arc', '-fblocks', '-framework', 'AppKit', '-framework', 'CoreFoundation']
        subprocess.run(base + ['-dynamiclib', str(args.source.resolve()), '-framework', 'CoreText',
                               '-framework', 'QuartzCore', '-o', str(library)], check=True)
        subprocess.run(base + [str(runner), '-o', str(executable)], check=True)
        result = subprocess.run([str(executable), str(library)], text=True, capture_output=True)
        if result.returncode == 0 and not result.stdout:
            raise RuntimeError('Native harness exited without a storage-check report')
        if result.stdout:
            # Validate the harness report rather than treating process success
            # alone as proof that native assertions actually ran.
            report = json.loads(result.stdout)
            if report.get('checks') != 80 or not isinstance(report.get('failures'), list):
                raise RuntimeError('Native harness did not report its storage checks')
            print(json.dumps(report, ensure_ascii=False, indent=2))
        if result.stderr:
            print(result.stderr, file=sys.stderr, end='')
        return result.returncode


if __name__ == '__main__':
    raise SystemExit(main())
