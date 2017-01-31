; PRE-GAME INITIALISATION
	mov  ax, 0x07C0
	mov  ds, ax
	mov  ah, 0x01
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
	mov  ah, 0x01
	int  0x16
	jz   .display
	mov  ah, 0x00
	int  0x16
	call update_bats
.display:
	mov  dx, [lbat_pos]
	call display_bat
	mov  dx, [rbat_pos]
	call display_bat
	mov  dx, [ball_pos]
	call display_ball
	call win_condition
	call move_ball
	mov  cx, 0x0007
	mov  dx, 0xA120
	mov  ah, 0x86
	int  0x15					; sleep for 500000 nano seconds (cx:dx)
	jmp game_loop

; GAME FUNCTIONS
display_bat:
	mov  cx, 0x04
	mov  al, '#'				; bat character
.loop:							; displays the whole 4-character bat
	push cx
	call move_cursor			
	call print_char
	pop  cx
	dec  cx
	inc  dh
	cmp  cx, 0
	jnz  .loop
	ret

display_ball:
	mov  al, '@'				; ball character
	call print_char
	ret

win_condition:
	cmp  dl, 0x00				; compare ball position with left-most column
	je   display_right_win		; if equal then right wins
	cmp  dl, 0x4F				; compare ball position with right-most column
	je   display_left_win		; if equal then left wins
	ret

display_left_win:
	mov  dx, 0x2414				; text position (36, 20)
	mov  si, left_str
	call print_string
	jmp  $

display_right_win:
	mov  dx, 0x2414				; text position (36, 20)
	mov  si, right_str
	call print_string
	jmp  $

move_ball:
	mov  ax, [ball_pos]
	cmp  al, 0x01
	je   .left
	cmp  al, 0x4E
	je   .right
	jmp  .walls
.left:							; calculation to find if the ball hits the bat
	mov  bx, [lbat_pos]
	sub  al, bl
	cmp  al, 0x03
	jbe  .wall_bounce
	jmp  .move
.right:							; calculation to find if the ball hits the bat
	mov  bx, [rbat_pos]
	sub  al, bl
	cmp  al, 0x03
	jg  .move
.bat_bounce:					; changing the direction of the ball when bouncing off the bats
	mov  ax, [ball_dir]
	xor  ax, 0x0100
	mov  [ball_dir], ax
.walls:							; checking if the ball hits the top or bottom
	cmp  ah, 0x00
	je   .wall_bounce
	cmp  ah, [display_width]
	jne  .move
.wall_bounce:					; changing the direction of the ball when bouncing off the walls
	mov  ax, [ball_dir]
	xor  ax, 0x0001
	mov  [ball_dir], al
.move:
	mov  ax, [ball_pos]
	mov  bx, [ball_dir]
	cmp  bx, 0x0000
	je   .move_tl
	cmp  bx, 0x0100
	je   .move_tr
	cmp  bx, 0x0101
	je   .move_bl
	jmp  .move_br
.move_tl:
	sub  ax, 0x0101
	ret
.move_tr:
	sub  al, 0x01
	add  ah, 0x01
	ret
.move_bl:
	add  al, 0x01
	sub  ah, 0x01
	ret
.move_br:
	sub  ax, 0x0101
	ret

update_bats:
	cmp  al, 'w'
	je   .left_up
	cmp  al, 's'
	je   .left_down
	cmp  al, 'i'
	je   .right_up
	cmp  al, 'k'
	je   .right_down
	ret
.left_up:
	mov  ax, [lbat_pos]
	cmp  ah, 0x00
	je   .return
	sub  ah, 0x01
	mov  [lbat_pos], ax
	ret 
.left_down:
	mov  ax, [lbat_pos]
	cmp  ah, 0x4B
	je   .return
	add  ah, 0x01
	mov  [lbat_pos], ax
	ret
.right_up:
	mov  ax, [rbat_pos]
	cmp  ah, 0x00
	je   .return
	sub  ah, 0x01
	mov  [rbat_pos], ax
	ret
.right_down:
	mov  ax, [rbat_pos]
	cmp  ah, 0x4B
	je  .return
	add  ah, 0x01
	mov  [rbat_pos], ax
	ret
.return:
	ret

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
	display_width	db 0x00
	lbat_pos		dw 0x0A00				; split x-pos:y-pos
	rbat_pos		dw 0x0A4F				; ^
	ball_pos		dw 0x0B01				; ^
	ball_dir		dw 0x0000				; split x-dir:y-dir
	left_str		db 'LEFT WINS!', 0x00	; win text
	right_str		db 'RIGHT WINS!', 0x00	; lose text

	times 510-($-$$) db 0
	dw 0xAA55
