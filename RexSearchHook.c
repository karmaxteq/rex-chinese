// Rex 1408 candidate-title bridge. The guarded binary patch reuses an existing
// imported String.lowercased() stub. The assembly dispatcher keeps that public
// two-word Swift ABI intact, tail-routing only its one verified title call to
// the correctly typed field helper below.
#include <mach-o/dyld.h>
#include <mach-o/loader.h>
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#define RX_SWIFT_CC __attribute__((swiftcall))
typedef struct { uintptr_t word0, word1; } RXSearchString;
typedef struct { uintptr_t word0, word1; double weight; } RXSearchField;

extern RXSearchString rxSearchTitle(RXSearchString value) RX_SWIFT_CC;
extern RXSearchString rxNativeLowercased(RXSearchString value) RX_SWIFT_CC
    __asm__("_$sSS10lowercasedSSyF");

// Hidden linkage allows the isolated ABI fixture to exercise the real return
// address dispatch without weakening the installed dylib's validation.
__attribute__((visibility("hidden"))) uintptr_t rxSearchTitleReturnPC;

#define RX_MAX_LOAD_COMMAND_BYTES (UINT32_C(1024) * UINT32_C(1024))
#define RX_MAX_DYLD_IMAGES UINT32_C(4096)

static int RXHasSaneLoadCommands(const struct mach_header_64 *header) {
    return header && header->magic == MH_MAGIC_64 && header->filetype == MH_EXECUTE &&
        header->sizeofcmds <= RX_MAX_LOAD_COMMAND_BYTES &&
        header->ncmds <= header->sizeofcmds / sizeof(struct load_command);
}

typedef const struct mach_header_64 *(*RXImageHeaderAtIndex)(uint32_t);

// DYLD_INSERT_LIBRARIES can make image zero an inserted dylib. Select the one
// and only executable image instead of assuming dyld's image-table order.
__attribute__((visibility("hidden"))) const struct mach_header_64 *
rxSelectMainExecutableHeader(uint32_t count, RXImageHeaderAtIndex imageHeaderAtIndex) {
    if (!imageHeaderAtIndex || count == 0 || count > RX_MAX_DYLD_IMAGES) return NULL;
    const struct mach_header_64 *main = NULL;
    for (uint32_t index = 0; index < count; index++) {
        const struct mach_header_64 *header = imageHeaderAtIndex(index);
        if (!header || header->magic != MH_MAGIC_64) continue;
        if (header->filetype != MH_EXECUTE) continue;
        if (main) return NULL;
        main = header;
    }
    return main;
}

static const struct mach_header_64 *RXLoadedImageHeaderAtIndex(uint32_t index) {
    return (const struct mach_header_64 *)_dyld_get_image_header(index);
}

static const struct mach_header_64 *RXLoadedMainExecutableHeader(void) {
    return rxSelectMainExecutableHeader(_dyld_image_count(), RXLoadedImageHeaderAtIndex);
}

static int RXMainHeaderHasSupportedUUID(const struct mach_header_64 *header) {
    static const uint8_t armUUID[16] = {
        0xd2,0x29,0xe6,0xf2,0x6f,0xa4,0x3b,0xef,0x92,0x5d,0x8d,0x3f,0x8a,0x28,0x50,0x1b
    };
    static const uint8_t intelUUID[16] = {
        0x41,0x3c,0x17,0x7a,0xf1,0xbf,0x39,0x80,0xba,0x9e,0xf3,0x18,0x86,0x64,0x9f,0x5c
    };
    if (!RXHasSaneLoadCommands(header)) return 0;
    const uint8_t *cursor = (const uint8_t *)(header + 1);
    const uint8_t *end = cursor + header->sizeofcmds;
    for (uint32_t index = 0; index < header->ncmds; index++) {
        if ((size_t)(end - cursor) < sizeof(struct load_command)) return 0;
        const struct load_command *command = (const struct load_command *)cursor;
        if (command->cmdsize < sizeof *command || command->cmdsize % 8 ||
            command->cmdsize > (size_t)(end - cursor)) return 0;
        if (command->cmd == LC_UUID && command->cmdsize == sizeof(struct uuid_command)) {
            const uint8_t *uuid = ((const struct uuid_command *)command)->uuid;
            if (memcmp(uuid, armUUID, sizeof armUUID) == 0 ||
                memcmp(uuid, intelUUID, sizeof intelUUID) == 0) return 1;
        }
        cursor += command->cmdsize;
    }
    return 0;
}

__attribute__((visibility("hidden"))) uintptr_t rxValidatedSearchReturnPC(const struct mach_header_64 *header) {
    if (!RXHasSaneLoadCommands(header)) return 0;
    static const uint8_t armUUID[16] = {
        0xd2,0x29,0xe6,0xf2,0x6f,0xa4,0x3b,0xef,0x92,0x5d,0x8d,0x3f,0x8a,0x28,0x50,0x1b
    };
    static const uint8_t intelUUID[16] = {
        0x41,0x3c,0x17,0x7a,0xf1,0xbf,0x39,0x80,0xba,0x9e,0xf3,0x18,0x86,0x64,0x9f,0x5c
    };
    const uint8_t *expectedUUID;
    const uint8_t *instruction;
    size_t instructionSize;
    uintptr_t callOffset;
    static const uint8_t armCall[] = {0x4d,0x6f,0x48,0x94};
    static const uint8_t intelCall[] = {0xe8,0xa4,0xc2,0x5e,0x01};
    if (header->cputype == CPU_TYPE_ARM64 && header->cpusubtype == CPU_SUBTYPE_ARM64_ALL) {
        expectedUUID = armUUID; instruction = armCall; instructionSize = sizeof armCall; callOffset = 0xb2758;
    } else if (header->cputype == CPU_TYPE_X86_64 && header->cpusubtype == CPU_SUBTYPE_X86_64_ALL) {
        expectedUUID = intelUUID; instruction = intelCall; instructionSize = sizeof intelCall; callOffset = 0xc0061;
    } else return 0;
    const uint8_t *cursor = (const uint8_t *)(header + 1);
    const uint8_t *end = cursor + header->sizeofcmds;
    unsigned uuidCount = 0;
    int matchingUUID = 0, matchingText = 0;
    for (uint32_t index = 0; index < header->ncmds; index++) {
        if ((size_t)(end - cursor) < sizeof(struct load_command)) return 0;
        const struct load_command *command = (const struct load_command *)cursor;
        if (command->cmdsize < sizeof *command || command->cmdsize % 8 ||
            command->cmdsize > (size_t)(end - cursor)) return 0;
        if (command->cmd == LC_UUID) {
            if (command->cmdsize != sizeof(struct uuid_command)) return 0;
            uuidCount++;
            matchingUUID = memcmp(((const struct uuid_command *)command)->uuid, expectedUUID, 16) == 0;
        } else if (command->cmd == LC_SEGMENT_64) {
            if (command->cmdsize < sizeof(struct segment_command_64)) return 0;
            const struct segment_command_64 *segment = (const struct segment_command_64 *)command;
            if (memcmp(segment->segname, "__TEXT\0", 7) == 0 && segment->vmaddr == UINT64_C(0x100000000) &&
                segment->fileoff == 0 && segment->vmsize >= callOffset + instructionSize &&
                segment->filesize >= callOffset + instructionSize && (segment->initprot & VM_PROT_EXECUTE)) matchingText++;
        }
        cursor += command->cmdsize;
    }
    if (cursor != end || uuidCount != 1 || !matchingUUID || matchingText != 1 ||
        memcmp((const uint8_t *)header + callOffset, instruction, instructionSize) != 0) return 0;
    return (uintptr_t)header + callOffset + instructionSize;
}

__attribute__((visibility("hidden"))) void rxConfigurePaletteSearchForHeader(const struct mach_header_64 *header) {
    rxSearchTitleReturnPC = rxValidatedSearchReturnPC(header);
    if (RXMainHeaderHasSupportedUUID(header) && !rxSearchTitleReturnPC) {
        static const char message[] = "Rex search hook validation failed for supported Rex 1408 image\n";
        (void)write(STDERR_FILENO, message, sizeof message - 1);
        abort();
    }
}

__attribute__((constructor)) static void RXConfigurePaletteSearch(void) {
    rxConfigurePaletteSearchForHeader(RXLoadedMainExecutableHeader());
}

// This is reached only from Rex's verified (String, Double) title call. Its
// consuming Swift helper receives the retained input and returns a separately
// owned String; preserve the caller's field weight across that helper call.
RXSearchField rxHookSearchTitleField(RXSearchString value, double weight) RX_SWIFT_CC
    __attribute__((noinline));
RXSearchField rxHookSearchTitleField(RXSearchString value, double weight) {
    RXSearchString expanded = rxSearchTitle(value);
    return (RXSearchField){expanded.word0, expanded.word1, weight};
}

// Defined in RexSearchDispatch.S. Its deliberately opaque declaration keeps
// the interpose table from imposing a mismatched C/Swift function type.
extern void rxHookSearchLowercased(void);

__attribute__((used)) static struct {
    const void *replacement;
    const void *replacee;
} rx_search_interpose[] __attribute__((section("__DATA,__interpose"))) = {
    {(const void *)rxHookSearchLowercased, (const void *)rxNativeLowercased}
};
