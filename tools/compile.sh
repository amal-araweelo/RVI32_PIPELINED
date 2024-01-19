#!/bin/bash 

PROGRAM="$1"

# if program ends in .s
if [[ $PROGRAM == *.s ]]; then
	riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -c $PROGRAM -o $PROGRAM.o
	riscv64-unknown-elf-objdump -d $PROGRAM.o
else
	# if program ends in .c
	riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -S -c $PROGRAM -o $PROGRAM.s
	riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -c $PROGRAM.s -o $PROGRAM.o
	riscv64-unknown-elf-objdump -d $PROGRAM.o
fi

# Get $PROGRAM.bin from $PROGRAM.o using objcopy
riscv64-unknown-elf-objcopy -O binary $PROGRAM.o $PROGRAM.bin
