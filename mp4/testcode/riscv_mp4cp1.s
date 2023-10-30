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
    nop
    
    # lw x1, (x2)
    addi x2, x2, 132
    addi x1, x1, 120
    addi x3, x3, 120
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
    addi t1, t1, 84     # 20
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
