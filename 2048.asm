;2048.ASM	15-Sep-2016		Boreal		loren.blaney@gmail.com
;A 2048-bit Clone of Gabriele Cirulli's 2048 Game
;Use the arrow keys to move the tiles, and Ctrl+Alt+Del to exit the program.
;Assemble with tasm /m and tlink /t
;Greets to Adok Aphex Bonz Boothby Bushy Chut claw Dragan Espineter Flyke G3
; GreenGhost INT-E Jeff meph Optimus Picard Ruud Shur Sniper Stefan TAD and
; the rest of you inspiring Hugi size coders.

	.code
	.486
	org	100h
;	ax=0, bx=0, cx=00FF, bp=09??, dx=cseg, si=0100, di=sp=-2
box	equ	0		;(yep, clobbers the PSP, hence Ctrl+Alt+Del)

start:	mov	cl, 16		;empty the box of tiles
	xor	di, di
	rep stosb		;es:[di++]:= al; cx--

	mov	al, 03h		;clear the screen
	int	10h

;Turn loop: Insert a new tile at a random empty location
tl00:	mov	ax, 9421	;linear congruential random number generator
	imul	ax, ax, 12345	;seed:= seed*9421 + 1
tl10:	inc	ax
	mov word ptr tl10-2, ax	;self-modifying code (some old CPUs choke)
	mov	cx, ax		;save copy of random number
	and	ax, 000Fh	;get random box location (0..15)
	xchg	bx, ax
	cmp	[bx+box], bh	;is it zero, i.e. empty?
	jne	tl00		;loop until empty location is found

	xchg	ax, cx		;get random number with its additional high bits
	mov	cl, 1		;assume the 90% case that inserts 2^1=2
	aam	10		;ah:= al/10; al:= remainder
	jne	tl17		;skip if remainder is not zero
	 inc	cx		;10% of the time insert 2^2=4
tl17:	mov	[bx+box], cl	;insert new tile into the box

;Show the box with its numbered tiles
	xor	si, si		;for I:= 0 to 15 do all box locations
tl22:	mov	ax, si		;  cx:= ((I&3)+5)*6; X coordinate
	and	al, 03h
	add	al, 5		;  center on screen horizontally
	imul	cx, ax, 6

	imul	ax, si, 40h	;  ch:= I>>2*3+6; Y coordinate
	mov	al, 6		;  center on screen verticlly
	aad	3		;  al:= ah*3 + 6; ah:= 0
	mov	ch, al		;  cx:= coordinates of upper-left corner

	mov	dx, 0205h	;  dx:= coordinates of lower-right corner
	add	dx, cx
	imul	bx, [si+box], 2000h ;color tiles according to their values
	add	bh, 20h		;  start with blue, i.e. empty = blue
	shr	bh, 1		;  color:= power+1 & 70h ("&" avoids flashing)
	or	bh, 0Fh		;  make the numbers bright white
	mov	ax, 0600h	;  fill window with color attribute in bh
	int	10h

	sub	dx, 0104h	;  move cursor to number's position on tile
	mov	ah, 02h		;  Cursor(dl, dh)
	xor	bx, bx		;  select display page zero
	int	10h

	xor	ax, ax		;  ax:= 0
	xor	cx, cx		;  if power # 0 then change ax from 0 to 1
	add	cl, [si+box]
	je	tl28
	 inc	ax
tl28:	shl	ax, cl		;  ax:= 2^power (or 0)

;Display 4-digit number in ax
	mov	bl, 10		;divisor (bh=0)
	mov	cl, 4		;loop couner (ch=0)
io10:	cwd			;dx:= 0; (ax<8000h)
	idiv	bx		;ax:= dx:ax/10; dx:= remainder
	push	dx		;save digit on stack
	loop	io10

	mov	cl, 4		;unwind stack
io20:	pop	ax		;get digit
	or	bh, al		;display underlines instead of leading zeros
	jne	io30
	 mov	al, '_'-'0'
io30:	add	al, '0'		;convert digit to its ASCII value
	int	29h		;display it (without changing attribute color)
	loop	io20		;loop for all 4 digits

	inc	si		;next tile
	cmp	si, 16		;(increment takes more code but leaves flashing
	jne	tl22		; cursor at bottom where it's less annoying)

;Get arrow keystrokes and move tiles
	xor	bp, bp		;clear moved flag: Moved:= false
tl42:	mov	ah, 0		;get keystroke: ChIn
	int	16h
	mov	al, ah		;use the scan code

	mov	cx, 3		;for I:= 3 downto 0 do each row or each column
tl45:	mov	si, cx		;  initialize some common stuff
	xor	di, di
	cmp	al, 4Bh		;  if left arrow then
	jne	tl50
	 shl	si, 2		;    MoveTiles(I*4,   +1)
	 inc	di
tl50:
	cmp	al, 4Dh		;  if right arrow then
	jne	tl60
	 shl	si, 2		;    MoveTiles(3+I*4, -1)
	 add	si, 3
	 dec	di
tl60:
	cmp	al, 50h		;  if down arrow then
	jne	tl70
	 add	si, 12		;    MoveTiles(I+12,  -4)
	 mov	di, -4
tl70:
	cmp	al, 48h		;  if up arrow then
	jne	tl80
	 mov	di, 4		;    MoveTiles(I,     +4)
tl80:
;Shift tiles, add identical adjacents, and shift again
; si=X0, di=DX
; bx=X, cl=M, ch=N
	push	ax		;save arrow key's scan code
	push	cx		; and row/column counter
	cwd			;dx:= 0; (ah<80h)

;Shift all tiles in a single row or column
st00:	mov	cl, 3		;for M:= 1 to 3 do
st05:	mov	bx, si		;  X:= X0

	mov	ch, 3		;  for N:= 1 to 3 do
st10:	mov	dh, 0
	mov	ah, 0		;    if Box(X)=0 & Box(X+DX)#0 then
	call	st100		;      do common code
	dec	ch		;  next N
	jne	st10
	loop	st05		;next M; (ch=0)	

	dec	dx		;dl = FFh, FEh
	jnp	st99		;exit loop when dl's parity is odd

;Add identical adjacent tiles into a new tile
	mov	bx, si		;X:= X0

	mov	cl, 3		;for N:= 1 to 3 do
st30:	mov	dh, 1
	mov	ah, [bx+di+box]	;  if Box(X)=Box(X+DX) & Box(X+DX)#0 then
	call	st100		;    do common code
	loop	st30		;next N
	jmp	st00		;go back to close any gaps that opened up
st99:
	pop	cx
	pop	ax
	dec	cx		;next row or column
	jns	tl45

	test	bp, bp		;loop until a tile moves
	je	tl42
	jmp	tl00		;loop for next turn

;Common code
st100:	cmp	ah, [bx+box]	;Box(X) must equal al, either 0 or adjacent tile
	jne	st140
	cmp	[bx+di+box], bh	;Box(X+DX) must not be empty
	je	st140
	 add	dh, [bx+di+box]	;Box(X):= Box(X+DX); optionally increment power
	 mov	[bx+box], dh
	 mov	[bx+di+box], bh	;Box(X+DX):= 0
	 inc	bp		;Moved:= true
st140:	add	bx, di		;X:= X+DX
	ret

	end	start
