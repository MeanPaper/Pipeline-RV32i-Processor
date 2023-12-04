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


    andi x1, x1, 0      # clear x1
    andi x2, x2, 0      # clear x2
    andi x6, x6, 0
    addi x6, x6, 10
    addi x1, x1, -10       
    addi x2, x2, 10    

    mul x3, x1, x2        # check the behavior
    addi x1, x3, 0        # x1 = -100 mini range 

    mul x3, x6, x2  
    addi x2, x3, 0       # x2 = 100 max range

    # initialization
    # addi x4, x1, 0      # outter loop
    # addi x5, x1, 0      # inner loop
    
# loop_outter:
#     beq x4, x2, loop_outter_end

# loop_inner:
#     beq x5, x2, loop_inner_end
#     mulhsu x3, x5, x4
#     addi x5, x5, 1
#     j loop_inner
# loop_inner_end:

#     addi x5, x1, 0      # recover x5 to -10000 for another loop
#     addi x4, x4, 1      # outter loop + 1
#     j loop_outter
# loop_outter_end:


## remu checking
    # addi x4, x0, 1
    # addi x5, x0, 1

    addi x4, x1, 0      # outter loop
    addi x5, x1, 0      # inner loop
loop_outter:
    beq x4, x2, loop_outter_end

loop_inner:
    beq x5, x2, loop_inner_end
    rem x3, x5, x4
    addi x5, x5, 1
    j loop_inner
loop_inner_end:

    # addi x5, x0, 1      # recover x5 to -10000 for another loop
    addi x5, x1, 0
    addi x4, x4, 1      # outter loop + 1
    j loop_outter
loop_outter_end:




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


    # andi x1, x1, 0      # clear x1
    # andi x2, x2, 0      # clear x2
    # addi x1, x1, -2     # 
    # addi x2, x2, 3      #
    # rem  x3, x1, x2     # x3 = x1 % x2


    # andi x1, x1, 0      # clear x1
    # andi x2, x2, 0      # clear x2
    # addi x1, x1, 3     # 
    # addi x2, x2, -2      #
    # rem  x3, x1, x2     # x3 = x1 % x2
    
    # andi x1, x1, 0      # clear x1
    # andi x2, x2, 0      # clear x2
    # addi x1, x1, 2       # 
    # addi x2, x2, -1      #
    # div  x3, x1, x2     # x3 = x1 / x2


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