%if 0

OUT=print
set -e
nasm -I asmlib/ -f bin -o $OUT $0 "$@" 2>&1 | grep -vF ': ... from macro '
ls -l $OUT
chmod +x $OUT

OFF=$(  readelf -lW $OUT 2>/dev/null | awk '$2=="0x000000"{print $3}')
START=$(readelf -hW $OUT 2>/dev/null | awk '$1=="Entry"{print $4}')
objdump -Mintel -b binary -m i386 -D $OUT --adjust-vma=$OFF --start-address=$START

set +e
./$OUT
echo ret $?
exit
%endif

%define MSG `hello, world\n`
%strlen LEN MSG
%define REG_OPT 1

%include "stdlib.mac"
ELF

BASE 0x05439000
rinit
rset	eax, 4
rset	ebx, 1

	;puts	ecx, LEN

	mov	ecx, msg
	set	edx, LEN
	int	0x80
	ELF_PHDR 3

	xchg	eax, ebx
	int	0x80
	;pop	eax
	;xchg	eax, ebx
	;int	0x80

msg:	db	MSG

