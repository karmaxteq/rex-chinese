#!/usr/bin/env python3
"""Exercise production translation caching without injecting or opening Rex.

The extracted production translation block is compiled with an NSCache subclass
that observes real cache calls. Only the uncached-body entry receives a test
counter; no production instrumentation or altered translation rules are used.
NSCache limits are advisory, so eviction is tested by explicitly clearing it.
"""
import argparse
import json
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
PREFIX = r'''
#import <Foundation/Foundation.h>
#include <stdatomic.h>
static _Atomic unsigned long uncachedCalls;
static _Atomic unsigned long cacheSets;
static _Atomic unsigned long mutableEntries;
static NSCache *observedCache;
@interface ObservedCache<KeyType, ObjectType> : NSCache<KeyType, ObjectType>
@end
@implementation ObservedCache
- (instancetype)init {
    if ((self = [super init])) observedCache = self;
    return self;
}
- (void)setObject:(id)object forKey:(id)key cost:(NSUInteger)cost {
    atomic_fetch_add(&cacheSets, 1);
    // Immutable CF-backed NSString instances can inherit NSMutableString.
    // A real mutable string's copy is distinct; an immutable copy is stable.
    if ([key copy] != key || [object copy] != object)
        atomic_fetch_add(&mutableEntries, 1);
    [super setObject:object forKey:key cost:cost];
}
@end
#define NSCache ObservedCache
'''
RUNNER = r'''
#undef NSCache
static NSMutableArray *failures;
static NSUInteger checks;
static void check(BOOL condition, NSString *name) {
    checks++;
    if (!condition) [failures addObject:name];
}
static unsigned long calls(void) { return atomic_load(&uncachedCalls); }
static BOOL rejectsMutation(NSString *value) {
    NSString *before = [value copy];
    @try { [(NSMutableString *)value appendString:@"-mutation-probe"]; }
    @catch (NSException *exception) { return [value isEqualToString:before]; }
    return NO;
}
int main(void) { @autoreleasepool {
    failures = [NSMutableArray array];
    check(RXTranslate(nil) == nil, @"nil passes through");
    id nonString = @42;
    check((id)RXTranslate(nonString) == nonString, @"non-string passes through");
    check([RXTranslate(@"") isEqualToString:@""], @"empty string preserved");
    NSMutableString *empty = [NSMutableString string];
    NSString *emptyResult = RXTranslate(empty);
    [empty appendString:@"mutated"];
    check([emptyResult isEqualToString:@""], @"empty mutable result is a snapshot");

    unsigned long start = calls();
    check([RXTranslate(@"91 results") isEqualToString:@"91 项结果"], @"dynamic output");
    unsigned long warm = calls();
    for (NSUInteger i = 0; i < 100; i++) RXTranslate(@"91 results");
    check(warm > start && calls() == warm, @"dynamic result cached across repeated calls");

    start = calls();
    check([RXTranslate(@"cache-probe-unknown") isEqualToString:@"cache-probe-unknown"], @"unknown output unchanged");
    warm = calls();
    for (NSUInteger i = 0; i < 100; i++) RXTranslate(@"cache-probe-unknown");
    check(warm > start && calls() == warm, @"negative result cached across repeated calls");

    NSMutableString *mutable = [NSMutableString stringWithString:@"mutable-cache-probe"];
    NSString *retained = RXTranslate(mutable);
    [mutable setString:@"Filter"];
    check([retained isEqualToString:@"mutable-cache-probe"], @"returned value survives source mutation");
    check([RXTranslate(mutable) isEqualToString:@"筛选"], @"mutated source uses its new content");
    start = calls();
    check([RXTranslate(@"mutable-cache-probe") isEqualToString:@"mutable-cache-probe"] && calls() == start,
          @"old cache key remains intact without recomputation");
    check(rejectsMutation(retained), @"returned snapshot rejects mutation");
    check(atomic_load(&mutableEntries) == 0, @"cache stores immutable keys and values");

    NSString *recursive = @"See the keys bound to Toggle Activity and where each came from.";
    check([RXTranslate(recursive) isEqualToString:@"查看绑定到 切换活动 的按键及其来源。"], @"recursive translation finishes");
    warm = calls(); RXTranslate(recursive);
    check(calls() == warm, @"recursive outer result cached");
    check([RXTranslate(RXTranslate(recursive)) isEqualToString:RXTranslate(recursive)], @"recursive output remains idempotent");

    NSString *longInput = [@"long-untranslated-payload-" stringByPaddingToLength:16384 withString:@"z" startingAtIndex:0];
    unsigned long sets = atomic_load(&cacheSets);
    start = calls();
    check([RXTranslate(longInput) isEqualToString:longInput], @"long input output unchanged");
    RXTranslate(longInput);
    check(calls() == start + 2, @"long input bypasses memoization");
    check(atomic_load(&cacheSets) == sets, @"long input not retained in cache");
    check(observedCache != nil && observedCache.countLimit > 0 && observedCache.countLimit <= 1024,
          @"cache has finite advisory entry limit");
    check(observedCache.totalCostLimit > 0 && observedCache.totalCostLimit <= 1024 * 1024,
          @"cache has finite advisory cost limit");

    RXTranslate(@"explicit-eviction-probe");
    [observedCache removeAllObjects];
    start = calls();
    check([RXTranslate(@"explicit-eviction-probe") isEqualToString:@"explicit-eviction-probe"] && calls() > start,
          @"evicted content recomputes correctly");

    __block _Atomic unsigned long threadFailures = 0;
    dispatch_apply(8, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(size_t worker) {
        @autoreleasepool {
            for (NSUInteger i = 0; i < 2000; i++) {
                NSString *input = [NSString stringWithFormat:@"%lu results", (unsigned long)(worker * 2000 + i)];
                NSString *expected = [NSString stringWithFormat:@"%lu 项结果", (unsigned long)(worker * 2000 + i)];
                if (![RXTranslate(input) isEqualToString:expected]) atomic_fetch_add(&threadFailures, 1);
                NSMutableString *sharedContent = [NSMutableString stringWithString:@"concurrent-unknown"];
                NSString *output = RXTranslate(sharedContent);
                [sharedContent appendString:@"-changed"];
                if (![output isEqualToString:@"concurrent-unknown"]) atomic_fetch_add(&threadFailures, 1);
            }
        }
    });
    check(atomic_load(&threadFailures) == 0, @"eight concurrent workers preserve translations and snapshots");
    check(atomic_load(&mutableEntries) == 0, @"concurrent cache writes remain immutable");
    NSDictionary *report = @{@"checks": @(checks), @"failures": failures,
        @"concurrent_iterations": @16000, @"uncached_calls": @(calls()),
        @"cache_writes": @(atomic_load(&cacheSets)),
        @"limits_are_advisory": @YES};
    NSData *data = [NSJSONSerialization dataWithJSONObject:report options:NSJSONWritingPrettyPrinted error:NULL];
    fwrite(data.bytes, 1, data.length, stdout); putchar('\n');
    return failures.count ? 1 : 0;
} }
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=ROOT / 'RexZh.m')
    args = parser.parse_args()
    if sys.platform != 'darwin':
        parser.exit(2, 'Translation cache tests require macOS and Xcode command-line tools.\n')
    source = args.source.read_text()
    start = source.index('static NSString *RXTranslate(')
    end = source.index('\nstatic CFStringRef (*RXOriginalCFBundleCopyLocalizedString)', start)
    block = source[start:end]
    target = 'static NSString *RXTranslateUncached(NSString *s) {'
    if target not in block:
        target = 'static NSString *RXTranslate(NSString *s) {'
    if block.count(target) != 1:
        raise RuntimeError('Expected exactly one production uncached translation body')
    block = block.replace(target, target + '\n    atomic_fetch_add(&uncachedCalls, 1);', 1)
    with tempfile.TemporaryDirectory(prefix='rex-translation-cache-') as directory:
        root = Path(directory)
        main = root / 'main.m'
        main.write_text(PREFIX + block + RUNNER)
        executable = root / 'cache-test'
        subprocess.run(['xcrun', 'clang', '-O2', '-fobjc-arc', '-fblocks', str(main),
                        '-framework', 'Foundation', '-o', str(executable)], check=True)
        result = subprocess.run([str(executable)], text=True, capture_output=True, timeout=60)
        if not result.stdout:
            raise RuntimeError('Native cache harness did not produce a report: ' + result.stderr)
        report = json.loads(result.stdout)
        if report.get('checks') != 24 or report.get('concurrent_iterations') != 16000:
            raise RuntimeError('Native cache harness did not execute all assertions')
        print(json.dumps(report, ensure_ascii=False, indent=2))
        if result.stderr:
            print(result.stderr, file=sys.stderr, end='')
        return result.returncode


if __name__ == '__main__':
    raise SystemExit(main())
