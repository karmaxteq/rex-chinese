#!/usr/bin/env python3
"""Compile and execute the Rex search ABI bridge without opening Rex."""
import os
from pathlib import Path
import platform
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'RexTextHook.swift'
SEARCH_C = ROOT / 'RexSearchHook.c'
DISPATCH_S = ROOT / 'RexSearchDispatch.S'
INTERPOSE_C = ROOT / 'RexTextHookInterpose.c'

GATE_FIXTURE = r'''
#include <mach-o/loader.h>
#include <mach/vm_prot.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

extern uintptr_t rxSearchTitleReturnPC;
extern uintptr_t rxValidatedSearchReturnPC(const struct mach_header_64 *);
extern void rxConfigurePaletteSearchForHeader(const struct mach_header_64 *);
extern const struct mach_header_64 *rxSelectMainExecutableHeader(uint32_t,
    const struct mach_header_64 *(*)(uint32_t));

static const struct mach_header_64 *inventory[4];
static const struct mach_header_64 *fixtureImageHeader(uint32_t index) {
  return index < 4 ? inventory[index] : NULL;
}

void rxSearchBridgeSetGate(uintptr_t value) { rxSearchTitleReturnPC = value; }

static struct mach_header_64 *fixture(int badUUID, int badCall) {
  const size_t callOffset = 0xb2758;
  struct mach_header_64 *header = calloc(1, callOffset + 4);
  if (!header) return NULL;
  header->magic = MH_MAGIC_64;
  header->cputype = CPU_TYPE_ARM64;
  header->cpusubtype = CPU_SUBTYPE_ARM64_ALL;
  header->filetype = MH_EXECUTE;
  header->ncmds = 2;
  header->sizeofcmds = sizeof(struct uuid_command) + sizeof(struct segment_command_64);
  struct uuid_command *uuid = (struct uuid_command *)(header + 1);
  const uint8_t expected[16] = {
    0xd2,0x29,0xe6,0xf2,0x6f,0xa4,0x3b,0xef,0x92,0x5d,0x8d,0x3f,0x8a,0x28,0x50,0x1b
  };
  uuid->cmd = LC_UUID;
  uuid->cmdsize = sizeof(*uuid);
  memcpy(uuid->uuid, expected, sizeof(expected));
  if (badUUID) uuid->uuid[0] ^= 1;
  struct segment_command_64 *text = (struct segment_command_64 *)(uuid + 1);
  text->cmd = LC_SEGMENT_64;
  text->cmdsize = sizeof(*text);
  memcpy(text->segname, "__TEXT", 7);
  text->vmaddr = UINT64_C(0x100000000);
  text->vmsize = callOffset + 4;
  text->filesize = callOffset + 4;
  text->initprot = VM_PROT_EXECUTE;
  const uint8_t call[4] = {0x4d, 0x6f, 0x48, 0x94};
  memcpy((uint8_t *)header + callOffset, call, sizeof(call));
  if (badCall) ((uint8_t *)header)[callOffset] ^= 1;
  return header;
}

int rxSearchBridgeGateValidation(void) {
  struct mach_header_64 *good = fixture(0, 0);
  struct mach_header_64 *wrongUUID = fixture(1, 0);
  struct mach_header_64 *wrongCall = fixture(0, 1);
  if (!good || !wrongUUID || !wrongCall) return 10;
  struct mach_header_64 inserted = { .magic = MH_MAGIC_64, .filetype = MH_DYLIB };
  struct mach_header_64 secondMain = { .magic = MH_MAGIC_64, .filetype = MH_EXECUTE };
  inventory[0] = &inserted; inventory[1] = good; inventory[2] = NULL;
  int failed = rxSelectMainExecutableHeader(3, fixtureImageHeader) != good;
  inventory[0] = good; inventory[1] = &secondMain;
  failed |= rxSelectMainExecutableHeader(2, fixtureImageHeader) != NULL ||
      rxSelectMainExecutableHeader(0, fixtureImageHeader) ||
      rxSelectMainExecutableHeader(4097, fixtureImageHeader) ||
      rxSelectMainExecutableHeader(2, NULL) ||
      !rxValidatedSearchReturnPC(good) ||
      rxValidatedSearchReturnPC(wrongUUID) || rxValidatedSearchReturnPC(wrongCall);
  if (!failed) {
    pid_t child = fork();
    if (child == 0) {
      rxConfigurePaletteSearchForHeader(wrongCall);
      _exit(70);
    }
    int status = 0;
    if (child < 0 || waitpid(child, &status, 0) != child || !WIFSIGNALED(status)) failed = 1;
  }
  free(good);
  free(wrongUUID);
  free(wrongCall);
  rxSearchTitleReturnPC = 0;
  return failed ? 1 : 0;
}
'''

CALLER_FIXTURE = r'''
#if defined(__arm64__)
  .section __TEXT,__text,regular,pure_instructions
  .globl _rxSearchBridgeExactCall
  .p2align 2
_rxSearchBridgeExactCall:
  stp x29, x30, [sp, #-16]!
  mov x29, sp
  bl _rxHookSearchLowercased
Lafter:
  ldp x29, x30, [sp], #16
  ret
  .globl _rxSearchBridgeExactReturnPC
  .p2align 2
_rxSearchBridgeExactReturnPC:
  adrp x0, Lafter@PAGE
  add x0, x0, Lafter@PAGEOFF
  ret
#elif defined(__x86_64__)
  .section __TEXT,__text,regular,pure_instructions
  .globl _rxSearchBridgeExactCall
  .p2align 4, 0x90
_rxSearchBridgeExactCall:
  subq $8, %rsp
  callq _rxHookSearchLowercased
Lafter:
  addq $8, %rsp
  retq
  .globl _rxSearchBridgeExactReturnPC
  .p2align 4, 0x90
_rxSearchBridgeExactReturnPC:
  leaq Lafter(%rip), %rax
  retq
#else
#error unsupported architecture
#endif
'''

RUNNER = r'''
import Darwin

@_silgen_name("rxSearchBridgeSetGate") func setGate(_ value: UInt)
@_silgen_name("rxSearchBridgeGateValidation") func gateValidation() -> Int32
@_silgen_name("rxSearchBridgeExactReturnPC") func exactReturnPC() -> UInt
@_silgen_name("rxSearchBridgeExactCall")
func exactTitle(_ value: consuming String, _ weight: Double) -> (String, Double)
@_silgen_name("rxHookSearchLowercased")
func normalLowercased(_ value: borrowing String) -> String

@main
struct SearchBridgeRunner {
  static func require(_ condition: @autoclosure () -> Bool, _ message: String) {
    if !condition() { fputs("FAIL: \(message)\n", stderr); exit(1) }
  }

  static func main() {
    require(gateValidation() == 0, "gate rejects known UUID with bad call bytes")
    setGate(exactReturnPC())
    let titleInputs = [
      ("Settings", "Settings 设置"),
      ("Search commands…", "Search commands… 搜索命令…"),
      ("你好😀", "你好😀"),
      ("/tmp/Filter/Settings.txt", "/tmp/Filter/Settings.txt"),
      (String(repeating: "unknown-😀/", count: 200), String(repeating: "unknown-😀/", count: 200)),
    ]
    var retained: [String] = []
    for (index, fixture) in titleInputs.enumerated() {
      let weight = Double(index) + 0.625
      let output = exactTitle(fixture.0, weight)
      require(output.0 == fixture.1, "title output \(index)")
      require(output.1 == weight, "title weight \(index)")
      retained.append(output.0)
    }
    // Construct, rather than spell as a literal, a known long title. Keep an
    // independently retained copy alive across the consuming title path.
    let knownLong = [
      "Search every action and the keys bound to it, ",
      "and record, remove, or reset shortcuts."
    ].joined()
    let knownLongCopy = knownLong
    require(knownLong.utf8.count > 15, "known long title is heap-sized")
    let knownLongOutput = exactTitle(knownLong, 91.875)
    require(knownLongOutput.0 == knownLongCopy + " 搜索所有操作及其绑定的按键，并记录、移除或重置快捷键。",
            "dynamic known long title alias")
    require(knownLongOutput.1 == 91.875, "dynamic known long title weight")
    require(knownLongCopy == [
      "Search every action and the keys bound to it, ",
      "and record, remove, or reset shortcuts."
    ].joined(), "retained input copy survives consuming title path")
    retained.append(knownLongOutput.0)
    retained.removeAll()

    // A non-matching return PC must leave ordinary lowercased callers on the
    // native path; their borrowing input remains usable after the call.
    setGate(exactReturnPC() &+ 1)
    let normalInputs = ["MiXeD", "你好ABC😀", "/tmp/Filter/Settings.txt", String(repeating: "AbC😀", count: 200)]
    for input in normalInputs {
      let before = input
      let output = normalLowercased(input)
      require(output == before.lowercased(), "normal lowercased output")
      require(input == before, "normal lowercased retains borrowing input")
    }
    setGate(0)
    print("search bridge: title ownership/weight, native fallback, and gate rejection PASS")
  }
}
'''


def run(*command, **kwargs):
    subprocess.run(command, check=True, **kwargs)


def compile_object(arch, source, output, sdkroot):
    run('xcrun', 'clang', '-arch', arch, '-isysroot', sdkroot,
        '-mmacosx-version-min=13.0', '-O2', '-c', str(source), '-o', str(output))


def main():
    if not all(path.is_file() for path in (SOURCE, SEARCH_C, DISPATCH_S, INTERPOSE_C)):
        raise SystemExit('FAIL: production search bridge sources are missing')
    sdkroot = subprocess.check_output(['xcrun', '--sdk', 'macosx', '--show-sdk-path'], text=True).strip()
    native_arch = platform.machine()
    if native_arch not in ('arm64', 'x86_64'):
        raise SystemExit(f'FAIL: unsupported native architecture {native_arch}')
    with tempfile.TemporaryDirectory(prefix='rex-search-bridge-') as directory:
        tmp = Path(directory)
        for arch in ('arm64', 'x86_64'):
            compile_object(arch, SEARCH_C, tmp / f'search-{arch}.o', sdkroot)
            compile_object(arch, DISPATCH_S, tmp / f'dispatch-{arch}.o', sdkroot)
        (tmp / 'gate.c').write_text(GATE_FIXTURE)
        (tmp / 'caller.S').write_text(CALLER_FIXTURE)
        (tmp / 'runner.swift').write_text(RUNNER)
        getters, marker, _ = INTERPOSE_C.read_text().partition('__attribute__((used))')
        if not marker:
            raise SystemExit('FAIL: production interpose table marker is missing')
        (tmp / 'getters.c').write_text(getters)
        compile_object(native_arch, tmp / 'gate.c', tmp / 'gate.o', sdkroot)
        compile_object(native_arch, tmp / 'caller.S', tmp / 'caller.o', sdkroot)
        compile_object(native_arch, tmp / 'getters.c', tmp / 'getters.o', sdkroot)
        executable = tmp / 'runner'
        run('xcrun', 'swiftc', '-target', f'{native_arch}-apple-macos13.0', '-O',
            str(SOURCE), str(tmp / 'runner.swift'), str(tmp / f'search-{native_arch}.o'), str(tmp / f'dispatch-{native_arch}.o'),
            str(tmp / 'gate.o'), str(tmp / 'caller.o'), str(tmp / 'getters.o'), '-o', str(executable))
        result = subprocess.run([str(executable)], env={**os.environ, 'MallocScribble': '1'},
                                text=True, capture_output=True, timeout=60)
        print(result.stdout.strip())
        if result.stderr:
            print(result.stderr.strip())
        if result.returncode:
            raise SystemExit(f'FAIL: native search bridge exit {result.returncode}')
        if 'search bridge: title ownership/weight, native fallback, and gate rejection PASS' not in result.stdout:
            raise SystemExit('FAIL: native search bridge did not reach its completion marker')
    print('search bridge assembly: arm64/x86_64 compiled; native executable PASS')


if __name__ == '__main__':
    main()
