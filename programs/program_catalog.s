# PROGRAM CATALOGUE
# setup
    li x18, 0x00000000    # load LED addr
    li x19, 0x00000004    # load SW addr
    li x28, 1
    li x29, 2
    nop
    addi x5, x0, 0        # x5 is temp reg to hold sw values
    lw   x5, 0(x19)       # load sw values
    beq x5, x0, SWtoLED    # SW = 0 - SW to LED demo
    beq x5, x28, FancyBlink
    beq x5, x29, Fibonnaci


# SW to LED demo
SWtoLED:
    addi x3, x0, 0       # x3 is temp reg to move value 
    
    loop:
    lw x3, 0(x19)         # load value from switches
    nop
    sw x3, 0(x18)         # write value to led's
    nop
    beq x0, x0, loop    

### Led blinky time 2.0
FancyBlink:
addi x1, x0, 0    #LED storage location
addi x2, x0, 0
addi x3, x0, 0
lui x3, 8        #Max blink value (2^^15)
addi x3, x3, 0    #Max blink value (2^^15)
addi x4, x0, 0     #Counter for waitloop
lui x5, 12207      #989680 is 10'000'000 (should make waitloop half sec bc 2 instr)
addi x5, x5, 128    #989680 is 10'000'000 (should make waitloop half sec bc 2 instr)

reset:
addi x2, x0, 1    #LED value
sw x2, 0(x1)
beq x0, x0, waitloop

blinkloop:
addi x4, x0, 0
slli x2, x2, 1
sw x2, 0(x1)
beq x0, x0, waitloop

waitloop:        #Loop to slow down execution speed
addi x4, x4, 1
bne x4, x5, waitloop
addi x4, x0, 0
beq x2, x3, reset
beq x0, x0, blinkloop

# FIBONNACI
Fibonnaci:
addi x1, x0, 1
addi x2, x0, 0
li x3, 0xB520 #highest fibbonaci number below limit
li x4, 0x00000000 #address of fibbonaci storage
addi x5, x0, 1

addi x10, x0, 0     #counter for waitloop
lui x11, 12207         #waitloop maxval 50mio
addi x11, x11, 128     #waitloop maxval 50mio

restart:
sw x0, 0(x4)
addi x6, x0, 0
loopup:
    add x2, x1, x2
    add x6, x2, x0
    sw x2, 0(x4)
    
    beq x2, x3, loopdown
    beq x0, x0, waitloopup
loopup1:
    
    add x1, x1, x2
    add x6, x1, x0
    sw x1, 0(x4)
    
    beq x0, x0, waitloopup1
    
loopdown:
    
    sub x2, x2, x1
    beq x1, x5, restart
    add x6, x1, x0
    sw x1, 0(x4)
    beq x0, x0, waitloopdown
loopdown1:    
    sub x1, x1, x2
    add x6, x2, x0
    sw x2, 0(x4)
    
    beq x0, x0, waitloopdown1
    
waitloopup:        #Loop to slow down execution speed
addi x10, x10, 1
bne x10, x11, waitloopup
addi x10, x0, 0
beq x0, x0, loopup1

waitloopup1:        #Loop to slow down execution speed
addi x10, x10, 1
bne x10, x11, waitloopup1
addi x10, x0, 0
beq x0, x0, loopup

waitloopdown:        #Loop to slow down execution speed
addi x10, x10, 1
bne x10, x11, waitloopdown
addi x10, x0, 0
beq x0, x0, loopdown1

waitloopdown1:        #Loop to slow down execution speed
addi x10, x10, 1
bne x10, x11, waitloopdown1
addi x10, x0, 0
beq x0, x0, loopdown
 