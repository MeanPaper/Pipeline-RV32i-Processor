.align 4

.section .rodata

a:          .word 0x900d900d     # 52
ab:         .word 0x00000010     # 56
abc:        .word 0x00000000     # 60
abcd:       .word 0x600d600d     # 64

.section .text
.globl _start
    # Refer to the RISC-V ISA Spec for the functionality of
    # the instructions in this test program.
_start:
    # la x2, threshold
    auipc x2, 0
    auipc x10, 0
    auipc x1, 0
    addi x3, x3, 100
    addi x4, x4, 128
    nop
    nop
    nop
    nop
    add x4, x3, x4
    lh   x13, (x10)
    lh   x11, 2(x10)
    lb   x12, -1(x10)
    nop
    nop
    nop
    sb  x4, 228(x2) 
    sw  x10, 232(x2)
    sh  x10, 242(x2)
    # sw
    # sh


    # lw x1, (x2)
    not  x1, x1
    xor  x3, x3, x3
    addi x8, x8, 1
    addi x4, x4, 1
    addi x2, x2, 132
    addi x1, x1, 120
    addi x3, x3, 120
    and  x9, x9, 0
    or   x8, x8, 1
    nop
    nop
    nop
    nop
    add x4, x3, x2
    nop
    lw x1, (x2) # strange rd_wdata error
    nop
    nop
    nop
    nop
    add x3, x1, x2
    # nop
    # nop
    # nop
    # nop
       
    # addi x2, x2, 3 
    # addi x4, x5, 0    
    # nop
    # nop
    # nop
    # nop


    # for golden spike to stall
    li  t0, 1     
    # la  t1, tohost
    auipc t1, 0         # 0
    nop                 # 4
    nop                 # 8
    nop                 # 12
    nop                 # 16
    addi t1, t1, 100    # 20 used to be 84
    nop                 # 24
    nop                 # 28
    nop                 # 32
    nop                 # 36
    sw  t0, 0(t1)       # 40
    sw  x0, 4(t1)       # 44
halt:                 # Infinite loop to keep the processor
    beq x0, x0, halt  # from trying to execute the data below.   # 48
                      # Your own programs should also make use
                      # of an infinite loop at the end.

.section .rodata

bad:        .word 0xdeadbeef     # 52
threshold:  .word 0x00000010     # 56
result:     .word 0x00000000     # 60
good:       .word 0x600d600d     # 64

.section ".tohost"
.globl tohost
tohost: .dword 0                 # 68
.section ".fromhost"
.globl fromhost
fromhost: .dword 0
