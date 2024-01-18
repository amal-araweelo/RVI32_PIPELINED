# fibonnaci
addi x1, x0, 1
addi x2, x0, 0
li x3, 0xB520 #highest fibbonaci number below limit
li x4, 0x10000018 #address of fibbonaci storage
addi x5, x0, 1

restart:
sw x0, 0(x4)
addi x6, x0, 0
loopup:
    add x2, x1, x2
    add x6, x2, x0
    sw x2, 0(x4)
    
    beq x2, x3, loopdown
    
    add x1, x1, x2
    add x6, x1, x0
    sw x1, 0(x4)
    
    beq x0, x0, loopup
loopdown:
    
    sub x2, x2, x1
    beq x1, x5, restart
    add x6, x1, x0
    sw x1, 0(x4)
    
    sub x1, x1, x2
    add x6, x2, x0
    sw x2, 0(x4)
    
    beq x0, x0, loopdown