%if 0

OUT=print
set -e
nasm -I asmlib/ -f bin -o $OUT $0 "$@" 2>&1 | grep -vF ': ... from macro '
ls -l $OUT
chmod +x $OUT

OFF=$(  readelf2 -lW $OUT 2>/dev/null | awk '$2=="0x000000"{print $3}')
START=$(readelf2 -hW $OUT 2>/dev/null | awk '$1=="Entry"{print $4}')
objdump -b binary -m i386 -D $OUT --adjust-vma=$OFF --start-address=$START

set +e
./$OUT
echo ret $?
exit


%endif

%define ELF_OFFSET 2
%define MSG `hello, world\n`
%strlen LEN MSG
%define REG_OPT 1

%include "stdlib.mac"
ELF

BASE 0x0d430000
rinit
rset	eax, 4
rset	ebx, 1


	;lea	edx, [3*eax+ebx]
	set	edx, LEN
	push	10
	;enter	0x20, 0x1
	push	`orld`
ELF_PHDR 1
	push	'o, w'
	;add	al, al
	;push	'o, w'
	;push	'hell'
	push	'hell'
	reg
	;exitafterputs
	;xchg	eax, ebx
	;mov	ecx, esp
	;set	edx, -1
	;dec	edx
	;int	0x80
	putsexit	esp, LEN
	;xchg	eax, ebx
	;pop	ebx
	;pop	ebx
	;int	0x80

%include "regdump2.mac"

