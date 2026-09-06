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

; args: word string pointer (si), byte cursor x (dl), byte cursor y (dh)
print_string_at:
	push ax
	push bx
	
	call move_cursor_to
	call print_string
	
	pop ax
	pop bx
	ret

; args: byte cursor x (dl), byte cursor y (dh)
move_cursor_to:
	mov ah, 0x02
	mov bh, 0
	int 0x10
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