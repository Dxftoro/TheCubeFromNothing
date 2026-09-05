use16
org 0x7C00

S_WIDTH 		= 80
S_HEIGHT 		= 25
VIDEO_MEM		= 0xB800
DIST			= 64
CENTER_X		= 40
CENTER_Y		= 12

; =======================================================
; Colors
; =======================================================
COLOR_BLACK 		= 0x00
COLOR_BLUE			= 0x01
COLOR_GREEN			= 0x02
COLOR_CYAN			= 0x03
COLOR_RED			= 0x04
COLOR_MAGENTA		= 0x05
COLOR_BROWN			= 0x06
COLOR_GRAY			= 0x07
COLOR_DARK_GRAY		= 0x07
COLOR_LIGHT_BLUE	= 0x09
COLOR_LIGHT_GREEN	= 0x0A
COLOR_LIGHT_CYAN	= 0x0B
COLOR_LIGHT_RED		= 0x0C
COLOR_LIGHT_MAGENTA	= 0x0D
COLOR_YELLOW		= 0x0E
COLOR_WHITE			= 0x0F

; =======================================================
; Macros
; =======================================================

macro putchar x, y, char, attr {
	mov di, (S_WIDTH * y + x) * 2
	mov byte [es:di], char
	mov byte [es:di + 1], attr
}

macro delay dhi, dlo {
	mov ah, 0x86
	mov cx, dhi
	mov dx, dlo
	
	int 15h

	xor ah, ah
	xor cx, cx
	xor dx, dx
}

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
		call draw_vertices
	
		; 1ms delay
		delay 0x0003, 0x0D40
		
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

; Perspective projection:
; sx = x * DIST / (z + DIST) + CENTER_X
; sy = y * DIST / (z + DIST) + CENTER_Y
draw_vertices:
	mov cx, 8
	mov si, rotated_verticies
	
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
		mov [screen_coords], al
		
		; y * DIST / Zd + CENTER_Y
		mov al, [si + 1]
		cbw
		imul ax, ax, DIST
		cwd
		idiv bx
		add ax, CENTER_Y
		mov [screen_coords + 1], al
		
		mov bl, '#'
		mov bh, COLOR_LIGHT_BLUE
		call draw_pixel
		
		add si, 3
		loop .vert_pass
	ret

; Draws a pixel with coordinates stored in screen_coords
; args: byte char (bl), byte attr (bh)
draw_pixel:
	; (S_WIDTH * y + x) * 2	
	mov ax, S_WIDTH
	mul byte [screen_coords + 1]
	
	mov dl, [screen_coords]
	xor dh, dh
	add ax, dx
	
	shl ax, 1
	
	mov di, ax
	mov byte [es:di], bl
	mov byte [es:di + 1], bh
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

print_string:
	lodsb ; ds, si will be used
	or al, al
	jz .done
	mov ah, 0x0E
	int 0x10
	jmp print_string
.done:
	ret

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

; =======================================================
; Data
; =======================================================
sin_table:
	db 0x00,0x14,0x26,0x38,0x47,0x53,0x5C,0x62
	db 0x64,0x62,0x5C,0x53,0x47,0x38,0x26,0x14
	db 0x00,0xEC,0xDA,0xC8,0xB9,0xAD,0xA4,0x9E
	db 0x9C,0x9E,0xA4,0xAD,0xB9,0xC8,0xDA,0xEC

cube_vertices	db 10, 10, 10,		10, 10, -10
				db 10, -10, 10,		10, -10, -10
				db -10, 10, 10,		-10, 10, -10
				db -10, -10, 10, 	-10, -10, -10

rotated_verticies rb 8 * 3
screen_coords		db 0, 0
current_angle		db 0
sinv				db 0
cosv				db 0

SINE_TALBE_AMP		dw 100

times 510-($-$$) db 0
dw 0xAA55