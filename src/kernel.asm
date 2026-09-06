use16
org 0x7E00

include 'macros.inc'

; =======================================================
; Code
; =======================================================
start:
	mov ax, 0
	mov ds, ax
	mov es, ax

	.main_loop:
		call clear_screen
	
		mov ax, VIDEO_MEM
		mov es, ax
		
		call rotate_cube
		call project_to_screen
		call draw_edges
	
		; 100ms delay
		delay 0x0001, 0x86A0
		
		inc byte [current_angle]
		and byte [current_angle], 31
	
		jmp .main_loop

; =======================================================
; Functions
; =======================================================

rotate_cube:
	mov cx, 8
	mov si, cube_vertices
	mov di, rotated_verticies
	
	.rotation_pass:
		call rotate_vertex
		
		; x
		mov [di], al
		; y
		mov [di + 1], bh
		; z
		mov [di + 2], bl
		
		add si, 3
		add di, 3
		loop .rotation_pass
	
	ret

; ret: x (al), y (bh), z (bl)
; rot_x = (x * cos(angle) - z * sin(angle)) / SINE_TALBE_AMP
; rot_z = (x * sin(angle) + z * cos(angle)) / SINE_TALBE_AMP
rotate_vertex:
	mov al, [current_angle]
	call tsin
	mov [sinv], al
	
	mov al, [current_angle]
	call tcos
	mov [cosv], al
	
	; rotating x
	mov al, [si]
	imul byte [cosv]
	mov bx, ax
	mov al, [si + 2]
	imul byte [sinv]
	sub bx, ax
	mov ax, bx
	cwd
	idiv word [SINE_TALBE_AMP]
	push ax
	
	; rotating z
	mov al, [si]
	imul byte [sinv]
	mov bx, ax
	mov al, [si + 2]
	imul byte [cosv]
	add bx, ax
	mov ax, bx
	cwd
	idiv word [SINE_TALBE_AMP]
	mov bl, al
	
	; rotating y (do not)
	mov bh, [si + 1]
	
	pop ax	
	ret

project_to_screen:
	mov cx, 8
	mov si, rotated_verticies
	mov di, screen_coords
	
	.vert_pass:
		; Zd = z + DIST, Zd -> bx
		mov al, [si + 2]
		cbw
		add ax, DIST
		mov bx, ax
		
		; x * DIST / Zd + CENTER_X
		mov al, [si]
		cbw
		imul ax, ax, DIST
		cwd
		idiv bx
		add ax, CENTER_X
		mov [di], al
		
		; y * DIST / Zd + CENTER_Y
		mov al, [si + 1]
		cbw
		imul ax, ax, DIST
		cwd
		idiv bx
		sar ax, 1
		add ax, CENTER_Y
		mov [di + 1], al
		
		add si, 3
		add di, 2
		loop .vert_pass
	ret

draw_edges:
	mov cx, 12
	mov si, cube_edges
	
	.edge_pass:
		lodsb
		
		push cx
		push si
		call draw_edge
		pop si
		pop cx
		
		loop .edge_pass
	ret

draw_edge:
	; first vertex index (bl), second vertex index (bh)
	call unpack_edge
	
	; first vertex offset
	mov al, bl
	xor ah, ah
	shl ax, 1
	mov si, ax
	
	; second vertex offset
	mov al, bh
	xor ah, ah
	shl ax, 1
	mov di, ax
	
	; |x0 - x1|
	mov al, [screen_coords + si]
	mov bl, [screen_coords + di]
	call subabs
	mov [dist_x], al
	mov [sign_x], dl
	
	; |y0 - y1|
	mov al, [screen_coords + si + 1]
	mov bl, [screen_coords + di + 1]
	call subabs
	mov [dist_y], al
	mov [sign_y], dl
	
	mov al, [screen_coords + si]
	mov [current_pixel], al
	mov al, [screen_coords + si + 1]
	mov [current_pixel + 1], al
	
	mov al, [screen_coords + di]
	mov [dest_x], al
	mov al, [screen_coords + di + 1]
	mov [dest_y], al
	
	; errv
	mov al, [dist_x]
	xor ah, ah
	mov bx, ax
	;
	mov al, [dist_y]
	xor ah, ah
	sub bx, ax
	mov [errv], bx
	
	.line_pass:
		mov bl, '#'
		mov bh, COLOR_LIGHT_BLUE
		call draw_pixel
		
		mov al, [current_pixel]
		cmp al, [dest_x]
		jne .step
		
		mov al, [current_pixel + 1]
		cmp al, [dest_y]
		je .done
	.step:
		call draw_edge_step
		jmp .line_pass
	.done:
	ret

draw_edge_step:
	; -dist_y -> cx
	xor ah, ah
	mov al, [dist_y]
	neg ax
	mov cx, ax
	
	mov ax, [errv]
	sal ax, 1
	
	cmp ax, cx
	jle .skip_x
		xor ch, ch
		mov cl, [dist_y]
		sub [errv], cx
		
		mov dl, [sign_x]
		add [current_pixel], dl
	.skip_x:
	
	xor ch, ch
	mov cl, [dist_x]
	cmp ax, cx
	jge .skip_y
		add [errv], cx
		mov al, [sign_y]
		add [current_pixel + 1], al
	.skip_y:
	ret

; Draws a pixel with coordinates stored in screen_coords
; args: byte char (bl), byte attr (bh)
draw_pixel:
	; (S_WIDTH * y + x) * 2	
	mov ax, S_WIDTH
	mul byte [current_pixel + 1]
	
	mov dl, [current_pixel]
	xor dh, dh
	add ax, dx
	
	shl ax, 1
	
	mov di, ax
	mov byte [es:di], bl
	mov byte [es:di + 1], bh
	ret

; args: packed edge byte (al)
; ret: first vertex index (bl), second vertex index (bh)
unpack_edge:
	mov bl, al
	and bl, 00000111b
	
	mov bh, al
	shr bh, 3
	ret

; args: byte left operand (al), byte right operand (bl)
; ret: result (al), sign (dl)
subabs:
	sub al, bl
	cbw
	
	mov dl, ah
	shl dl, 1
	add dl, 1
	neg dl
	
	xor al, ah
	sub al, ah
	ret

; args: byte angle_index (al)
; ret: sin value (al)
tsin:
	xor ah, ah
	mov bx, ax
	mov al, [sin_table + bx]
	ret

; args: byte angle_index (al)
; ret: cos value (al)
tcos:
	add al, 8
	and al, 31
	xor ah, ah
	mov bx, ax
	mov al, [sin_table + bx]
	ret

include 'funcs.inc'

; =======================================================
; Data
; =======================================================
sin_table:
	db 0x00,0x14,0x26,0x38,0x47,0x53,0x5C,0x62
	db 0x64,0x62,0x5C,0x53,0x47,0x38,0x26,0x14
	db 0x00,0xEC,0xDA,0xC8,0xB9,0xAD,0xA4,0x9E
	db 0x9C,0x9E,0xA4,0xAD,0xB9,0xC8,0xDA,0xEC

cube_vertices	db 15, 15, 15,		15, 15, -15
				db 15, -15, 15,		15, -15, -15
				db -15, 15, 15,		-15, 15, -15
				db -15, -15, 15, 	-15, -15, -15

; packed edge indices
cube_edges 		db 0x08, 0x10, 0x20, 0x19
				db 0x29, 0x1A, 0x32, 0x3B
				db 0x2C, 0x34, 0x3D, 0x3E

rotated_verticies 	rb 8 * 3
screen_coords		rb 8 * 2
current_pixel		db 0, 0
errv				dw 0
SINE_TALBE_AMP		dw 100
dest_x				db 0
dest_y				db 0
dist_x				db 0
dist_y				db 0
sign_x				db 0
sign_y				db 0
current_angle		db 0
sinv				db 0
cosv				db 0