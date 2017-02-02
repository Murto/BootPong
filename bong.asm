; PRE-GAME INITIALISATION
	mov  ax, 0x07C0				; set ax to start of code
	mov  ds, ax					; move ax into ds
	mov  ah, 0x01
	mov  cx, 0x2000
	int  0x10					; remove cursor blinking
	mov  ax, 0x0305
	mov  bx, 0x031F
	int  0x16					; increase keyboard input delay
	mov  ah, 0x0F
	int  0x10					; get screen width
	mov  [display_width], ah	; store screen width
	mov  cx, [ball_del]			; move ball delay into cx
	push cx						; push for later


; GAME LOOP
game_loop:
	call clear_display			; clear display of all characters
	mov  ah, 0x01
	int  0x16					; check for keyboard input
	jz   .display				; if no input then jump to .display
	mov  ah, 0x00
	int  0x16					; get keyboard input
	call update_bats			; update bat position for keyboard input
.display:
	mov  dx, [lbat_pos]
	call display_bat			; display left bat
	mov  dx, [rbat_pos]
	call display_bat			; display right bat
	mov  dx, [ball_pos]
	call display_ball			; display ball

	pop  cx						; pop ball movement counter
	dec  cx						; decrement counter
	cmp  cx, 0x0000				; compare counter to 0
	jne  .sleep					; if not equal then go straight to sleep
	
	mov  cx, [ball_del]			; move ball delay into cx
	call bounce_ball			; bounce the ball if it needs bouncing
	call move_ball				; move the ball
	call win_condition			; check if someone has won

.sleep:
	push cx						; push ball movement counter back onto the stack
	xor  cx, cx
	mov  dx, 0x0002
	mov  ah, 0x86				
	int  0x15					; sleep for 2 nano seconds (cx:dx)
	jmp  game_loop				; go back to the start of the game loop


; GAME FUNCTIONS
display_bat:
	mov  cx, 0x04				; bat length
	mov  al, '|'				; bat character
.loop:
	push cx						; push bat length counter
	call move_cursor			; move the cursor into position
	call print_char				; print the bat character
	pop  cx						; pop bat length counter
	dec  cx						; decrement it
	inc  dh						; increment position of the cursor
	cmp  cx, 0					; compare the counter to zero
	jnz  .loop					; if its not zero then repeat
	ret

display_ball:
	mov  al, '@'				; ball character
	call move_cursor			; move the cursor to where the ball is
	call print_char				; print the ball character
	ret

win_condition:
	cmp  dl, 0x00				; compare ball position with left-most column
	je   display_right_win		; if equal then right wins
	cmp  dl, 0x4F				; compare ball position with right-most column
	je   display_left_win		; if equal then left wins
	ret

display_left_win:
	mov  dx, 0x0422				; text position
	call move_cursor			; move cursor into position
	mov  si, left_str			; move string into source index
	call print_string			; print the string
	jmp  $						; jump to this position forever

display_right_win:
	mov  dx, 0x0422				; text position
	call move_cursor			; move the cursor into position
	mov  si, right_str			; move string into source index
	call print_string			; print the string
	jmp  $						; jump to this position forever

bounce_ball:
	mov  ax, [ball_pos]			; move the ball position into ax
	cmp  al, 0x01				; compare the x position with 1
	je   .left_bat				; if they are equal jump to .left_bat

	cmp  al, 0x4E				; compare the x position with 79
	je   .right_bat				; if they are equal jump to .right_bat

	jmp  .walls					; otherwise jump to .walls

.left_bat:
	mov  bx, [lbat_pos]			; move left bat posiiton into bx
	jmp  .bat_bounce			; jump to .bat_bounce

.right_bat:
	mov  bx, [rbat_pos]			; move right bat position into bx

.bat_bounce:
	sub  ah, bh					; subtract bh from ah
	cmp  ah, 0x03				; compare the result with 3
	jg   .walls					; if the result is not between 0 and 3 then jump to .walls

	mov  ax, [ball_dir]			; move the ball direction into ax
	xor  al, 0x01				; invert the ball's x direction
	mov  [ball_dir], ax			; save the change we made
	sub  word [ball_del], 0x04	; speed up the ball's movement
.walls:
	mov  ax, [ball_pos]			; move the ball position into ax
	cmp  ah, 0x00				; compare the y position with 0
	je   .wall_bounce			; if equal then jump to .wall_bounce

	cmp  ah, 0x18				; compare the y position with 24
	jne  .return				; if they arent equal then jump to .return

.wall_bounce:
	mov  ax, [ball_dir]			; move ball direction into ax
	xor  ah, 0x01				; invert ball y direction
	mov  [ball_dir], ax			; save our change

.return:
	ret

update_bats:
	cmp  al, 'w'				; compare al with 'w'
	je   .left_up				; if equal then jump to .left_up

	cmp  al, 's'				; compare al with 's'
	je   .left_down				; if equal then jump to .left_down

	cmp  al, 'i'				; compare al with 'i'
	je   .right_up				; if equal then jump to .right_up

	cmp  al, 'k'				; compare al with 'k'
	je   .right_down			; if equal then jump to .right_down

	ret							; return if no relevant keys are pressed

.left_up:
	mov  ax, [lbat_pos]			; move left bat's position into ax
	cmp  ah, 0x00				; compare bat y position with 0
	je   .return				; if they are equal then return

	dec  ah						; move y position up
	mov  [lbat_pos], ax			; save the change
	ret

.left_down:
	mov  ax, [lbat_pos]			; move left bat's position into ax
	cmp  ah, 0x15				; compare bat y position with 21
	je   .return				; if they are equal then return

	inc  ah						; move y position down
	mov  [lbat_pos], ax			; save the change
	ret

.right_up:
	mov  ax, [rbat_pos]			; move right bat's position into ax
	cmp  ah, 0x00				; compare y positon with 0
	je   .return				; if equal then return

	dec  ah						; move y position up
	mov  [rbat_pos], ax			; save the change
	ret

.right_down:
	mov  ax, [rbat_pos]			; move right bat's position into ax
	cmp  ah, 0x15				; compare y position with 21
	je  .return					; if they are equal then return

	inc  ah						; move y position down
	mov  [rbat_pos], ax			; save the change
	ret

.return:
	ret

move_ball:
	mov  ax, [ball_pos]			; move ball position into ax
	mov  bx, [ball_dir]			; move ball direction into bx
	cmp  bl, 0x01				; compare x direction to 1
	je   .move_right			; if they are equal then jump to .move_right

.move_left:
	dec  al						; move ball x left
	jmp  .move_y				; jump to .move_y

.move_right:
	inc  al						; move ball x right

.move_y:
	cmp  bh, 0x01				; compare ball y direction to 1
	je   .move_down				; if equal then jump to .move_down

.move_up:
	dec  ah						; move ball y up
	jmp  .return				; jump to return

.move_down:
	inc  ah						; move ball y down

.return:
	mov  [ball_pos], ax			; save the changes
	ret


; BASIC DISPLAY FUNCTIONS
clear_display:
	mov  ax, 0x0700
	mov  bh, 0x02				; set text to green and background to black
	xor  cx, cx					; set cx to top left (0, 0)
	mov  dh, 0x1A
	mov  dl, [display_width]	; set dx to bottom right (23, 79)
	int  0x10					; clear screen of characters
	xor  dx, dx					; set dx to top left (0, 0)
	call move_cursor			; redundant operation
	ret

move_cursor:
	mov  ah, 0x02
	xor  bh, bh					; set page number to zero
	int  0x10					; move dursor to position (dl, dh)
	ret

print_char:
	mov  ah, 0x0E
	int  0x10					; print char in al
	ret

print_string:
	lodsb						; load byte at si into al
	cmp  al, 0x00				; compare al with 0 (indicates end of string)
	je   .done					; if they are equal then jump to .done

	call print_char				; print character in al
	jmp  print_string			; jump to print_string

.done:
	ret

; VARIABLES
	display_width	db 0x00					; width of display
	ball_del		dw 0x00AF				; number of nanoseconds * 2 that it takes for the ball to move once
	lbat_pos		dw 0x0A00				; position of the left bat split y-pos:x-pos due to little-endian format
	rbat_pos		dw 0x0A4F				; position of the right bat	^^
	ball_pos		dw 0x0C02				; position of the ball		^^
	ball_dir		dw 0x0000				; split x-dir:y-dir
	left_str		db 'LEFT WINS!', 0x00	; left win text
	right_str		db 'RIGHT WINS!', 0x00	; right win text


; PADDING AND BOOT SIGNATURE
	times 510-($-$$) db 0					; padding
	dw 0xAA55								; boot signature
