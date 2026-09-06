; A code to build a binary cubefn image aligned to 1MB.
; Useful when it needs to be launched in VirtualBox or VMWare.

format binary

file 'bin/bootloader.bin'
file 'bin/kernel.bin'

times 1048576 - ($ - $$) db 0