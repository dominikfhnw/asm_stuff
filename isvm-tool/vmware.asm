%if 0

#OFF=0x680ab000
#START=$(( OFF + 25 ))

OUT=vmware
set -e
nasm -I asmlib/ -f bin -o $OUT $0 "$@" 2>&1 | grep -vF ' ... from macro '
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


%define REG_OPT 1
%include "stdlib.mac"
ELF
BASE 0x680ab000
	rinit
	;rdump
	set	ebx, 0
	set	edx, 'XV'
	set	ecx, 'hXMV'
ELF_PHDR 1
	xchg	eax, ecx
	;push	eax
	;mov	ebx, ebp
	;set	ecx, 0xA
	;mov	dl, 0x58
	;mov	dh, 0x56
	;set	dx, 'XV'
	reg
	in	eax, dx
	;pop	eax
	;cmp	ebx, ebp
	;setc	bl

	;exit	x
	exit

%include "regdump2.mac"
