@echo off

mkdir bin 2>nul

fasm bootloader.asm bin/cubefn.bin && bochs -f cubefn.txt