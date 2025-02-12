%if 0

OUT=binfmt4
set -e
#set -o pipefail
if [ "${FULL-1}" = 1 ]; then
	#set -x
	rm -f $OUT $OUT.o
	nasm -g -I asmlib/ -f elf32 -o $OUT.o "$0" "$@" 2>&1 | grep -vF ': ... from macro '
	#ld -m elf_i386 -z noseparate-code $OUT.o -o $OUT
	if [ -n "${HARDEN-}" ]; then
		ld -z ibt -z shstk --script link -m elf_i386 -u __stack_chk_fail -u __gets_chk -z relro -z now --build-id=none --orphan-handling=warn -z noseparate-code $OUT.o -o $OUT
		readelf -Wa $OUT
		cp $OUT $OUT.full
		ls -l $OUT.full
		cat rechead2 > s.c
		elftoc -e $OUT >> s.c
		echo -e '#include <stdio.h>\nint main(void) { fwrite(&foo, 1, offsetof(elf, _end), stdout);return(0); }' >> s.c
		#strip --strip-dwo -wK'*' -R .hash -R .gnu.hash -R .gnu.version -R .gnu.version_r -R .got -R .got.plt -R .rel.plt -R .rel.got $OUT.full
		sed -i 's/PT_NULL/PT_GNU_RELRO/' s.c
		bash ./s.c
		strace -ni ./cust 127.0.0.1 ||:
		echo
		echo "## CHECKSEC"
		checksec --file=cust ||:
		echo
		echo "## HARDENING-CHECK"
		hardening-check -c cust
	else
		FLAGS="--build-id=none --orphan-handling=warn --gc-sections --print-gc-sections" 
		ld $FLAGS -m elf_i386 -z noseparate-code $OUT.o -o $OUT
		cp $OUT $OUT.full
		ls -l $OUT.full
	fi
	sstrip -z $OUT
else
	rm -f $OUT
	#nasm -I asmlib/ -f bin -o $OUT "$0" "$@"
	nasm -I asmlib/ -f bin -o $OUT "$0" "$@" 2>&1 | grep -vF ': ... from macro '
fi
ls -l $OUT
chmod +x $OUT

#DUMP="--no-addresses -Mintel"
DUMP="-Sl -Mintel"
DUMP="-Mintel"
DUMP="--no-addresses -Mintel"
if false
then
	r2 -c aa -c "e emu.str = true" -c pdf -q binfmt4.full
elif [ "${FULL-1}" = 1 ]; then
	#objdump --visualize-jumps=color -d $OUT.full
	objdump $DUMP -d $OUT.full
else
	OFF=$(  readelf2 -lW $OUT 2>/dev/null | awk '$2=="0x000000"{print $3}')
	START=$(readelf2 -hW $OUT 2>/dev/null | awk '$1=="Entry"{print $4}')
	objdump $DUMP -b binary -m i386 -D $OUT --adjust-vma="$OFF" --start-address="$START"
	#objdump --visualize-jumps=color -b binary -m i386 -D $OUT --adjust-vma="$OFF" --start-address="$START"
fi

set +e
ls -l $OUT
echo ret $?
exit

%endif

%define REG_OPT    1
%define REG_ASSERT 0
%define REG_SIMPLE 0
%define REG_SEARCH 1

%xdefine L .nolist

%define ERRHANDLE	1
%define FIND_FD		0
%define CLOSE_FD	1
%define FULL_MMAP	1
%define CLEANUP		1

%imacro err 0-1.nolist -4
	%if ERRHANDLE
	test	eax, eax
	%if 1
		js	error
	%else
		jns	%%next
		set	ebx, 1
		xchg	eax, ebx
		int	0x80
		%%next:
	%endif
	rset	eax, %1
	%endif
%endmacro

%include "stdlib.mac"
%define reg_stack 0
ELF
rinit
%define SC_DEBUG 0

%imacro ychg arg(2)
	rget	%1
	%assign yval1 reg_val
	rget	%2
	%assign yval2 reg_val

	rset	%1, yval2
	rset	%2, yval1
	xchg	%1, %2

%endmacro

mmap_final:
mmap	0x10000, 0xffff, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE | MAP_FIXED | MAP_ANONYMOUS, 0, 0
err	0x10000
%if !ERRHANDLE
	rset	eax, 0x10000
%endif

memset:
ychg	eax, edi
rdump
sub	ecx, 6
memset	0x10000, 0x90, ecx
rdump
mov	esi, error2
taint	esi
set	ecx, 6
rep	movsb
rset	ecx, 0

auxval:
	set	edi, esp
	set	eax, 0
	set	ecx, -1
	repne	scasd
	repne	scasd
	taint	ecx
	ychg	esi, edi

	.loop:
		taint	eax
		lodsd
		cmp	al, 2
		lodsd
	jne	.loop

	rset	eax, -2
copy:
	read	ebx, 0x10000, 0xffff
	err	-3
	close	ebx
	err	0


%if CLEANUP
cleanup:
rtaint
zero	eax, ebx, ecx, edx, esi, edi
%endif
jump:
;jmp	[esp]
jmp	0x10000


;%if ERRHANDLE
	error:
	neg	ebx
	error2:	
	xchg	eax, ebx
	xor	eax, eax
	inc	eax
	int	0x80

	;xchg	eax, ebx
	;neg	ebx
	;;imul	ebx, eax, -1
	;taint	eax, ebx
	;exit ebx
	.end:
;%endif

%if 0
hexprint:
rtaint
pusha
enter	16,0
;mov	ebx, eax
;push	`\n`
;push	0
;push	0
set	edi, esp
;set	ecx, 8
tohex	ebx
rdump
set	eax, 10
stosb
puts	esp, 9
leave
popa
ret
%endif

%define SC_DEBUG 0
%include "regdump2.mac"

%if 0
lea	eax, [eax]
lea	eax, [esp]
lea	eax, [byte esp]
lea	eax, [nosplit esp]
lea	eax, [byte nosplit esp]
lea	eax, [ebp]
lea	eax, [byte ebp+0]

lea	ax, [eax]
lea	eax, [123456]
add	esi, 50
lea	esi, [esi+50]
lea	esi, [esp+50]
%endif
