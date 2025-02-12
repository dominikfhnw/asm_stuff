%if 0

OUT=binfmt3
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
DUMP="-Mintel"
if [ "${FULL-1}" = 1 ]; then
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
#strace -s 64 -rni ./$OUT 127.0.0.1
echo ret $?
exit

%endif

; reg_simple: 202b
; reg_deflt:  182b
; reg_opt:    170b
%define REG_OPT 1
%define REG_SIMPLE 0

; full ELF	+61b
; errhandle	+13b
; find_fd	+13b
; close_fd	+07b
; full_mmap	+01b
; cleanup	+10b
%define ERRHANDLE	1
%define FIND_FD		1
%define CLOSE_FD	1
%define FULL_MMAP	1
%define CLEANUP		1

%imacro err 0-1 -4
	%if ERRHANDLE
	test	eax, eax
	%if 1
		js	.error
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

%imacro XXassert 2
	pushf
	cmp	%1, %2
	je	%%assert_ok
	mov	eax, 0xDEADBEEF
	mov	ebx, $
	int3
	%%assert_ok:
	popf
%endmacro

%include "stdlib.mac"
ELF
rinit
%if ELF_CUSTOM
	BASE 0x68c0b000
	rset	eax, 0xc0
%endif

%define SC_DEBUG 0

%if FIND_FD
	dup	0
	err	-2

	ELF_PHDR 1
	mov	ebx, eax
	rset	ebx, -2
	xchg	eax, edi
	rset	edi, -2
	rset	eax, 0
	inc	eax
	close	ebx
	err	0
	dec	edi
%else
	ELF_PHDR 1
	set	edi, 3
%endif

rdump
%if FULL_MMAP
	mmap	0x10000, 0xffff, (PROT_READ | PROT_WRITE | PROT_EXEC), (MAP_PRIVATE | MAP_FIXED), edi, 0
%else
	mmap	0x0ffff, 0xffff, (PROT_READ | PROT_WRITE | PROT_EXEC), (MAP_PRIVATE), edi, 0
%endif
err

;taint	eax,ebx,ecx, edx, esi
;set    eax, 0x10000
;set    ebx, 0x0FF00
;set    ecx, 0x0FF00
;set    edx, 0x4
;set    esi, 0

;xchg	eax, ecx
;rset	ecx, 0x10000
;rset	eax, 0xff00

%if CLOSE_FD
close	edi
err	0
%endif

%if CLEANUP
zero	ebx, ecx, edx, esi, edi
%endif
jmp	0x10000


%if ERRHANDLE
	.error:
	;xchg	eax, ebx
	;neg	ebx
	imul	ebx, eax, -1
	taint	eax, ebx
	exit ebx
%endif

%define SC_DEBUG 0
%include "regdump2.mac"

