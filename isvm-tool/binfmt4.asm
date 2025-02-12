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
#DUMP="--no-addresses -Mintel"
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
;%define reg_stack 0
ELF
rinit

%imacro ychg arg(2)
	rget	%1
	%assign yval1 reg_val
	rget	%2
	%assign yval2 reg_val

	rset	%1, yval2
	rset	%2, yval1
	xchg	%1, %2

%endmacro

antistrace
;secretstack
;antiptrace2
mmap_final:
;mmap	0x10000, 0xffff, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE | MAP_FIXED | MAP_ANONYMOUS, 0, 0
; strace shows less when PROT_READ not set
mmap	0x10000, 0xffff, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE | MAP_FIXED | MAP_ANONYMOUS, x, x
err	0x10000
%if !ERRHANDLE
	rset	eax, 0x10000
%endif
rdump

memset:
ychg	eax, edi
sub	ecx, 6
rset	ecx, 0xffff - 6

memset	0x10000, 0x90, ecx
mov	esi, error2
taint	esi
set	ecx, 6
rep	movsb
rset	ecx, 0

auxval:
	; XXX ebp if secretstack, esp otherwise
	set	edi, esp
	set	eax, 0
	;rdump
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

	reg
	rset	eax, -2
	rdump
	; IST
	; eax FD
	; ebx 0x10000
	; ecx -1
	; edx 7
	; ebp 0
	;
	; SOLL
	; eax 7-4
	; ebx FD
	; ecx 0x10000
	; edx 0xffff

	set	ecx, ebx
	ychg	ebx, eax
	ychg	edx, eax
	
	copy:
	rdump
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
jmp	0x10000


	error:
	neg	eax
	error2:	
	xchg	eax, ebx
	xor	eax, eax
	inc	eax
	int	0x80

		.end:

%include "regdump2.mac"

%if 0
call	auxval
mov	ebp, auxval
movd	mm0, ebp
call	ebp
movd	ebp, mm0
lea	eax, [ebp+eax*4]
lea	eax, [ebx+eax*4]
call	eax
%endif
