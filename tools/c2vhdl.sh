#!/bin/bash

PROGRAM=$1

riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -S -c $PROGRAM -o $PROGRAM.s
riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -c $PROGRAM.s -o $PROGRAM.o
riscv64-unknown-elf-objdump -d $PROGRAM.o | ./objdmp2vhdl.sh
