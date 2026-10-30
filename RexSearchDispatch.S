#if defined(__arm64__)
  .section __TEXT,__text,regular,pure_instructions
  .globl _rxHookSearchLowercased
  .p2align 2
_rxHookSearchLowercased:
  // x30 is the original caller's post-BL PC. x9 is caller-saved and does not
  // overlap String's x0/x1 or the title field's d0.
  adrp x9, _rxSearchTitleReturnPC@PAGE
  ldr x9, [x9, _rxSearchTitleReturnPC@PAGEOFF]
  cbz x9, Lnative
  cmp x30, x9
  b.ne Lnative
  b _rxHookSearchTitleField
Lnative:
  b _$sSS10lowercasedSSyF
#elif defined(__x86_64__)
  .section __TEXT,__text,regular,pure_instructions
  .globl _rxHookSearchLowercased
  .p2align 4, 0x90
_rxHookSearchLowercased:
  // (%rsp) is the original return PC. r11 is caller-saved and does not
  // overlap String's rdi/rsi or the title field's xmm0.
  movq _rxSearchTitleReturnPC(%rip), %r11
  testq %r11, %r11
  je Lnative
  cmpq %r11, (%rsp)
  jne Lnative
  jmp _rxHookSearchTitleField
Lnative:
  jmp _$sSS10lowercasedSSyF
#else
#error "RexSearchDispatch supports only arm64 and x86_64"
#endif
