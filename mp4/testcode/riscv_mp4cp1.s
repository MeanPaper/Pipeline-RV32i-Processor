.align 4
.section .text
.globl _start
    # Refer to the RISC-V ISA Spec for the functionality of
    # the instructions in this test program.
_start:
    # la x2, threshold
    auipc x2, 0
    nop
    nop
    nop
    
    # lw x1, (x2)
    addi x2, x2, 120
    addi x1, x1, 120
    addi x3, x3, 120
    nop
    nop
    nop
    add x4, x3, x2

    lw x1, (x2)
    nop
    nop
    nop
    nop
    nop

    add x3, x1, x2
    nop
    nop
    nop
    nop
       
    # addi x2, x2, 3 
    # mv x7, x4
    
    li  t0, 1
    # # add   t0, x0, 1
    la  t1, tohost
    # auipc t1, 0 
    # nop
    # nop
    # nop
    # nop

    # addi t1, t1, 48
    # nop
    # nop
    # nop
    # nop
    sw  t0, 0(t1)
    sw  x0, 4(t1)
halt:                 # Infinite loop to keep the processor
    beq x0, x0, halt  # from trying to execute the data below.
                      # Your own programs should also make use
                      # of an infinite loop at the end.

.section .rodata

bad:        .word 0xdeadbeef
threshold:  .word 0x00000010
result:     .word 0x00000000
good:       .word 0x600d600d

.section ".tohost"
.globl tohost
tohost: .dword 0
.section ".fromhost"
.globl fromhost
fromhost: .dword 0
