.text
addi x5, x0, 5
sw x0, 0(x0)

reset:
addi x5, x0, 0
addi x1,x0,1
addi x4, x0,1
nop
nop
loop:
    addi x1, x1, 1
    nop
    nop
    nop
    beq x1, x5, blink
    beq x0, x0, loop

blink:
    sw x4,0(x0)
    nop
    nop
    nop
    beq x0, x0, reset 