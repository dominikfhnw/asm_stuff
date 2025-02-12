%if 0

OUT=hi
##set -e
nasm -I asmlib/ -f bin -o $OUT $0 "$@" 2>&1 | grep -vF ': ... from macro '
ls -l $OUT
chmod +x $OUT

OFF=$(  readelf2 -lW $OUT 2>/dev/null | awk '$2=="0x000000"{print $3}')
START=$(readelf2 -hW $OUT 2>/dev/null | awk '$1=="Entry"{print $4}')
objdump -Mintel -b binary -m i386 -D $OUT --adjust-vma=$OFF --start-address=$START

set +e
./$OUT
echo ret $?
exit
%endif

%define REG_OPT 1
;%define ELF_OFFSET 1

%include "stdlib.mac"
ELF

BASE 0x35424000
rinit
.e:

	pop	ecx
	pop	ecx
	;mov	ecx, [esp+4]
	inc	ecx
	inc	ecx
	inc	edx

	dec	eax
	int	0x80
	jmp	.e
	ELF_PHDR
	;add	[ecx], dword `gi\0\0`

%include "regdump2.mac"
