#!/usr/bin/env python3
"""Run production AX receiver dispatch and walker fallback in an isolated process.

Only the installer constructor attribute is removed. Captured original IMPs are
replaced by probes that record the actual receiver, so old unsafe dispatch fails
assertions without invoking an incompatible AppKit implementation or opening UI.
"""
import argparse
import json
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
RUNNER = r'''
static NSMutableArray *failures;
static NSUInteger checks, viewCalls, elementCalls, incompatibleCalls;
static id lastReceiver;
static NSString *lastAttribute;
static void check(BOOL ok, NSString *name) {
    checks++;
    if (!ok) [failures addObject:name];
}
static id viewProbe(id self, SEL cmd, NSString *attribute) {
    viewCalls++; lastReceiver = self; lastAttribute = attribute;
    if (![self isKindOfClass:NSView.class]) incompatibleCalls++;
    return @"view-raw";
}
static id elementProbe(id self, SEL cmd, NSString *attribute) {
    elementCalls++; lastReceiver = self; lastAttribute = attribute;
    if (![self isKindOfClass:NSAccessibilityElement.class]) incompatibleCalls++;
    return @"element-raw";
}
@interface GuardView : NSView @end
@implementation GuardView @end
@interface GuardElement : NSAccessibilityElement @end
@implementation GuardElement
- (id)accessibilityAttributeValue:(NSString *)attribute { return nil; }
@end
@interface GuardVirtualNode : NSObject
@property(nonatomic, strong) NSMutableDictionary *attributes;
@property(nonatomic, copy) NSArray *children;
@property(nonatomic) NSUInteger reads;
@end
@implementation GuardVirtualNode
- (instancetype)init {
    if ((self = [super init])) _attributes = [NSMutableDictionary dictionary];
    return self;
}
- (id)accessibilityAttributeValue:(NSString *)attribute {
    self.reads++;
    return [attribute isEqualToString:NSAccessibilityChildrenAttribute] ? self.children : self.attributes[attribute];
}
- (void)accessibilitySetValue:(id)value forAttribute:(NSString *)attribute { self.attributes[attribute] = value; }
- (NSRect)accessibilityFrame { return NSMakeRect(3, 4, 100, 18); }
@end
@interface GuardHookedNode : GuardVirtualNode @end
@implementation GuardHookedNode @end
@interface GuardHookedChildNode : GuardHookedNode @end
@implementation GuardHookedChildNode @end
@interface GuardCell : NSCell @end
@implementation GuardCell
- (id)accessibilityAttributeValue:(NSString *)attribute { return @"cell"; }
@end
int main(void) { @autoreleasepool {
    failures = [NSMutableArray array];
    origAccessibilityValue = (IMP)viewProbe;
    origAXElementAttribute = (IMP)elementProbe;
    check(RXRawAXValue(nil, @"AXProbe") == nil && viewCalls == 0 && elementCalls == 0, @"nil dispatches neither original IMP");
    for (NSView *view in @[[NSView new], [GuardView new]]) {
        NSUInteger before = viewCalls;
        check([RXRawAXValue(view, @"AXProbe") isEqual:@"view-raw"] && viewCalls == before + 1,
              @"NSView and subclass retain view original path");
        check(lastReceiver == view && [lastAttribute isEqual:@"AXProbe"], @"view probe receives exact receiver and attribute");
    }
    for (NSAccessibilityElement *element in @[[NSAccessibilityElement new], [GuardElement new]]) {
        NSUInteger before = elementCalls;
        check([RXRawAXValue(element, @"AXProbe") isEqual:@"element-raw"] && elementCalls == before + 1,
              @"NSAccessibilityElement and subclass retain element original path");
        check(lastReceiver == element && [lastAttribute isEqual:@"AXProbe"], @"element probe receives exact receiver and attribute");
    }
    for (id object in @[[NSObject new], [GuardVirtualNode new], [NSCell new], [GuardCell new]]) {
        NSUInteger before = elementCalls + viewCalls;
        check(RXRawAXValue(object, @"AXProbe") == nil && elementCalls + viewCalls == before,
              [@"unrelated receiver bypasses captured IMP: " stringByAppendingString:NSStringFromClass([object class])]);
    }
    origAccessibilityValue = NULL;
    check(RXRawAXValue([GuardView new], @"AXProbe") == nil,
          @"missing view original does not fall through to element IMP");
    origAXElementAttribute = NULL;
    check(RXRawAXValue([GuardElement new], @"AXProbe") == nil, @"missing element original returns nil");
    origAccessibilityValue = (IMP)viewProbe;
    origAXElementAttribute = (IMP)elementProbe;
    GuardVirtualNode *root = [GuardVirtualNode new];
    GuardVirtualNode *child = [GuardVirtualNode new];
    root.children = @[child];
    root.attributes[NSAccessibilityHelpAttribute] = @"Save";
    child.attributes[NSAccessibilityHelpAttribute] = @"Hue";
    RXHasHueFrame = NO;
    NSUInteger before = elementCalls;
    RXWalkAX(root, 0);
    check([root.attributes[NSAccessibilityHelpAttribute] isEqual:RXTranslate(@"Save")],
          @"walker translates legacy virtual node through existing value fallback");
    check([child.attributes[NSAccessibilityHelpAttribute] isEqual:RXTranslate(@"Hue")] && child.reads > 0,
          @"walker retains child traversal and fallback translation");
    check(RXHasHueFrame && NSEqualRects(RXHueFrame, child.accessibilityFrame),
          @"raw text frame detection falls back to provider value");
    check(elementCalls == before, @"walker never calls element original on NSObject virtual nodes");
    RXWalkAX(nil, 0);
    check(incompatibleCalls == 0, @"no captured original sees incompatible receiver");

    // Real SwiftUI AX nodes inherit NSObject and their installed getter already
    // translates strings. Preserve the per-class original, not an AppKit IMP.
    SEL selector = @selector(accessibilityAttributeValue:);
    IMP virtualOriginal = class_getMethodImplementation(GuardVirtualNode.class, selector);
    RXSwiftNodeOriginals = [NSMutableDictionary dictionary];
    RXSwiftNodeOriginals[[NSString stringWithFormat:@"%p:%s", GuardHookedNode.class,
        sel_getName(selector)]] = [NSValue valueWithPointer:virtualOriginal];
    Method virtualMethod = class_getInstanceMethod(GuardVirtualNode.class, selector);
    class_addMethod(GuardHookedNode.class, selector, (IMP)RXSwiftAttribute,
                    method_getTypeEncoding(virtualMethod));
    NSMutableArray *nodes = [NSMutableArray array];
    for (NSString *text in @[@"Hue", @"Chroma", @"Lightness", @"Save"]) {
        GuardHookedNode *node = nodes.count % 2 ? [GuardHookedChildNode new] : [GuardHookedNode new];
        node.attributes[NSAccessibilityHelpAttribute] = text;
        check([[node accessibilityAttributeValue:NSAccessibilityHelpAttribute] isEqual:RXTranslate(text)],
              @"production SwiftUI getter is installed and returns the translation");
        check([RXRawAXValue(node, NSAccessibilityHelpAttribute) isEqual:text],
              @"raw SwiftUI getter resolves matching class or superclass original");
        [nodes addObject:node];
    }
    root.children = nodes;
    RXHasHueFrame = RXHasChromaFrame = RXHasLightnessFrame = RXHasRemoteSaveFrame = NO;
    before = elementCalls + viewCalls;
    RXWalkAX(root, 0);
    check(RXHasHueFrame && NSEqualRects(RXHueFrame, [nodes[0] accessibilityFrame]),
          @"hooked SwiftUI Hue retains raw frame detection");
    check(RXHasChromaFrame && NSEqualRects(RXChromaFrame, [nodes[1] accessibilityFrame]),
          @"hooked SwiftUI Chroma retains raw frame detection");
    check(RXHasLightnessFrame && NSEqualRects(RXLightnessFrame, [nodes[2] accessibilityFrame]),
          @"hooked SwiftUI Lightness retains raw frame detection");
    check(RXHasRemoteSaveFrame && NSEqualRects(RXRemoteSaveFrame, [nodes[3] accessibilityFrame]),
          @"hooked SwiftUI Save retains raw frame detection");
    for (NSUInteger i = 0; i < nodes.count; i++) {
        check([[(GuardHookedNode *)nodes[i] attributes][NSAccessibilityHelpAttribute]
                isEqual:@[@"Hue", @"Chroma", @"Lightness", @"Save"][i]],
              @"walker preserves original provider text behind translated getter");
    }
    check(elementCalls + viewCalls == before && incompatibleCalls == 0,
          @"hooked virtual nodes never dispatch incompatible AppKit originals");
    NSDictionary *report = @{@"checks": @(checks), @"failures": failures,
        @"incompatible_original_calls": @(incompatibleCalls),
        @"scope": @"production raw receiver dispatch and walker; no app injection or windows"};
    NSData *data = [NSJSONSerialization dataWithJSONObject:report options:NSJSONWritingPrettyPrinted error:NULL];
    fwrite(data.bytes, 1, data.length, stdout); putchar('\n');
    return failures.count ? 1 : 0;
}}
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=ROOT / 'RexZh.m')
    args = parser.parse_args()
    if sys.platform != 'darwin':
        parser.exit(2, 'Requires macOS and Xcode command-line tools.\n')
    source = args.source.read_text()
    constructor = '__attribute__((constructor)) static void RexChineseInstall(void)'
    if source.count(constructor) != 1:
        raise RuntimeError('Expected one automatic hook installer')
    source = source.replace(constructor, 'static void RexChineseInstall(void)', 1)
    with tempfile.TemporaryDirectory(prefix='rex-raw-ax-receiver-') as directory:
        root = Path(directory)
        harness, executable = root / 'main.m', root / 'raw-ax-receiver'
        harness.write_text(source + '\n' + RUNNER)
        subprocess.run(['xcrun', 'clang', '-fobjc-arc', '-fblocks', str(harness),
                        '-framework', 'AppKit', '-framework', 'CoreFoundation',
                        '-framework', 'CoreText', '-framework', 'QuartzCore',
                        '-o', str(executable)], check=True)
        result = subprocess.run([str(executable)], capture_output=True, text=True, timeout=30)
        if result.stderr:
            print(result.stderr, file=sys.stderr, end='')
        if not result.stdout:
            raise RuntimeError('Native receiver harness did not produce a report')
        report = json.loads(result.stdout)
        if report.get('checks') != 37 or not isinstance(report.get('failures'), list):
            raise RuntimeError('Native receiver harness did not execute every check')
        print(json.dumps(report, ensure_ascii=False, indent=2))
        return result.returncode


if __name__ == '__main__':
    raise SystemExit(main())
