addi x1, x0, 0
addi x2, x0, 5
addi x3, x0, 0
addi x4, x0, 3

reset:
    addi x1, x0, 0
    addi x3, x3, 1
loop:
    addi x1, x1, 1
    bne x1, x2, loop
    bne x3, x4, reset
