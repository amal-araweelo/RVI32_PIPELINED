.text
reset:
    addi x1, x0, 0
    addi x2, x0, 1
    addi x3, x0, 5
    nop
    nop
    nop
    sw x2,0(x0)
    nop
    nop
    nop

loop:
    nop
    nop
    addi x1,x1,1
    nop
    nop
    nop
    beq x1, x3, blink
    beq x0, x0, loop

blink:
    lw x2, 0(x0)
    nop
    nop
    nop
    addi x2,x0,0
    beq x0,x0,reset

