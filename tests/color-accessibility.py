#!/usr/bin/env python3
"""Exercise contextual color AX getter hooks without app injection or windows.

Compile the real production source with only its automatic installer disabled.
Raw fixture providers retain English storage; assertions call production getters
and independently check Chinese labels, unchanged values and receiver safety.
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
static NSUInteger checks, incompatibleCalls, rawReads, roleReads;
static char storageKey;
static void check(BOOL ok, NSString *name) {
    checks++;
    if (!ok) [failures addObject:name];
}
@interface ColorFixtureView : NSView @end
@implementation ColorFixtureView @end
@interface ColorFixtureElement : NSAccessibilityElement @end
@implementation ColorFixtureElement
- (id)accessibilityAttributeValue:(NSString *)attribute { return nil; }
@end
@interface ColorFixtureSwift : NSObject @end
@implementation ColorFixtureSwift @end
static NSMutableDictionary *storage(id object) { return objc_getAssociatedObject(object, &storageKey); }
static id provider(id self, SEL selector, NSString *attribute) {
    rawReads++;
    if ([attribute isEqual:NSAccessibilityRoleAttribute]) roleReads++;
    return storage(self)[attribute];
}
static id viewProvider(id self, SEL selector, NSString *attribute) {
    if (![self isKindOfClass:NSView.class]) incompatibleCalls++;
    return provider(self, selector, attribute);
}
static id elementProvider(id self, SEL selector, NSString *attribute) {
    if (![self isKindOfClass:NSAccessibilityElement.class]) incompatibleCalls++;
    return provider(self, selector, attribute);
}
static id modernProvider(id self, SEL selector) {
    NSString *attribute = selector == @selector(accessibilityLabel) ? @"AXLabel" :
        selector == @selector(accessibilityDescription) ? NSAccessibilityDescriptionAttribute :
        selector == @selector(accessibilityTitle) ? NSAccessibilityTitleAttribute :
        selector == @selector(accessibilityValueDescription) ? NSAccessibilityValueDescriptionAttribute :
        NSAccessibilityValueAttribute;
    return provider(self, selector, attribute);
}
static id makeNode(Class cls, NSString *role, NSString *description) {
    id node = [cls new];
    NSMutableDictionary *attributes = [@{NSAccessibilityRoleAttribute: role,
        NSAccessibilityDescriptionAttribute: description,
        @"AXLabel": description, NSAccessibilityTitleAttribute: description,
        NSAccessibilityHelpAttribute: @"Click to choose a color.",
        NSAccessibilityPlaceholderValueAttribute: @"#RRGGBB",
        NSAccessibilityValueAttribute: @"Unedited"} mutableCopy];
    objc_setAssociatedObject(node, &storageKey, attributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return node;
}
static id legacy(id node, NSString *attribute) {
    if ([node isKindOfClass:ColorFixtureView.class])
        return RXAccessibilityAttributeValue(node, @selector(accessibilityAttributeValue:), attribute);
    if ([node isKindOfClass:ColorFixtureElement.class])
        return RXAXElementAttribute(node, @selector(accessibilityAttributeValue:), attribute);
    return RXSwiftAttribute(node, @selector(accessibilityAttributeValue:), attribute);
}
static id modern(id node, SEL selector) {
    if ([node isKindOfClass:ColorFixtureView.class]) {
        if (selector == @selector(accessibilityLabel)) return RXViewAccessibilityLabel(node, selector);
        if (selector == @selector(accessibilityTitle)) return RXViewAccessibilityTitle(node, selector);
        if (selector == @selector(accessibilityDescription)) return RXViewAccessibilityDescription(node, selector);
        if (selector == @selector(accessibilityValueDescription)) return RXViewAccessibilityValueDescription(node, selector);
        return RXViewAccessibilityValue(node, selector);
    }
    if ([node isKindOfClass:ColorFixtureElement.class]) return RXAXElementObject(node, selector);
    if (selector == @selector(accessibilityLabel)) return RXSwiftLabel(node, selector);
    if (selector == @selector(accessibilityDescription)) return RXSwiftDescription(node, selector);
    if (selector == @selector(accessibilityValueDescription)) return RXSwiftValueDescription(node, selector);
    return RXSwiftValue(node, selector);
}
static void configureOriginals(void) {
    origAccessibilityValue = (IMP)viewProvider;
    origAXElementAttribute = (IMP)elementProvider;
    origViewAccessibilityLabelGetter = origViewAccessibilityTitleGetter =
        origViewAccessibilityDescriptionGetter = origViewAccessibilityValueGetter =
        origViewAccessibilityValueDescriptionGetter = (IMP)modernProvider;
    origAXElementLabel = origAXElementTitle = origAXElementDescription =
        origAXElementValue = (IMP)modernProvider;
    RXSwiftNodeOriginals = [NSMutableDictionary dictionary];
    SEL selectors[] = {@selector(accessibilityAttributeValue:), @selector(accessibilityLabel),
        @selector(accessibilityDescription), @selector(accessibilityValue), @selector(accessibilityValueDescription)};
    for (NSUInteger i = 0; i < sizeof(selectors) / sizeof(selectors[0]); i++) {
        NSString *key = [NSString stringWithFormat:@"%p:%s", ColorFixtureSwift.class, sel_getName(selectors[i])];
        RXSwiftNodeOriginals[key] = [NSValue valueWithPointer:i ? (IMP)modernProvider : (IMP)provider];
    }
}
int main(void) { @autoreleasepool {
    failures = [NSMutableArray array]; configureOriginals();
    NSArray *classes = @[ColorFixtureView.class, ColorFixtureElement.class, ColorFixtureSwift.class];
    for (Class cls in classes) {
        for (NSUInteger number = 16; number <= 255; number++) {
            NSString *raw = [NSString stringWithFormat:@"Color #%lu", (unsigned long)number];
            NSString *expected = [NSString stringWithFormat:@"颜色 #%lu", (unsigned long)number];
            id well = makeNode(cls, NSAccessibilityColorWellRole, raw);
            NSDictionary *before = [storage(well) copy];
            check([legacy(well, NSAccessibilityDescriptionAttribute) isEqual:expected], @"all 240 generated well descriptions");
            check([modern(well, @selector(accessibilityLabel)) isEqual:expected], @"all 240 modern generated well labels");
            check([legacy(well, NSAccessibilityValueAttribute) isEqual:@"未编辑"], @"all 240 generated well states");
            check([modern(well, @selector(accessibilityValue)) isEqual:@"未编辑"], @"all 240 modern generated well states");
            check([RXRawAXValue(well, NSAccessibilityDescriptionAttribute) isEqual:raw], @"raw well provider bypasses translation");
            check([storage(well) isEqual:before], @"all 240 raw well storages unchanged");
            for (NSString *role in @[NSAccessibilityTextFieldRole, NSAccessibilityTextAreaRole]) {
                for (NSString *wrapped in @[[NSString stringWithFormat:@"Hex value for %@", raw],
                                            [raw stringByAppendingString:@"的十六进制值"]]) {
                    id field = makeNode(cls, role, wrapped);
                    storage(field)[NSAccessibilityValueAttribute] = @"#F5F5F5";
                    NSDictionary *beforeField = [storage(field) copy];
                    NSString *expectedField = [expected stringByAppendingString:@"的十六进制值"];
                    check([legacy(field, NSAccessibilityDescriptionAttribute) isEqual:expectedField], @"all 240 hex wrappers and roles");
                    check([modern(field, @selector(accessibilityDescription)) isEqual:expectedField], @"all 240 modern hex wrappers");
                    check([legacy(field, NSAccessibilityValueAttribute) isEqual:@"#F5F5F5"], @"actual hex value unchanged");
                    check([storage(field) isEqual:beforeField], @"hex wrapper original storage unchanged");
                }
            }
        }
        NSArray *invalid = @[@"Color #0", @"Color #15", @"Color #256", @"Color #-16", @"Color #016",
            @"Color #16 ", @"Color #16.example", @"Color #16/Settings", @"/tmp/Color #16", @"my Color #16",
            @"Color #16 color", @"Color #１６", @"Color #16\n", @"Color #9999999999999999999999999"];
        for (NSString *text in invalid) {
            id node = makeNode(cls, NSAccessibilityColorWellRole, text);
            check([legacy(node, NSAccessibilityDescriptionAttribute) isEqual:text], @"malformed/out-of-range/generated-label negatives");
            check([legacy(node, NSAccessibilityValueAttribute) isEqual:@"Unedited"], @"state rejected without canonical generated label");
        }
        for (NSString *role in @[NSAccessibilityButtonRole, NSAccessibilityStaticTextRole, NSAccessibilityUnknownRole]) {
            id node = makeNode(cls, role, @"Color #232");
            check([legacy(node, NSAccessibilityDescriptionAttribute) isEqual:@"Color #232"], @"wrong role does not translate generated-shaped name");
            check([modern(node, @selector(accessibilityLabel)) isEqual:@"Color #232"], @"wrong modern role preserves name");
            check([legacy(node, NSAccessibilityValueAttribute) isEqual:@"Unedited"], @"wrong role preserves state-shaped user value");
        }
        id unrelated = makeNode(cls, NSAccessibilityColorWellRole, @"Color #232");
        storage(unrelated)[NSAccessibilityHelpAttribute] = @"User-defined color";
        check([legacy(unrelated, NSAccessibilityDescriptionAttribute) isEqual:@"Color #232"], @"arbitrary color well name preserved without generated help");
        check([legacy(unrelated, NSAccessibilityValueAttribute) isEqual:@"Unedited"], @"arbitrary color well state preserved without generated help");
        id field = makeNode(cls, NSAccessibilityTextFieldRole, @"Hex value for Color #232");
        storage(field)[NSAccessibilityPlaceholderValueAttribute] = @"Name";
        check([legacy(field, NSAccessibilityDescriptionAttribute) isEqual:@"Hex value for Color #232"], @"arbitrary named text field is not a hex editor");
        storage(field)[NSAccessibilityPlaceholderValueAttribute] = @"#RRGGBB";
        for (NSString *value in @[@"Color #232", @"Unedited", @"Hex value for Color #232", @"Color #232的十六进制值", @"/tmp/Color #232", @"中文 😀"] ) {
            storage(field)[NSAccessibilityValueAttribute] = value;
            check([legacy(field, NSAccessibilityValueAttribute) isEqual:value], @"legacy editable user text preserved");
            check([modern(field, @selector(accessibilityValue)) isEqual:value], @"modern editable user text preserved");
        }
        for (id role in @[NSNull.null, @17]) {
            id node = makeNode(cls, NSAccessibilityColorWellRole, @"Color #232");
            if (role == NSNull.null) [storage(node) removeObjectForKey:NSAccessibilityRoleAttribute];
            else storage(node)[NSAccessibilityRoleAttribute] = role;
            check([legacy(node, NSAccessibilityDescriptionAttribute) isEqual:@"Color #232"], @"missing/non-string raw role rejected");
            check([legacy(node, NSAccessibilityValueAttribute) isEqual:@"Unedited"], @"missing/non-string raw role preserves state");
        }
        id noStatus = makeNode(cls, NSAccessibilityColorWellRole, @"Color #232");
        for (id value in @[@17, NSNull.null]) {
            storage(noStatus)[NSAccessibilityValueAttribute] = value;
            check(legacy(noStatus, NSAccessibilityValueAttribute) == value, @"non-string values remain original objects");
        }
        [storage(noStatus) removeObjectForKey:NSAccessibilityValueAttribute];
        check(legacy(noStatus, NSAccessibilityValueAttribute) == nil, @"nil values preserved");
        check([modern(noStatus, @selector(accessibilityDescription)) isEqual:@"颜色 #232"], @"missing state does not prevent generated description");
        id plain = makeNode(cls, NSAccessibilityStaticTextRole, @"Unrelated status");
        NSUInteger beforeRoles = roleReads;
        check([legacy(plain, NSAccessibilityDescriptionAttribute) isEqual:@"Unrelated status"], @"unrelated text preserved");
        check(roleReads == beforeRoles, @"unrelated strings prefiltered before raw role lookup");
        for (NSString *attribute in @[NSAccessibilityHelpAttribute, NSAccessibilityPlaceholderValueAttribute]) {
            storage(plain)[attribute] = @"Color #232";
            check([legacy(plain, attribute) isEqual:@"Color #232"], @"non-description attributes preserve generated-shaped text");
        }
        check([RXTranslate(@"Color #232") isEqual:@"Color #232"] && [RXTranslate(@"Unedited") isEqual:@"Unedited"],
              @"generic translator never receives color or state rules");
    }
    check(incompatibleCalls == 0, @"raw lookup never invokes incompatible AppKit original");
    NSDictionary *report = @{@"checks": @(checks), @"failures": failures,
        @"canonical_indices": @240, @"provider_kinds": @3, @"incompatible_original_calls": @(incompatibleCalls),
        @"raw_reads": @(rawReads), @"role_reads": @(roleReads),
        @"scope": @"production AX getter functions and raw providers; no app injection or windows"};
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
        raise RuntimeError('Expected exactly one automatic hook installer')
    source = source.replace(constructor, 'static void RexChineseInstall(void)', 1)
    with tempfile.TemporaryDirectory(prefix='rex-color-accessibility-') as directory:
        root = Path(directory)
        harness, executable = root / 'main.m', root / 'color-accessibility'
        harness.write_text(source + '\n' + RUNNER)
        subprocess.run(['xcrun', 'clang', '-fobjc-arc', '-fblocks', str(harness),
                        '-framework', 'AppKit', '-framework', 'CoreFoundation',
                        '-framework', 'CoreText', '-framework', 'QuartzCore',
                        '-o', str(executable)], check=True)
        result = subprocess.run([str(executable)], capture_output=True, text=True, timeout=30)
        if result.stderr:
            print(result.stderr, file=sys.stderr, end='')
        if not result.stdout:
            raise RuntimeError('Native color AX harness did not produce a report')
        report = json.loads(result.stdout)
        if report.get('checks') != 16036 or report.get('canonical_indices') != 240 or not isinstance(report.get('failures'), list):
            raise RuntimeError('Native color AX harness did not execute expected fixtures')
        print(json.dumps(report, ensure_ascii=False, indent=2))
        return result.returncode


if __name__ == '__main__':
    raise SystemExit(main())
