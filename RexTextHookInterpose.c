#include <stddef.h>

extern void rxHookLKLiteral(void *, void *, void *) __asm__("_rxHookLKLiteral");
extern void rxHookLKInit(void *, void *, void *) __asm__("_rxHookLKInit");
extern void rxHookLR(void *, void *, void *) __asm__("_rxHookLR");
extern void originalLKLiteral(void *, void *, void *) __asm__("_$s7SwiftUI18LocalizedStringKeyV13stringLiteralACSS_tcfC");
extern void originalLKInit(void *, void *, void *) __asm__("_$s7SwiftUI18LocalizedStringKeyVyACSScfC");
extern void rxHookLKAppendLiteral(void *, void *, void *) __asm__("_rxHookLKAppendLiteral");
extern void originalLKAppendLiteral(void *, void *, void *) __asm__("_$s7SwiftUI18LocalizedStringKeyV0D13InterpolationV13appendLiteralyySSF");
extern void originalLR(void *, void *, void *) __asm__("_$s10Foundation23LocalizedStringResourceV13stringLiteralACSS_tcfC");
extern void rxHookTextVerbatim(void *, void *, void *) __asm__("_rxHookTextVerbatim");
extern void originalTextVerbatim(void *, void *, void *) __asm__("_$s7SwiftUI4TextV8verbatimACSS_tcfC");
extern void rxHookTextLocalizedResource(void *, void *, void *) __asm__("_rxHookTextLocalizedResource");
extern void originalTextLocalizedResource(void *, void *, void *) __asm__("_$s7SwiftUI4TextVyAC10Foundation23LocalizedStringResourceVcfC");
extern void rxHookTextAttributedString(void *, void *, void *) __asm__("_rxHookTextAttributedString");
extern void originalTextAttributedString(void *, void *, void *) __asm__("_$s7SwiftUI4TextVyAC10Foundation16AttributedStringVcfC");
extern void rxHookTextGeneric(void *, void *, void *, void *, void *) __asm__("_rxHookTextGeneric");
extern void originalTextGeneric(void *, void *, void *, void *, void *) __asm__("_$s7SwiftUI4TextVyACxcSyRzlufC");

void *rxOrigLKLiteralAddress(void) { return (void *)originalLKLiteral; }
void *rxOrigLKInitAddress(void) { return (void *)originalLKInit; }
void *rxOrigLKAppendLiteralAddress(void) { return (void *)originalLKAppendLiteral; }
void *rxOrigTextVerbatimAddress(void) { return (void *)originalTextVerbatim; }
void *rxOrigTextLocalizedResourceAddress(void) { return (void *)originalTextLocalizedResource; }
void *rxOrigTextAttributedStringAddress(void) { return (void *)originalTextAttributedString; }

__attribute__((used)) static struct {
    const void *replacement;
    const void *replacee;
} rx_interpose[] __attribute__((section("__DATA,__interpose"))) = {
    { (const void *)rxHookLKLiteral, (const void *)originalLKLiteral },
    { (const void *)rxHookLKInit, (const void *)originalLKInit },
    { (const void *)rxHookLKAppendLiteral, (const void *)originalLKAppendLiteral },
    { (const void *)rxHookLR, (const void *)originalLR },
    { (const void *)rxHookTextVerbatim, (const void *)originalTextVerbatim },
    { (const void *)rxHookTextLocalizedResource, (const void *)originalTextLocalizedResource },
    { (const void *)rxHookTextAttributedString, (const void *)originalTextAttributedString },
    { (const void *)rxHookTextGeneric, (const void *)originalTextGeneric },
};
