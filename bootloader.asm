use16
org 0x7C00

S_WIDTH 		= 80
S_HEIGHT 		= 25
VIDEO_MEM		= 0xB800

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
	
	putchar 10, 10, '#', COLOR_LIGHT_BLUE
	
	jmp $

; =======================================================
; Functions
; =======================================================

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
; Sine table
; =======================================================
sin_table:
	db 0x00,0x14,0x26,0x38,0x47,0x53,0x5C,0x62
	db 0x64,0x62,0x5C,0x53,0x47,0x38,0x26,0x14
	db 0x00,0xEC,0xDA,0xC8,0xB9,0xAD,0xA4,0x9E
	db 0x9C,0x9E,0xA4,0xAD,0xB9,0xC8,0xDA,0xEC

times 510-($-$$) db 0
dw 0xAA55