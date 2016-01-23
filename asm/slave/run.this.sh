#!/bin/bash

clear
if [ $# = 0 ]; then
    echo "usage: $0 <file to asm w/o .asm suffix>";
    exit 1
fi;
avra -m $1.map -l $1.list -o $1.hex $1.asm

