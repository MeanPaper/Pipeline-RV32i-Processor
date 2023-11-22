.align 4
.section .text
.globl _start

_start:
    # andi x1, x1, 0      # clear x1
    # andi x2, x2, 0      # clear x2
    # addi x1, x1, -1     # x1 = -1
    # addi x2, x2, -1     # x2 = -1, however, I will fake this to unsigned
    # mulhsu x3, x1, x2   # check the behavior

    # andi x1, x1, 0      # clear x1
    # andi x2, x2, 0      # clear x2
    # addi x1, x1, -1     # x1 = -1
    # addi x2, x2, 2      # x2 = 2, however, I will fake this to unsigned
    # mulhsu x3, x1, x2   # check the behavior

    # andi x1, x1, 0      # clear x1
    # andi x2, x2, 0      # clear x2
    # addi x1, x1, 2     # x1 = -1
    # addi x2, x2, 2      # x2 = 2, however, I will fake this to unsigned
    # mulhsu x3, x1, x2   # check the behavior


    # andi x1, x1, 0      # clear x1
    # andi x2, x2, 0      # clear x2
    # addi x1, x1, -1     # x1 = -1
    # addi x2, x2, 2      # x2 = 2, however, I will fake this to unsigned
    # mulh x3, x1, x2   # check the behavior

    # andi x1, x1, 0      # clear x1
    # andi x2, x2, 0      # clear x2
    # addi x1, x1, -1     # x1 = -1
    # addi x2, x2, 2      # x2 = 2, however, I will fake this to unsigned
    # mul  x3, x1, x2   # check the behavior


    # andi x1, x1, 0      # clear x1
    # andi x2, x2, 0      # clear x2
    # addi x1, x1, -1     # x1 = -1
    # addi x2, x2, 2      # x2 = 2, however, I will fake this to unsigned
    # mulhu  x3, x1, x2   # check the behavior


    

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