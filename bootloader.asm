use16
org 0x7C00

S_WIDTH 		= 80
S_HEIGHT 		= 25
VIDEO_MEM		= 0xB800
DIST			= 64
CENTER_X		= 12
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
macro cputchar x, y, char, attr {
	mov di, (S_WIDTH * y + x) * 2
	mov byte [es:di], char
	mov byte [es:di + 1], attr
}

; =======================================================
; Code
; =======================================================
start:
	mov ax, 0
	mov ds, ax
	mov es, ax
	
	call clear_screen
	
	mov ax, VIDEO_MEM
	mov es, ax
	
	call draw_vertices
	
	jmp $

; =======================================================
; Functions
; =======================================================

; Perspective projection:
; sx = x * DIST / (z + DIST) + CENTER_X
; sy = y * DIST / (z + DIST) + CENTER_Y
draw_vertices:
	mov cx, 0
	mov si, cube_vertices
	
	.vert_pass:	cmp cx, 8
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
		mov [screen_coords], al
		
		putchar [screen_coords], [screen_coords + 1], '#', COLOR_LIGHT_BLUE
		
		add si, 3
		inc cx
		jne .vert_pass
	ret

; args: byte angle_index (al)
tsin:
	mov bx, ax
	mov al, [sin_table + bx]
	ret

; args: byte angle_index (al)
tcos:
	add al, 8
	and al, 31
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

cube_vertices	db 10, 10, 10,	10, 10, -10,
				db 10, -10, 10,	10, -10, -10,
				db -10, 10, 10,	-10, 10, -10,
				db -10, -10, 10, -10, -10, -10

screen_coords	db 0, 0

times 510-($-$$) db 0
dw 0xAA55