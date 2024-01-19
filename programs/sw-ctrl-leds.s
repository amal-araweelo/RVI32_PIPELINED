# SW to LED demo
    .text
    li x1, 0x00000000    # load LED addr
    li x2, 0x00000004    # load SW addr
    addi x3, x0, 0       # x3 is temp reg to move value 
    
    loop:
    lw x3, 0(x2)         # load value from switches
    nop
    sw x3, 0(x1)         # write value to led's
    nop
    beq x0, x0, loop
