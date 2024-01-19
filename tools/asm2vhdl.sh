#!/bin/bash

N_LINE=0

ASM_FILE=$1

riscv64-unknown-elf-as -march=rv32i -o output.o $ASM_FILE

# Replace 'output.o' with your object file name
riscv64-unknown-elf-objdump -d output.o | grep -E '^[[:space:]]+[0-9a-f]+:' | while read -r line; do
    # Extract the hex value and the assembly code
    hex_value=$(echo "$line" | awk '{print $2}')
    asm_code=$(echo "$line" | cut -d$'\t' -f3-)

    # Now you can use $hex_value and $asm_code as separate variables
    echo "$N_LINE => x\"$hex_value\", -- $asm_code"

    N_LINE=$((N_LINE+1))
done

rm output.o
