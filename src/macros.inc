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