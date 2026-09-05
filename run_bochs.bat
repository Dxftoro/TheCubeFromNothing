@echo off

mkdir bin 2>nul

fasm bootloader.asm bin/bootloader.bin
fasm kernel.asm bin/kernel.bin
copy /b bin\bootloader.bin + bin\kernel.bin bin\cubefn.bin

bochs -f cubefn.txt