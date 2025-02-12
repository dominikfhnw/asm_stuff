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

%include "stdlib.mac"

%define REPLACE 0

BASE	0x3d499000
%define REG_OPT 1
rinit
ELF 1
	pop	edi	;argc
	; start of arg/env/aux string area
	pop	edi
	push	edi
	; find end of string area marked by a dword == 0
	repne	scasd

	; ecx contains 0 - (number of doublewords)
	; multiply by -4 to get number of bytes
	set	edx, 10
	;mov	dl, 10
	;set	ebx, 1
;reg


	std
.strrep:
	;dec	edi
	;reg
		;cmp 	[edi], byte 0
		repne scasb
		;add	al, [edi]
		;cmpxchg	[edi], dl
ELF_PHDR 1
		;jnz	.notzero
		;dec	edi
		mov	[edi+1], dl
		;mov	al, 0
		;set	eax, 0
		cmp	edi, esp
		;reg
	ja	.strrep
	;zero	ebx	

	;imul	edx, ecx, -4
;reg
	pop	ecx

;reg
	cdq
	dec	edx
reg
	;putsexit ecx, x
	exit

;lea edi, [esp]
;mov edi, [esp]

%include "regdump2.mac"
