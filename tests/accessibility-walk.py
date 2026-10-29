#!/usr/bin/env python3
"""Exercise production native/AX traversal without opening a window or Rex.

Compile the complete Objective-C production source and append a same-translation-
unit harness. Only the automatic constructor attribute is removed: the harness
calls the unchanged traversal functions directly, without installing global hooks
or scheduling the application's refresh timer. Uses macOS/Xcode and the standard
library. --source permits comparison with a prior production source snapshot.
"""
import argparse
import json
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
RUNNER = r'''
static NSMutableArray *testFailures;
static NSUInteger testChecks;
static void testCheck(BOOL condition, NSString *name, NSUInteger actual) {
    testChecks++;
    if (!condition) [testFailures addObject:@{@"check": name, @"actual": @(actual)}];
}

// Use real NSView ownership/subview traversal, with deterministic AX attributes.
// These class names deliberately do not start with RX (the patch's own views).
@interface TestNativeView : NSView
@property(nonatomic, strong) NSMutableDictionary *testAttributes;
@property(nonatomic, copy) NSArray *testVirtualChildren;
@property(nonatomic) NSUInteger testChildrenReads;
@property(nonatomic) NSUInteger testDescriptionReads;
@end
@implementation TestNativeView
- (instancetype)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) _testAttributes = [NSMutableDictionary dictionary];
    return self;
}
- (id)accessibilityAttributeValue:(NSString *)attribute {
    if ([attribute isEqualToString:NSAccessibilityChildrenAttribute]) {
        self.testChildrenReads++;
        return [self.subviews arrayByAddingObjectsFromArray:self.testVirtualChildren ?: @[]];
    }
    if ([attribute isEqualToString:NSAccessibilityDescriptionAttribute]) self.testDescriptionReads++;
    return self.testAttributes[attribute];
}
- (void)accessibilitySetValue:(id)value forAttribute:(NSString *)attribute { self.testAttributes[attribute] = value; }
- (NSRect)accessibilityFrame { return NSMakeRect(100, 200, 120, 18); }
- (NSString *)accessibilityLabel { return nil; }
- (NSString *)accessibilityHelp { return nil; }
- (NSString *)accessibilityTitle { return nil; }
@end

// AX-only nodes stand in for SwiftUI virtual elements and the window AX root.
// No NSWindow is instantiated, shown, or connected to the running Rex process.
@interface TestAXElement : NSObject
@property(nonatomic, strong) NSMutableDictionary *testAttributes;
@property(nonatomic, copy) NSArray *testChildren;
@property(nonatomic) NSUInteger testChildrenReads;
@property(nonatomic) NSUInteger testDescriptionReads;
@property(nonatomic) NSRect testFrame;
@end
@implementation TestAXElement
- (instancetype)init {
    if ((self = [super init])) {
        _testAttributes = [NSMutableDictionary dictionary];
        _testFrame = NSMakeRect(30, 40, 110, 18);
    }
    return self;
}
- (id)accessibilityAttributeValue:(NSString *)attribute {
    if ([attribute isEqualToString:NSAccessibilityChildrenAttribute]) { self.testChildrenReads++; return self.testChildren; }
    if ([attribute isEqualToString:NSAccessibilityDescriptionAttribute]) self.testDescriptionReads++;
    return self.testAttributes[attribute];
}
- (void)accessibilitySetValue:(id)value forAttribute:(NSString *)attribute { self.testAttributes[attribute] = value; }
- (NSRect)accessibilityFrame { return self.testFrame; }
@end

@interface TestFieldCell : NSTextFieldCell
@property(nonatomic) NSUInteger testChildrenReads;
@property(nonatomic) NSUInteger testDescriptionReads;
@end
@implementation TestFieldCell
- (id)accessibilityAttributeValue:(NSString *)attribute {
    if ([attribute isEqualToString:NSAccessibilityChildrenAttribute]) { self.testChildrenReads++; return @[]; }
    if ([attribute isEqualToString:NSAccessibilityDescriptionAttribute]) self.testDescriptionReads++;
    return nil;
}
@end

// The server card exists only in the modern SwiftUI AX tree: the legacy
// attribute API deliberately exposes neither its strings nor its children.
@interface TestModernAXElement : NSObject
@property(nonatomic, strong) NSMutableDictionary *testTexts;
@property(nonatomic, copy) NSArray *testChildren;
@property(nonatomic) NSRect testFrame;
@property(nonatomic) NSUInteger testChildrenReads;
@property(nonatomic) NSUInteger testTextReads;
@property(nonatomic) NSUInteger testLegacyReads;
@property(nonatomic) NSUInteger testFrameReads;
@end
@implementation TestModernAXElement
- (instancetype)init {
    if ((self = [super init])) {
        _testTexts = [NSMutableDictionary dictionary];
        _testFrame = NSMakeRect(100, 200, 180, 33.5);
    }
    return self;
}
- (id)testText:(SEL)selector { self.testTextReads++; return self.testTexts[NSStringFromSelector(selector)]; }
- (id)accessibilityLabel { return [self testText:_cmd]; }
- (id)accessibilityHelp { return [self testText:_cmd]; }
- (id)accessibilityDescription { return [self testText:_cmd]; }
- (id)accessibilityValue { return [self testText:_cmd]; }
- (NSArray *)accessibilityChildren { self.testChildrenReads++; return self.testChildren; }
- (NSRect)accessibilityFrame { self.testFrameReads++; return self.testFrame; }
- (id)accessibilityAttributeValue:(NSString *)attribute { self.testLegacyReads++; return nil; }
@end

// Owned overlay names must be excluded before querying any accessibility API.
@interface RXTestModernOverlay : TestModernAXElement
@end
@implementation RXTestModernOverlay
@end

#if TEST_HAS_SERVER_COLLECTOR
static void testModernServerCollector(void) {
    NSString *english = @"Tailscale Access, Access Rex securely from your other devices.";
    NSString *chinese = @"Tailscale 访问、从其他设备安全访问 Rex。";
    TestModernAXElement *root = [TestModernAXElement new];
    TestModernAXElement *card = [TestModernAXElement new];
    card.testTexts[@"accessibilityLabel"] = english;
    root.testChildren = @[card];
    RXHasServerAccessFrame = NO;
    RXWalkAX(root, 0);
    testCheck(!RXHasServerAccessFrame, @"legacy AX walk cannot discover modern-only server card", RXHasServerAccessFrame);
    testCheck(root.testChildrenReads == 0 && card.testTextReads == 0,
              @"legacy AXChildren does not expose modern children", root.testChildrenReads);

    for (NSString *selector in @[@"accessibilityLabel", @"accessibilityHelp", @"accessibilityDescription", @"accessibilityValue"]) {
        for (NSString *text in @[english, chinese]) {
            root = [TestModernAXElement new];
            card = [TestModernAXElement new];
            root.testChildren = @[card];
            card.testTexts[selector] = text;
            RXHasServerAccessFrame = NO;
            BOOL found = RXCollectServerAccessFrame(root, 0);
            NSString *context = [NSString stringWithFormat:@"%@ %@", selector, text == english ? @"English" : @"Chinese"];
            testCheck(found && RXHasServerAccessFrame, [@"modern server match: " stringByAppendingString:context], found);
            testCheck(NSEqualRects(RXServerAccessFrame, NSMakeRect(100, 200, 180, 14)),
                      [@"combined server frame preserves bottom-left and crops to fourteen: " stringByAppendingString:context], RXHasServerAccessFrame);
            testCheck(root.testChildrenReads == 1 && root.testLegacyReads == 0 && card.testLegacyReads == 0,
                      [@"modern-only subtree reached without legacy AXChildren: " stringByAppendingString:context], root.testChildrenReads);
        }
    }

    card = [TestModernAXElement new];
    card.testTexts[@"accessibilityLabel"] = chinese;
    card.testFrame = NSMakeRect(11, 22, 130, 22);
    RXCollectServerAccessFrame(card, 0);
    testCheck(NSEqualRects(RXServerAccessFrame, card.testFrame), @"twenty-two-point subtitle frame is not cropped", RXHasServerAccessFrame);
    card.testFrame = NSMakeRect(11, 22, 130, 10);
    RXCollectServerAccessFrame(card, 0);
    testCheck(NSEqualRects(RXServerAccessFrame, card.testFrame), @"short subtitle frame is not enlarged", RXHasServerAccessFrame);

    NSRect sentinel = NSMakeRect(1, 2, 3, 4);
    card.testFrame = NSZeroRect;
    RXHasServerAccessFrame = NO;
    RXServerAccessFrame = sentinel;
    BOOL found = RXCollectServerAccessFrame(card, 0);
    testCheck(!found && !RXHasServerAccessFrame, @"empty matching frame is rejected", found);
    testCheck(NSEqualRects(RXServerAccessFrame, sentinel), @"empty frame leaves previous frame untouched", RXHasServerAccessFrame);
    TestModernAXElement *validChild = [TestModernAXElement new];
    validChild.testTexts[@"accessibilityLabel"] = chinese;
    card.testChildren = @[validChild];
    found = RXCollectServerAccessFrame(card, 0);
    testCheck(found && RXHasServerAccessFrame && NSEqualRects(RXServerAccessFrame, NSMakeRect(100, 200, 180, 14)),
              @"empty matching parent still searches its modern children", found);

    card = [TestModernAXElement new];
    card.testTexts[@"accessibilityLabel"] = @"Access another app securely from your other devices.";
    RXHasServerAccessFrame = NO;
    RXServerAccessFrame = sentinel;
    found = RXCollectServerAccessFrame(card, 0);
    testCheck(!found && !RXHasServerAccessFrame && NSEqualRects(RXServerAccessFrame, sentinel),
              @"unrelated access subtitle does not capture server frame", found);
    card.testTexts[@"accessibilityLabel"] = @123;
    found = RXCollectServerAccessFrame(card, 0);
    testCheck(!found && card.testFrameReads == 0, @"non-string modern label is ignored before frame lookup", card.testFrameReads);
    testCheck(!RXCollectServerAccessFrame(nil, 0) && !RXCollectServerAccessFrame([NSObject new], 0),
              @"nil and non-provider modern elements are ignored", 0);

    card = [TestModernAXElement new];
    card.testTexts[@"accessibilityLabel"] = chinese;
    found = RXCollectServerAccessFrame(card, 21);
    testCheck(!found && card.testTextReads == 0 && card.testChildrenReads == 0 && card.testFrameReads == 0,
              @"modern collector depth guard precedes provider reads", card.testTextReads);
    found = RXCollectServerAccessFrame(card, 20);
    testCheck(found && RXHasServerAccessFrame, @"modern server card at depth twenty is accepted", found);
    root = [TestModernAXElement new];
    validChild = [TestModernAXElement new];
    validChild.testTexts[@"accessibilityLabel"] = chinese;
    root.testChildren = @[validChild];
    RXHasServerAccessFrame = NO;
    found = RXCollectServerAccessFrame(root, 20);
    testCheck(!found && !RXHasServerAccessFrame && validChild.testTextReads == 0,
              @"modern child beyond depth twenty is not queried", validChild.testTextReads);

    root = [TestModernAXElement new];
    root.testChildren = @[root];
    found = RXCollectServerAccessFrame(root, 0);
    testCheck(!found && root.testChildrenReads == 21, @"modern self-cycle terminates after depths zero through twenty", root.testChildrenReads);
    root.testChildren = nil;

    RXTestModernOverlay *overlay = [RXTestModernOverlay new];
    overlay.testTexts[@"accessibilityLabel"] = chinese;
    RXHasServerAccessFrame = NO;
    found = RXCollectServerAccessFrame(overlay, 0);
    testCheck(!found && !RXHasServerAccessFrame && overlay.testTextReads == 0 && overlay.testChildrenReads == 0 && overlay.testFrameReads == 0,
              @"owned overlay text and frame are excluded before reads", overlay.testTextReads);
    overlay.testChildren = @[validChild];
    found = RXCollectServerAccessFrame(overlay, 0);
    testCheck(!found && !RXHasServerAccessFrame && overlay.testChildrenReads == 0 && validChild.testTextReads == 0,
              @"owned overlay subtree is never traversed", overlay.testChildrenReads);
}
#endif

int main(void) { @autoreleasepool {
    [NSApplication sharedApplication];
    testFailures = [NSMutableArray array];
    const NSUInteger count = 16;
    NSMutableArray<TestNativeView *> *views = [NSMutableArray array];
    for (NSUInteger i = 0; i < count; i++) {
        TestNativeView *view = [[TestNativeView alloc] initWithFrame:NSMakeRect(0, 0, 200, 100)];
        view.testAttributes[NSAccessibilityDescriptionAttribute] = @"Settings";
        if (views.count) [views.lastObject addSubview:view];
        [views addObject:view];
    }
    TestAXElement *hue = [TestAXElement new];
    hue.testAttributes[NSAccessibilityDescriptionAttribute] = @"Hue";
    hue.testFrame = NSMakeRect(10, 20, 30, 14);
    TestAXElement *notification = [TestAXElement new];
    notification.testAttributes[NSAccessibilityDescriptionAttribute] = @"Displayed top left";
    notification.testFrame = NSMakeRect(50, 60, 150, 14);
    views.lastObject.testVirtualChildren = @[hue, notification];
    RXHasHueFrame = RXHasNotificationFrame = NO;

    RXWalk(views.firstObject);
    NSUInteger nativeChildrenReads = 0, nativeNodeReads = 0;
    for (TestNativeView *view in views) {
        nativeChildrenReads += view.testChildrenReads;
        nativeNodeReads += view.testDescriptionReads;
        testCheck([view.testAttributes[NSAccessibilityDescriptionAttribute] isEqualToString:@"设置"],
                  @"native descendants still receive node translation", view.testDescriptionReads);
    }
    testCheck(nativeChildrenReads == 0, @"native walk never recursively reads AXChildren", nativeChildrenReads);
    testCheck(nativeNodeReads == count, @"native chain inspects each AX node once", nativeNodeReads);
    testCheck(hue.testDescriptionReads == 0 && notification.testDescriptionReads == 0,
              @"native walk leaves AX-only descendants to the window pass", hue.testDescriptionReads + notification.testDescriptionReads);

    // The native control's cell still gets its own shallow inspection.
    NSTextField *field = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 30)];
    TestFieldCell *cell = [[TestFieldCell alloc] initTextCell:@""];
    field.cell = cell;
    field.editable = YES;
    RXWalk(field);
    testCheck(cell.testDescriptionReads == 1, @"native cell receives shallow AX inspection", cell.testDescriptionReads);
    testCheck(cell.testChildrenReads == 0, @"native cell does not start another AX subtree walk", cell.testChildrenReads);

    // One window-root recursion must still reach both native and AX-only nodes.
    TestAXElement *windowRoot = [TestAXElement new];
    windowRoot.testChildren = @[views.firstObject];
    RXWalkAX(windowRoot, 0);
    NSUInteger finalNativeChildrenReads = 0;
    for (TestNativeView *view in views) finalNativeChildrenReads += view.testChildrenReads;
    testCheck(finalNativeChildrenReads == count, @"window pass reads each native AX child list once", finalNativeChildrenReads);
    testCheck(windowRoot.testChildrenReads == 1, @"window root child list is read once", windowRoot.testChildrenReads);
    testCheck(hue.testDescriptionReads == 1 && hue.testChildrenReads == 1,
              @"window pass reaches AX-only color node once", hue.testDescriptionReads);
    testCheck(notification.testDescriptionReads == 1 && notification.testChildrenReads == 1,
              @"window pass reaches AX-only notification node once", notification.testDescriptionReads);
    testCheck([hue.testAttributes[NSAccessibilityDescriptionAttribute] isEqualToString:@"色相"],
              @"AX-only color text translated", hue.testDescriptionReads);
    testCheck([notification.testAttributes[NSAccessibilityDescriptionAttribute] isEqualToString:@"显示在左上角"],
              @"AX-only notification text translated", notification.testDescriptionReads);
    testCheck(RXHasHueFrame && NSEqualRects(RXHueFrame, hue.testFrame), @"Hue overlay frame captured", RXHasHueFrame);
    testCheck(RXHasNotificationFrame && NSEqualRects(RXNotificationFrame, notification.testFrame) &&
              [RXNotificationPositionText isEqualToString:@"显示在左上角"],
              @"notification overlay text and frame captured", RXHasNotificationFrame);

    // A malformed provider that returns itself as its child must terminate at
    // the existing production depth limit, rather than hang the main thread.
    TestAXElement *cycle = [TestAXElement new];
    cycle.testChildren = @[cycle];
    RXWalkAX(cycle, 0);
    testCheck(cycle.testChildrenReads == 21, @"cyclic AX provider stops after depths zero through twenty", cycle.testChildrenReads);
    cycle.testChildren = nil;
    RXWalkAX(nil, 0);
    RXWalkAX([NSObject new], 0);
    TestAXElement *beyondLimit = [TestAXElement new];
    RXWalkAX(beyondLimit, 21);
    testCheck(beyondLimit.testChildrenReads == 0 && beyondLimit.testDescriptionReads == 0,
              @"depth guard runs before accessing a provider", beyondLimit.testChildrenReads);

    NSUInteger serverChecksBefore = testChecks;
    NSArray *skippedFeatures = @[];
#if TEST_HAS_SERVER_COLLECTOR
    testModernServerCollector();
#else
    skippedFeatures = @[@"modern server access collector absent from historical production source"];
#endif
    NSDictionary *report = @{@"checks": @(testChecks), @"failures": testFailures,
        @"modern_server_checks": @(testChecks - serverChecksBefore), @"skipped_features": skippedFeatures,
        @"native_views": @(count), @"native_walk_AXChildren_reads": @(nativeChildrenReads),
        @"native_walk_description_reads": @(nativeNodeReads),
        @"after_window_walk_native_AXChildren_reads": @(finalNativeChildrenReads),
        @"cycle_AXChildren_reads": @(cycle.testChildrenReads),
        @"scope": @"production traversal functions; isolated AppKit objects; no window or app injection"};
    NSData *json = [NSJSONSerialization dataWithJSONObject:report options:NSJSONWritingPrettyPrinted error:NULL];
    fwrite(json.bytes, 1, json.length, stdout); putchar('\n');
    return testFailures.count ? 1 : 0;
}}
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=ROOT / 'RexZh.m')
    args = parser.parse_args()
    if sys.platform != 'darwin':
        parser.exit(2, 'Accessibility traversal tests require macOS and Xcode command-line tools.\n')
    source = args.source.resolve().read_text()
    automatic = '__attribute__((constructor)) static void RexChineseInstall(void)'
    if source.count(automatic) != 1:
        raise RuntimeError('Could not isolate the production automatic hook installer')
    source = source.replace(automatic, 'static void RexChineseInstall(void)', 1)
    has_server_collector = 'static BOOL RXCollectServerAccessFrame(id element, NSUInteger depth)' in source
    with tempfile.TemporaryDirectory(prefix='rex-accessibility-walk-') as directory:
        root = Path(directory)
        harness, executable = root / 'main.m', root / 'accessibility-walk'
        harness.write_text(f'#define TEST_HAS_SERVER_COLLECTOR {int(has_server_collector)}\n' + source + '\n' + RUNNER)
        subprocess.run(['xcrun', 'clang', '-fobjc-arc', '-fblocks', str(harness),
                        '-framework', 'AppKit', '-framework', 'CoreFoundation',
                        '-framework', 'CoreText', '-framework', 'QuartzCore',
                        '-o', str(executable)], check=True)
        result = subprocess.run([str(executable)], capture_output=True, text=True, timeout=30)
        if not result.stdout:
            if result.stderr:
                print(result.stderr, file=sys.stderr, end='')
            raise RuntimeError('Native traversal harness exited without a report')
        report = json.loads(result.stdout)
        print(json.dumps(report, ensure_ascii=False, indent=2))
        expected_server_checks = 40 if has_server_collector else 0
        if (report.get('checks') != 31 + expected_server_checks
                or report.get('modern_server_checks') != expected_server_checks
                or not isinstance(report.get('failures'), list)):
            raise RuntimeError('Native traversal harness did not execute every check')
        if result.stderr:
            print(result.stderr, file=sys.stderr, end='')
        return result.returncode


if __name__ == '__main__':
    raise SystemExit(main())
