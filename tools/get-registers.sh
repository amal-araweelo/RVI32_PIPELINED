#!/bin/bash

# File containing the register dump
RES_FILE="$1"

# Read the file and process it
cat $RES_FILE | 
    hexdump -v -e '1/4 "%08X " "\n"' |
    awk '{printf("REG(%d) = %s\n", NR-1, $1)}'

