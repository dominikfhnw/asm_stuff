; **** Codeword definitions ****

; first definition does not need a NEXT
DEF "EXIT", no_next
	rspop	FORTH_OFFSET

; TODO: right place
%define	ASM_OFFSET  DEF0

;DEF "exit", no_next
;	exit	x

%if 0
DEF "bad", no_next
	printstr `\n?OP`
	hlt
	;EXECUTE2 reg, exit
%endif

%if 0
DEF "sleep"
	sleep 1
DEF "rwx"
	rwx
DEF "pause"
	pause
%endif
%if 0
DEF "reg"
	; TODO: this is a mess
	%if 0
		%xdefine OLD_DEBUG DEBUG	
		%xdefine DEBUG 0
		%include "regdump2.mac"
		%xdefine DEBUG OLD_DEBUG
		%xdefine IP 0
		regdump_func
	%else
		;hlt
	%endif
%endif

DEF "lit8"
	xor	eax, eax
	lodsb
	push	eax

DEF "lit32"
	lodsd
	push	eax

DEF "sp_at"
	push	esp

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
	pop	eax

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
	
DEF "syscall3"
	pop	eax
	pop	ebx
	pop	ecx
	pop	edx
	int	0x80
	push	eax

NEXT

; **** (almost) all primitives finished (TODO:fix that) ****
DEFFORTH "exit"
	lit	1
	f_syscall3
;ENDDEF ;does not return

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

DEF "DOCOL", no_next
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

	;NEXT
;DEF "NEXT", no_next
A_NEXT:
lastnext:
	realNEXT

