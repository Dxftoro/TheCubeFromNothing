@echo off

mkdir bin 2>nul

fasm bootloader.asm bin/cubefn.bin && qemu-system-x86_64 -drive file=bin/cubefn.bin,format=raw,if=ide