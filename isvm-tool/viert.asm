%if 0

OUT=viert
set -e
#set -o pipefail
if [ -n "${FULL-}" ]; then
	rm -f $OUT $OUT.o
	nasm -g -I asmlib/ -f elf32 -o $OUT.o "$0" "$@" 2>&1 | grep -vF ': ... from macro '
	#FLAGS="-z noexecstack"
	FLAGS=
	ld $FLAGS -m elf_i386 -z noseparate-code $OUT.o -o $OUT
	cp $OUT $OUT.full
	ls -l $OUT.full
	#sstrip -z $OUT
	sstrip $OUT
else
	rm -f $OUT
	nasm -I asmlib/ -f bin -o $OUT "$0" "$@" 2>&1 | grep -vF ': ... from macro '
fi
ls -l $OUT
chmod +x $OUT

#DUMP="--no-addresses -Mintel"
DUMP="-Mintel"
#DUMP="--no-addresses -Mintel"
if [ -n "${FULL-}" ]; then
	#objdump --visualize-jumps=color -d $OUT.full
	objdump $DUMP -d $OUT.full
else
	OFF=$(  readelf2 -lW $OUT 2>/dev/null | awk '$2=="0x000000"{print $3}')
	#OFF="0x10000"
	START=$(readelf2 -hW $OUT 2>/dev/null | awk '$1=="Entry"{print $4}')
	objdump $DUMP -b binary -m i386 -D $OUT --adjust-vma="$OFF" --start-address="$START"
	#objdump --visualize-jumps=color -b binary -m i386 -D $OUT --adjust-vma="$OFF" --start-address="$START"
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
%define LINCOM		0

%include "stdlib.mac"

%define	BASE		edi
%define	STATIC		1
%define zero_seg	0

%macro NEXT 0
	%%next:
	%if 0
		movzx	eax, byte [esi]
		inc	esi
	%else
		set	eax, 0
		lodsb
	%endif
	jmp	[BASE + 4*eax]

	;mov	BASE, fs
	;jmp	[fs:0 + eax*4]
%endmacro

%macro	DEF 1
	NEXT
	DEF%1:
	rtaint
	rset	eax, %1
%endmacro

%macro TABLE 1
	add	eax, %1 - LASTDEF
	taint	eax
	stosd
	%define LASTDEF %1
%endmacro

%macro WORD 1
	db %1
%endmacro


%if ELF_CUSTOM
	rinit
	ELF 
	%if STATIC
	%else
		BASE	0x3dc0b000
		rset	eax, 0xC0
		mmap	0, 0xFFFF, PROT_EXEC | PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, 0, 0
	%endif
	ELF_PHDR 1

	jmp	create_table
%endif

; **** Forth code ****
FORTH:
	db 1
	db 2
	db 1
	db 1
	db 0

%if STATIC
STATIC_TABLE:
	dd DEF0
	dd DEF1
	dd DEF2
;%define	BASE  STATIC_TABLE
%endif

; **** Codeword definitions ****
DEF0:
	rtaint
	exit	x

DEF 1
	printstr "HEYA"

DEF 2
	sleep 1

lastnext:
	NEXT


; **** Start of program ****
%if !ELF_CUSTOM
	_start:
	rinit
	%if !STATIC
		mmap	0, 0xFFFF, PROT_EXEC | PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, 0, 0
	%endif
%endif

create_table:
%if !STATIC
	push	eax
	ychg	edi, eax

	mov	eax, DEF0
	%define LASTDEF DEF0
	stosd

	TABLE DEF1
	TABLE DEF2
%endif

start_interpreter:
set	esi, FORTH
taint	esi
%if STATIC
	set	BASE, STATIC_TABLE
%else
	pop	BASE
%endif
jmp	lastnext

%include "regdump2.mac"
