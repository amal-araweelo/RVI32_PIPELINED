# PROGRAM CATALOGUE
# setup
    li x18, 0x00000000    # load LED addr
    li x19, 0x00000004    # load SW addr
    li x28, 1
    nop
    addi x5, x0, 0        # x5 is temp reg to hold sw values
    lw   x5, 0(x19)       # load sw values
    beq x5, x0, SWtoLED    # SW = 0 - SW to LED demo
    beq x5, x28, FancyBlink


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
 