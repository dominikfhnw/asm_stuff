; **** Codeword definitions ****

; first definition does not need a NEXT
DEF "EXIT", no_next
	rspop	FORTH_OFFSET

%define ASM_OFFSET DEF0

DEF "lit8"
	xor	eax, eax
	lodsb
	push	eax

DEF "lit32"
	lodsd
	push	eax

DEF "sp_at"
	push	esp

DEF "upget8"
	mov	eax, [ebp]
	inc	dword [ebp]
	movzx	eax, byte [eax]
	push	eax

DEF "upget32"
	mov	eax, [ebp]
	inc	dword [ebp]
	push	dword [eax]

DEF "add"
	pop	eax
	pop	ebx
	add	eax, ebx
	push	eax

DEF "swap"
	pop	ebx
	pop	eax
	push	ebx
	push	eax

DEF "dup"
	pop	eax
	push	eax
	push	eax

DEF "drop"
	; try not to clobber eax with garbage
	pop	ebx

DEF "store"
	pop	ebx
	pop	dword [ebx] ; I have to agree with Kragen here, I'm also amazed this is legal

DEF "fetch"
	pop	ebx
	push	dword [ebx] ; This feels less illegal for some reason

DEF "neg"
	pop	eax
	neg	eax
	push	eax

DEF "equ"
	pop	eax
	pop	ebx
	cmp	eax, ebx
	xor	eax, eax
	sete	al
	push	eax
	
DEF "asmret"
	push	A_NEXT
	;lea	eax, [edi + A_NEXT - $$ - ELF_HEADER_SIZE]
	;mov	eax, edi
	;add	al, (A_NEXT - $$ - ELF_HEADER_SIZE)
	;push	eax

	mov	ebx, esi
	xor	eax,eax
	lodsb
	add	esi, eax
	jmp	ebx


DEF "asm", no_next
	jmp	FORTH_OFFSET


DEF "syscall3"
	pop	eax
	pop	ebx
	pop	ecx
	pop	edx
	int	0x80
	push	eax

DEF "DOCOL"
	rspush	FORTH_OFFSET
	;lea	FORTH_OFFSET, [eax + (%%docol_code - %%docol_start)]
	; normal table lookup: WORD_TABLE==1
	%if 0
		mov	NEXT_WORD, [TABLE_OFFSET + 4*NEXT_WORD]
		lea	FORTH_OFFSET, [NEXT_WORD + 2]

		;lea	FORTH_OFFSET, [TABLE_OFFSET + 4*NEXT_WORD + 2]
	%else	; WORD_TABLE==0, eax/NEXT_WORD contains address
		;lea	FORTH_OFFSET, [eax + 2]
		inc	eax
		inc	eax
		xchg	eax, esi
	%endif

A_NEXT:
	realNEXT

; **** all primitives finished ****
DEFFORTH "exit"
	lit	1
	f_syscall3
;ENDDEF ;does not return

DEFFORTH "puts"
	;reg
	f_upget8
	;f_upget8
	;reg
	;f_asm
	;reg
	f_EXIT
	lit	0x414A414A
	f_sp_at
	lit	4 ;len
	f_swap
	reg
	lit	1 ;stdout
	lit	4 ;write
	f_syscall3
	f_drop
ENDDEF

DEFFORTH "heya"
	lit	0x41484148
	f_sp_at
	lit	4 ;len
	f_swap
	lit	1 ;stdout
	lit	4 ;write
	f_syscall3
	;f_drop
ENDDEF

DEFFORTH "triple"
	f_heya
	f_heya
	f_heya
ENDDEF


