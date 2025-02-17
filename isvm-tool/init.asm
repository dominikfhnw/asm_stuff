; **** Assembler code ****
SECTION .text align=1
_start:

;DEF "RETURNSTACK_INIT", no_next
A_RETURNSTACK_INIT:
rinit
%if 0
	;mmap	0x10000, 0xffff, PROT_WRITE, MAP_PRIVATE | MAP_FIXED | MAP_ANONYMOUS, 0, 0
	mmap	0xffff, 0xffff, PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, 0, 0
	;mmap	0x10000, 0xffff, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_FIXED | MAP_ANONYMOUS, 0, 0
	;mmap	0x10000, 0xffff, PROT_WRITE, MAP_SHARED | MAP_ANONYMOUS, 0, 0
	;A_INIT:
	add	eax, eax
	taint	eax
	ychg	eax, ebp
%else
	enter	0xFFFF, 0
	; data stack should be the unlimited segment normally. +2 bytes
	;xchg	esp, ebp
%endif

;DEF "INIT", no_next
A_INIT:

%if !WORD_TABLE && WORD_SIZE == 4
	set	FORTH_OFFSET, FORTH
	%if WORD_FOOBEL
		jmp	[FORTH_OFFSET]
	%else
		jmp	lastnext
	%endif
%elif 0 && !WORD_TABLE && WORD_SIZE == 1
	rset	TABLE_OFFSET, 0
	set	TABLE_OFFSET, ORG
	%define OFF (FORTH - $$ - 2 + ELF_HEADER_SIZE)
	;set	eax, FORTH - 2
	mov	eax, TABLE_OFFSET
	mov	al, OFF
	DOCOL
%else
	;shl	eax,8

	;mov	TABLE_OFFSET, eax
	%if HARDCODE
		%error not supported atm
	%else
		; this is slightly confusing, as we're misusing the TABLE_OFFSET
		; variable for ASM_OFFSET
		rset	TABLE_OFFSET, 0
		set	TABLE_OFFSET, ORG
	%endif

	%define OFF (FORTH - $$ - 2 + ELF_HEADER_SIZE)
	mov	eax, TABLE_OFFSET
	mov	al, OFF
	;lea	eax, [TABLE_OFFSET  + OFF]
	DOCOL
;%else
;	%if !HARDCODE
;		rset	TABLE_OFFSET, 0
;		set	TABLE_OFFSET, ORG
;		;set	TABLE_OFFSET, STATIC_TABLE
;		%assign	OFF FORTH-STATIC_TABLE-2
;		lea	NEXT_WORD, [TABLE_OFFSET+OFF]
;		taint	FORTH_OFFSET
;		;set	NEXT_WORD, FORTH-2
;	%else
;		%error not supported atm
;		set	FORTH_OFFSET, FORTH
;	%endif
;	;movd	mm0, TABLE_OFFSET
;	;movd	mm1, FORTH_OFFSET
;	;jmp	lastnext
;	DOCOL
%endif



