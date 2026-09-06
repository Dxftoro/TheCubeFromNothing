clear_screen:
	mov ax, VIDEO_MEM
	mov es, ax
	xor di, di
	
	mov cx, 80 * 25
	mov ax, 0x0720
.loop:
	stosw
	loop .loop
	ret

print_string:
	lodsb ; ds, si will be used
	or al, al
	jz .done
	mov ah, 0x0E
	int 0x10
	jmp print_string
.done:
	ret