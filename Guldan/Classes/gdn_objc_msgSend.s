//
//  gdn_objc_msgSend.s
//  Pods
//
//  Created by Alex023 on 2021/11/15.
//

#if defined(__arm64__)
.text

.align 4

/**
 * store registers
 **/
.macro GDN_STORE_REGISTERS

stp    fp, lr, [sp, #-0x10]!
mov    fp, sp
sub    sp, sp, #(10*8 + 8*16)
stp    x0, x1, [sp, #(8*16+0*8)]
stp    x2, x3, [sp, #(8*16+2*8)]
stp    x4, x5, [sp, #(8*16+4*8)]
stp    x6, x7, [sp, #(8*16+6*8)]
str    x8,     [sp, #(8*16+8*8)]

.endm

/**
 * load registers
 **/
.macro GDN_LOAD_REGISTERS

ldp    x0, x1, [sp, #(8*16+0*8)]
ldp    x2, x3, [sp, #(8*16+2*8)]
ldp    x4, x5, [sp, #(8*16+4*8)]
ldp    x6, x7, [sp, #(8*16+6*8)]
ldr    x8,     [sp, #(8*16+8*8)]
mov    sp, fp
ldp    fp, lr, [sp], #0x10

.endm

.globl _gdn_objc_msgSend
_gdn_objc_msgSend:

GDN_STORE_REGISTERS
bl      _needs_profiler
cbnz    x0, GDN_NEEDS_PROFILER

GDN_LOAD_REGISTERS
adrp        x9, _origin_objc_msgSend@PAGE
add     x9, x9, _origin_objc_msgSend@PAGEOFF
ldr     x9, [x9]
br      x9

GDN_NEEDS_PROFILER:
ldp     x0, x1, [fp, #-0x50]
ldr     x2, [fp, #0x8]
bl      _pre_objc_msgSend

GDN_LOAD_REGISTERS
adrp        x9, _origin_objc_msgSend@PAGE
add     x9, x9, _origin_objc_msgSend@PAGEOFF
ldr     x9, [x9]
blr     x9

GDN_STORE_REGISTERS
bl      _post_objc_msgSend
mov     x9, x0
GDN_LOAD_REGISTERS
// 恢复lr
mov     lr, x9
ret

#endif
