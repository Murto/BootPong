; PRE-GAME INITIALISATION
	mov	 ah, 0x01
	mov  cx, 0x2000
	int  0x10					; remove cursor blinking
	mov  ax, 0x0305
	mov  bx, 0x031F
	int  0x16					; increase keyboard delay
	mov  ah, 0x0F
	int  0x10					; get screen width
	mov  [display_width], ah	; save width for later calculations

game_loop:
	call clear_display			; clear display
	mov  dx, [bat1_pos]
	call display_bat
	mov  dx, [bat2_pos]
	call display_bat
	mov  dx, [ball_pos]
	call display_ball
	call win_condition

; GAME FUNCTIONS
display_bat:
	mov  cx, 4
	mov  al, '#'
.loop
	call move_cursor
	call print_char
	dec  cx
	cmp  word cx, 0
	jnz  .loop
	ret

display_ball:
	mov  al, '@'
	call print_char
	ret

win_condition:
	cmp  dx, 0

display_win:
	mov  dx, 0x28

display_lose:

freeze:
	jmp  $

; BASIC DISPLAY FUNCTIONS
clear_display:
	mov  ax, 0x0700				; clear display
	mov  bh, 0x0C				; !!!light red on black!!!
	xor  cx, cx					; set cx to top left (0, 0)
	mov  dl, [display_width]	; set dx to bottom right (23, 79)
	int  0x10
	xor  dx, dx					; set dx to top left (0, 0)
	call move_cursor
	ret

move_cursor:
	mov  ah, 0x02				; move cursor to (dl, dh)
	xor  bh, bh					; set page number to zero
	int  0x10
	ret

print_char:
	mov  ah, 0x0E				; print char at al
	int  0x10
	ret

print_string:
	lodsb						; load next byte from si
	cmp  al, 0x00				; compare byte with 0x00 (end of string)
	je   .done
	call print_char
	jmp  print_string
.done:
	ret

; VARIABLES
	display_width	dw 0x0000
	bat1_pos		dw 0x000A	; split x-pos:y-pos
	bat2_pos		dw 0x4F0A	; ^
	ball_pos		dw 0x010B	; ^
	ball_mov		dw 0x0101	; split x-mov:y-mov
	ball_dir		dw 0x0000	; split x-dir:y-dir
	win_str			db 'YOU WIN!', 0x00
	lose_str		db 'YOU LOSE!', 0x00
