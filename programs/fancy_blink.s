    ### Led blinky time 2.0
addi x1, x0, 0    #LED storage location
addi x2, x0, 0
addi x3, x0, 0
lui x3, 8        #Max blink value (2^^15)
addi x3, x3, 0    #Max blink value (2^^15)
addi x4, x0, 0     #Counter for waitloop
lui x5,12207      #989680 is 10'000'000 (should make waitloop half sec bc 2 instr)
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
 