use16
org 0x7C00

include 'macros.inc'

start:
	mov [boot_drive], dl
	
	call clear_screen
	
	mov si, msg_hello
	mov dl, 36
	mov dh, 11
	call print_string_at
	
	delay 0x001E, 0x8480
	
	push ax
	push bx
	mov dl, 0
	mov dh, 0
	call move_cursor_to
	pop ax
	pop bx
	
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