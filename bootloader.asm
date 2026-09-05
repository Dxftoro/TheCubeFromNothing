use16
org 0x7C00

include 'macros.inc'

; =======================================================
; Code
; =======================================================
start:
	mov [boot_drive], dl

	mov ax, 0
	mov ds, ax
	mov es, ax
	
	mov ah, 0x02
	mov al, 2
	mov ch, 0
	mov cl, 2
	mov dh, 0
	mov dl, [boot_drive]
	mov bx, 0x7E00
	
	int 0x13
	jc disk_error
	
	jmp 0x7E00

disk_error:
	jmp $
	
include 'funcs.inc'

boot_drive 	db 0
msg_hello	db "The Cube", 0

times 510-($-$$) db 0
dw 0xAA55