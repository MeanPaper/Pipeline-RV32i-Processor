.align 4
.section .text
.globl _start
    # Refer to the RISC-V ISA Spec for the functionality of
    # the instructions in this test program.
_start:
    la x31, threshold
    nop
    nop
    nop
    nop
    nop
    lw x1, (x31)
    nop
    nop
    nop
    nop
    nop    
    # lw x2, bad    
    # lw x3, result       
    # lw x4, good
    # nop
    # nop
    # nop
    # nop
    add x3, x1, x2
    nop
    nop
    nop
    nop
    nop   
    # addi x2, x2, 3 
    # mv x7, x4



    li  t0, 1
    la  t1, tohost
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