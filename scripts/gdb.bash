#!/bin/bash

CORE_LIST=$(ls core*.gz)

echo "sbl.elf bt command output" > sbl.elf.bt.out
for core_name in $CORE_LIST;
do
        echo "########################################################" >> sbl.elf.bt.out
        echo $core_name >>  sbl.elf.bt.out
        gunzip $core_name
        base_core_name=${core_name%.*}
        gdb /xian/sbl.elf $base_core_name -x ./gdb.cmd >> sbl.elf.bt.out
        gzip $base_core_name
done
