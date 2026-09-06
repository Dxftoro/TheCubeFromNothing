@echo off

mkdir bin 2>nul

fasm bootloader.asm bin/bootloader.bin
fasm kernel.asm bin/kernel.bin
copy /b bin\bootloader.bin + bin\kernel.bin bin\cubefn.bin

qemu-system-x86_64 -drive file=bin/cubefn.bin,format=raw,if=ide