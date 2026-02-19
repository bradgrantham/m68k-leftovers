.section .vectors, "a"
    .long   _stack_top
    .long   _start

    .section .text
    .global _start
_start:
    /* Zero .bss */
    lea     _bss_start, %a0
    lea     _bss_end, %a1
0:  cmp.l   %a1, %a0
    beq     1f
    clr.l   (%a0)+
    bra     0b
1:
    /* Copy .data from ROM to RAM if needed */
    lea     _data_load, %a0
    lea     _data_start, %a1
    lea     _data_end, %a2
2:  cmp.l   %a2, %a1
    beq     3f
    move.l  (%a0)+, (%a1)+
    bra     2b
3:
    /* Call global constructors */
    jsr     __libc_init_array

    /* Call main */
    jsr     main

    /* Call global destructors (if main returns) */
    jsr     __libc_fini_array

_halt:
    stop    #0x2700
    bra     _halt

.global _init
.global _fini
_init:
_fini:
    rts
