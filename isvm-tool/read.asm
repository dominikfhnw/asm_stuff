%if 0

OUT=print
set -e
#set -o pipefail
if [ -n "${FULL-}" ]; then
	set -x
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

if [ -n "${FULL-}" ]; then
	#objdump --visualize-jumps=color -d $OUT.full
	objdump -d $OUT.full
else
	OFF=$(  readelf -lW $OUT 2>/dev/null | awk '$2=="0x000000"{print $3}')
	START=$(readelf -hW $OUT 2>/dev/null | awk '$1=="Entry"{print $4}')
	objdump --no-addresses -b binary -m i386 -D $OUT --adjust-vma="$OFF" --start-address="$START"
	#objdump --visualize-jumps=color -b binary -m i386 -D $OUT --adjust-vma="$OFF" --start-address="$START"
fi

set +e
ls -l $OUT
strace -s 64 -rni ./$OUT 127.0.0.1
echo ret $?
exit

%endif
;%define ELF_OFFSET 2
;%define MSG `hello, world\n`
;%strlen LEN MSG
%define REG_OPT 1

%include "stdlib.mac"
ELF

;BASE 0x0d430000
BASE 0x3d909000
;rset	eax, 4
;rset	ebx, 1
rinit


ELF_PHDR 1
;seccomp_strict
;read	0, 0, -1

secretstack
reg
printstr "haha secret stack"
pause
exit
%if 0
	pop	eax
	pop	eax
	mov	[eax], dword 0
	mov	[eax+4], dword 0
	taint	eax
	pause
%endif

	dec	ecx
	mov	edi, esp
	repne	scasd
	mov	esp, edi
	taint	ecx, edi

	set	ebx, 1
.loop:
	taint	eax
	pop	edi
	test	edi, edi
	;reg
	jz	.exit

	puts	edi
	printstr `\n`

	jmp	.loop
	
.exit:
	;signal 17, 1
	antiptrace2
	;mov	ebp, ebx
	;waitpid	ebx, 0,0
.sleep:
	taint	eax, ebx, ecx, edx
	sleep	1
	mov	ebx, ebp
	taint	ebx
	;waitpid	-1, 0,0x80000000
	printstr "."
	;wait
	jmp	.sleep
	exit




%if 0
	rdump
	reg
%define reg_stack 1
	antiptrace2
%define reg_stack 1
	reg
	rdump
;rinit
	;clone	0x00010000 | 0x00000800 | 0x00000100 | 0x00800000,0,0,0,0
	;clone	0x00010000 | 0x00000800 | 0x00000100 | 0x00000000,0,0,0,0
	exit 42
	getppid
	xchg	eax, ebp
	clone	0x00800000,0,0,0,0
	;clone	0x00000000,0,0,0,0
	;fork
	test	eax,eax
	jnz	.exit
	getppid
	xchg	eax, ecx
	taint	ecx
	ptrace	0x4206, ecx, 0, 0
	reg
	test	eax,eax
	jz	.endcheck
	;getppid
	xchg	ebp, ebx
	kill	ebx, 11
.endcheck:
	hlt
.exit:
	pause
	exit 0
%endif

%include "regdump2.mac"
