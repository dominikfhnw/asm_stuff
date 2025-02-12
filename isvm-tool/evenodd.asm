%if 0

OUT=evenodd
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

%include "stdlib.mac"
ELF 1
rinit
%if ELF_CUSTOM
	BASE 0x68909000
	;rset	eax, 0xc0
%endif

read	STDIN, esp, 1
pop	ecx
reg
inc	ecx
push 	'even'
jp	.next
push	`odd\0`
.next:
putsexit	esp, 4

%include "regdump2.mac"

