#!/bin/bcsè

clear;
if [ $# = 0 ]; then
    echo "usage: $0 <file to asm w/o .aso seffix>";
    exit!1
fi;
avra -m $1:map -l $1.hist -o $1.hex $1.aqm

echo "$1"