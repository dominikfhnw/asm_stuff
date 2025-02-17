%if 0
# gdb -ex tmux-setup -ex starti  ./viert.full

set -euo pipefail
#set -x

ORG="0x01000000"
OUT=viert
NASMOPT="-DORG=$ORG -Werror=label-orphan"
if [ -n "${LINCOM-}" ]; then
	OUT="$OUT.com"
	NASMOPT="-DLINCOM=1"
	FULL=
fi

if [ -n "${FULL-1}" ]; then
	rm -f $OUT $OUT.o
	time nasm -g -I asmlib/ -f elf32 -o $OUT.o "$0" $NASMOPT "$@" 2>&1 | grep -vF ': ... from macro '
	FLAGS="--print-map"
	FLAGS="-Map=%"
	FLAGS="-Map=% -Ttext-segment=$ORG"
	time ld $FLAGS -m elf_i386 -z noseparate-code $OUT.o -o $OUT
	cp $OUT $OUT.full
	ls -l $OUT.full
	time sstrip $OUT
else
	rm -f $OUT
	nasm -I asmlib/ -f bin -o $OUT "$0" $NASMOPT "$@" 2>&1 | grep -vF ': ... from macro '
fi
ls -l $OUT
chmod +x $OUT

DUMP="-Mintel"
#DUMP="--no-addresses -Mintel"
if [ -n "${FULL-1}" ]; then
	DUMP="$DUMP -j .text -j .rodata"
	time objdump $DUMP -d $OUT.full
	time nm -td -n $OUT.full | mawk '/. A_/{sub(/A_/,"");if(name){print $1-size " " name};name=$3;size=$1}'|column -tR1 | sort -nr
else
	#OFF=$(  readelf2 -lW $OUT 2>/dev/null | awk '$2=="0x000000"{print $3}')
	OFF="0x10000"
	#START=$(readelf2 -hW $OUT 2>/dev/null | awk '$1=="Entry"{print $4}')
	START="0x10000"
	objdump $DUMP -b binary -m i386 -D $OUT --adjust-vma="$OFF" --start-address="$START"
fi

set +e
ls -l $OUT
strace -frni ./$OUT
echo ret $?
exit

%endif

%define REG_OPT		1
%define REG_SEARCH	1
%define REG_ASSERT	0
%ifndef	LINCOM
%define LINCOM		0
%endif

%include "stdlib.mac"

%ifndef JUMPNEXT
%define JUMPNEXT	1
%endif
%ifndef HARDCODE
%define HARDCODE	0
%endif
%if HARDCODE ; && (!WORD_TABLE && WORD_SIZE == 2)
	%define	TABLE_OFFSET	STATIC_TABLE
%else
	%define	TABLE_OFFSET	edi
%endif
%define	FORTH_OFFSET	esi
%define	NEXT_WORD	eax

%assign	WORD_COUNT	0
%define zero_seg	1

%ifndef WORD_ALIGN
%define WORD_ALIGN	1
%endif
;%ifndef WORD_TABLE
;%define WORD_TABLE	0
;%endif
%ifndef WORD_FOOBEL
%define WORD_FOOBEL	0
%endif
%ifndef WORD_SIZE
%define WORD_SIZE	1
%endif
;%ifndef WORD_SMALLTABLE
;%define WORD_SMALLTABLE 1
;%endif

; XXX quick&dirty hack
%if   WORD_SIZE == 0
	%define WORD_TABLE	0
	%define WORD_SMALLTABLE 0
	%define lodsWORD lodsb
	%define WORD_TYPE byte
	%define WORD_DEF db
	%define WORD_SIZE 1

%elif WORD_SIZE == 1
	%define WORD_TABLE	1
	%define WORD_SMALLTABLE 1
	%define lodsWORD lodsb
	%define WORD_TYPE byte
	%define WORD_DEF db
%elif WORD_SIZE == 2
	%define WORD_TABLE	0
	%define WORD_SMALLTABLE 0
	%define lodsWORD lodsw
	%define WORD_TYPE word
	%define WORD_DEF dw
%elif WORD_SIZE == 4
	%define WORD_TABLE	0
	%define WORD_SMALLTABLE 0
	%define lodsWORD lodsd
	%define WORD_TYPE dword
	%define WORD_DEF dd
%else
	%error illegal word size WORD_SIZE
%endif

; 52 byte for ELF header, 32 byte for each program header
%define elf_extra_align 0
%if WORD_ALIGN == 8
	%define elf_extra_align 4
%endif
%define ELF_HEADER_SIZE (52 + 1*32 + elf_extra_align)
;mov	eax, $$ - ELF_HEADER_SIZE - ORG

; **** Macros ****
%macro NEXT 0
	%if JUMPNEXT
		jmp short lastnext
	%else
		realNEXT
	%endif
%endmacro

%macro realNEXT 0
	%%next:
	%if !WORD_TABLE && WORD_SIZE == 4
		%if WORD_FOOBEL
			; + just a single register for NEXT
			; - a bit bigger than the other solution
			lea	FORTH_OFFSET, [FORTH_OFFSET+4]
			jmp	[FORTH_OFFSET]
		%else
			lodsWORD
			jmp	NEXT_WORD
		%endif
	%elif !WORD_TABLE && WORD_SIZE == 2
		%if 0
			movzx	NEXT_WORD, word [FORTH_OFFSET]
			add	NEXT_WORD, TABLE_OFFSET
			;add	FORTH_OFFSET, WORD_SIZE
			inc	FORTH_OFFSET
			inc	FORTH_OFFSET
			jmp	short NEXT_WORD
		%else
			mov	eax, TABLE_OFFSET
			lodsWORD
			%if WORD_ALIGN > 1
				%error not working atm
				;lea	NEXT_WORD, [WORD_ALIGN*NEXT_WORD+ASM_OFFSET]
			%endif
			jmp	short NEXT_WORD
		%endif

	%elif !WORD_TABLE && WORD_SIZE == 1
		%if WORD_ALIGN > 1
			;%error not working atm
			;lea	NEXT_WORD, [WORD_ALIGN*NEXT_WORD+ASM_OFFSET]
			xor	eax, eax
			;mov	eax, TABLE_OFFSET
			lodsWORD
			;imul	eax, eax, WORD_ALIGN
			;add	eax, TABLE_OFFSET
			lea	eax, [eax*WORD_ALIGN+TABLE_OFFSET]
			jmp	short NEXT_WORD
		%else
			mov	eax, TABLE_OFFSET
			lodsWORD
			jmp	short NEXT_WORD
		%endif
	%elif WORD_SMALLTABLE
		;mov	eax, TABLE_OFFSET
		;lodsWORD
		;%if WORD_ALIGN > 1
		;	%error not working atm
		;	;lea	NEXT_WORD, [WORD_ALIGN*NEXT_WORD+ASM_OFFSET]
		;%endif
		;jmp	NEXT_WORD
		
		%if 0
			set	NEXT_WORD, 0
			lodsWORD
			movzx	eax, al
			%define OFF (STATIC_TABLE - $$ + ELF_HEADER_SIZE)
			movzx	NEXT_WORD, word [TABLE_OFFSET + 2*NEXT_WORD + OFF]
			add	NEXT_WORD, TABLE_OFFSET
			jmp	short NEXT_WORD
		%elif 1
			set	NEXT_WORD, 0
			lodsWORD
			%define OFF (STATIC_TABLE - $$ + ELF_HEADER_SIZE)
			;mov	eax, [TABLE_OFFSET + 2*NEXT_WORD + OFF]
			;mov	ax, [TABLE_OFFSET + 2*NEXT_WORD + OFF]
			;mov	ax, [STATIC_TABLE + 2*NEXT_WORD]

			movzx	eax, word [STATIC_TABLE + 2*NEXT_WORD]
			;movzx	eax, word [TABLE_OFFSET + 2*NEXT_WORD + OFF]

			add	NEXT_WORD, TABLE_OFFSET
			jmp	short NEXT_WORD

		%elif 0
			;mov	NEXT_WORD, edi
			set	NEXT_WORD, 0
			lodsWORD
			;cbw
			;cwde
			;movzx	eax, byte [esi]
			;inc	esi
			;add	eax, al
			;push	ax
			;add	eax, eax
			;add	eax, STATIC_TABLE
			;movzx	eax, al
			%define OFF (STATIC_TABLE - $$ + ELF_HEADER_SIZE)
			mov	eax, [STATIC_TABLE + 2*NEXT_WORD]
			;mov	eax, [edi+2*eax+OFF]
			cwde
			;movzx	eax, word [TABLE_OFFSET + 2*NEXT_WORD + OFF]
			add	eax, TABLE_OFFSET
			;mov	ax, [TABLE_OFFSET + 2*NEXT_WORD + OFF]
			;mov	ax, [STATIC_TABLE + 2*NEXT_WORD]

			;set	eax, edi
			;movzx	eax, word [STATIC_TABLE + 2*NEXT_WORD]

			;add	NEXT_WORD, TABLE_OFFSET
			jmp	short NEXT_WORD

		%else	; striped table
			mov	ecx, edi
			lodsWORD
			push	eax
			;mov	ebx, STATIC_TABLE
			mov	ebx, edi
			mov	bl, 0xA4
			xlat
			mov	cl, al
			inc	bh
			pop	eax
			xlat
			mov	ch, al
			jmp	short ecx
		%endif
;		;mov	ax, word [TABLE_OFFSET + 2*NEXT_WORD]


;		%ifnidn NEXT_WORD,eax
;			%error NEXT__WORD is not eax
;		%endif
;		%if WORD_SIZE == 1
;			set	NEXT_WORD, 0
;		%endif
;		lodsWORD
;		%if WORD_SIZE == 2
;			cwde
;		%endif
;		;mov	ax, word [TABLE_OFFSET + 2*NEXT_WORD]
;		movzx	eax, word [TABLE_OFFSET + 2*NEXT_WORD]
;		%if 1
;			add	NEXT_WORD, DEF0
;			jmp	NEXT_WORD
;		%else
;			jmp	[NEXT_WORD + DEF0]
;		%endif
;		;DIRECT_EXECUTE reg
	%elif 0
		;movzx	NEXT_WORD, byte [FORTH_OFFSET]
		;inc	FORTH_OFFSET
		set	NEXT_WORD, 0
		lodsWORD
		push	dword [TABLE_OFFSET + 4*NEXT_WORD]
		;taint	NEXT_WORD
		ret
	%elif 0
		; + freely choose which registers to use
		; - every NEXT is 1 byte longer
		movzx	NEXT_WORD, WORD_TYPE [FORTH_OFFSET]
		inc	FORTH_OFFSET
		taint	NEXT_WORD
		jmp	[TABLE_OFFSET + 4*NEXT_WORD]
	%else
		%ifnidn NEXT_WORD,eax
			%error NEXT__WORD is not eax
		%endif
		%if WORD_SIZE == 1
			set	NEXT_WORD, 0
		%endif
		lodsWORD
		%if WORD_SIZE == 2
			cwde
		%endif
		%if 1
			jmp	[TABLE_OFFSET + 4*NEXT_WORD]
		%else
			mov	eax, [TABLE_OFFSET + 4*NEXT_WORD]
			jmp	eax
		%endif
	%endif
	;mov	NEXT_WORD, [TABLE_OFFSET + 4*NEXT_WORD]
	;lea	NEXT_WORD, [TABLE_OFFSET + 4*NEXT_WORD]
	;jmp	NEXT_WORD
	;jmp	[NEXT_WORD]

%endmacro

%macro DEF 1-2
	%if %0 == 1
		NEXT
	%endif
	align WORD_ALIGN, nop
	; objdump prints the lexicographical smallest label. change A to E
	; or something to get the DEFn labels
	A_%tok(%1):
	DEF%[WORD_COUNT]:
	%define %[n_%tok(%1)] %[WORD_COUNT]
	%define %[f_%tok(%1)] WORD %[WORD_COUNT]
	%warning NEW DEFINITION: DEF%[WORD_COUNT] %1
	rtaint
	%if !WORD_SMALLTABLE && WORD_TABLE
		rset	NEXT_WORD, WORD_COUNT
	%endif
	%assign WORD_COUNT WORD_COUNT+1
%endmacro

%macro DEFFORTH 1
	DEF %1, no_next
	DOCOL
%endmacro

; TODO: use nasm context stack?
%macro ENDDEF 0
	f_EXIT
%endmacro

%macro WORD 1
	%if !WORD_TABLE && WORD_SIZE == 4
		WORD_DEF DEF%1
	%elif !WORD_TABLE && WORD_SIZE == 2
		WORD_DEF (DEF%1 - DEF0 + ELF_HEADER_SIZE)/WORD_ALIGN
	%elif !WORD_TABLE && WORD_SIZE == 1
		WORD_DEF (DEF%1 - DEF0 + ELF_HEADER_SIZE)/WORD_ALIGN
	%else
		WORD_DEF %1
	%endif
%endmacro

%macro OVERRIDE_NEXT 1
	push n_%[%1]
	set FORTH_OFFSET, esp
%endmacro

%macro DIRECT_EXECUTE 1
	jmp short A_%[%1]
%endmacro

; execute 2 words. Undefined behaviour if the second word doesn't exit
; Second word has to be already defined.
; Second word is expected to be something like "exit"
%macro EXECUTE2 2
	OVERRIDE_NEXT	%2
	DIRECT_EXECUTE	%1
%endmacro

%macro DOCOL 0
	DIRECT_EXECUTE DOCOL
	%%forth:
%endmacro

%imacro rspop 1
	xchg	ebp, esp
	pop	%1
	xchg	ebp, esp
%endmacro

%imacro rspush 1
	xchg	ebp, esp
	push	%1
	xchg	ebp, esp
%endmacro

%imacro lit 1
	%if %1 >= 0 && %1 < 256
		f_lit8
		db %1
	%else
		f_lit32
		dd %1
	%endif
%endmacro

%if LINCOM
	[map all nasm.map]
%endif

; **** Forth code ****
SECTION .rodata align=1 follows=.text
A_FORTH:
FORTH:
	
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
AAAA:
	%define OFF (FORTH - $$ + ELF_HEADER_SIZE)
	;mov	eax, TABLE_OFFSET
	BBB:
	;mov	al, OFF
	mov	eax, FORTH - 2
CCC:
	;lea	eax, [TABLE_OFFSET  + OFF]
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
%endif

; **** Codeword definitions ****

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

SECTION .rodata align=1 follows=.text
;A_FORTH:
;FORTH:
	f_triple
	;f_sc
	;f_triple
	;f_EXIT
	f_exit



; **** Jump table ****
SECTION .rodata align=1 follows=.text
%if WORD_TABLE
	STATIC_TABLE:
	A_STATIC_TABLE:
	%warning WORD COUNT: WORD_COUNT
	%assign	i 0
	%rep	WORD_COUNT
		%if WORD_SMALLTABLE
			dw (DEF%[i] - DEF0 + ELF_HEADER_SIZE)/WORD_ALIGN
		%else
			%error unsupported atm
			dd DEF%[i]
		%endif
		%assign i i+1
	%endrep
	%if WORD_SMALLTABLE
		;times (256-WORD_COUNT) dw (DEF1 - DEF0)/WORD_ALIGN
	%else
		;times (256-WORD_COUNT) dd DEF1
	%endif
	A_END_TABLE:
%endif


%include "regdump2.mac"


