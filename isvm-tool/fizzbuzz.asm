true : ;OUT=fizzbuzz; nasm -Lmes -l out -I asmlib/ -f bin -o $OUT $0 "$@" 2>&1 | grep -vF ' ... from macro ' && ls -l $OUT && chmod +x $OUT && objdump -Mintel -b binary -m i386 -D $OUT --adjust-vma=0x3d994000 --start-address=0x3d994019 && ./$OUT; echo ret $?; exit
true : ;OUT=fizzbuzz; nasm -Lmes -l out -I asmlib/ -f bin -o $OUT $0 "$@" 2>&1 | grep -vF ' ... from macro ' && ls -l $OUT && chmod +x $OUT && objdump --no-addresses -Mintel -b binary -m i386 -D $OUT --adjust-vma=0x3d994000 --start-address=0x3d994019 && ./$OUT; echo ret $?; exit

; MAX < 128:	131
;    128..254:	134
; MAX ==  255:	132
; MAX ==  256:	133
;   257..1000:	135
; MAX ==  512:	133
; MAX == 1024:	134
; MAX == 2048:	134
; 1000..10000:	136
;10001..	137
;    Infinite:	127

; sorted:
;    Infinite:	127
; MAX < 128:	131
; MAX ==  255:	132
; MAX ==  256:	133
; MAX ==  512:	133
;    128..254:	134
; MAX == 1024:	134
; MAX == 2048:	134
; MAX == 4096:	134
; MAX == 8192:	134
; MAX == 16384:	135
; MAX == 32768:	135???
;   257..1000:	135
; 1001..10000:	136
;     10001..:	137

%ifndef MAX
%define MAX	127
%endif

%define	REG_OPT	1

%include "stdlib.mac"
ELF 
BASE 0x3d994000

;rinit
%if MAX == 0 || MAX > 255
rset	eax, -1
%else
rset	eax, 1
%endif
rset	ebx, -2
rset	edx, -2

; eax: number
; ebx: divisor/fd
; ecx: string pointer
; edx: remainder/string length
; ebp: unused
; esi: itoa length
; edi: itoa saved eax

;arg1 must not be negative
%macro isdiv 2
	push	eax
	push	edx
	set	eax, %1
	set	ebx, %2
	cdq
	;reg
	div	ebx
	;reg
	test	edx, edx
	;cdq
	pop	edx
	pop	eax
%endmacro


	;inc	eax	;encoded in  memory address
	;cdq		;encoded in  memory address
	push	0xA

	push	eax
	set	ebx, 5
	div	ebx
	test	edx, edx

ELF_PHDR 2
	pop	eax
	cdq
	reg
	jnz	.notfive
	push	'Buzz'
	set	edx, 4

	.notfive:
	;reg
	isdiv	eax, 3
	jnz	.notthree
	push	'Fizz'
	lea	edx, [edx+4]
	.notthree:
	;reg
	mov	ecx, esp
	mov	edi, eax
	;rdump
	test	edx, edx
	jnz	.next
		; edx == 0
		%if MAX > 10000 || MAX == 0
		push	edx
		push	edx
		%else
		push	edx
		%endif
		set	ebx, 10

		.itoa:
			inc	esi
			;reg
			div	ebx
			;reg
			or	dl, '0'
			dec	ecx
			xchg	[ecx], dl
			test	eax, eax
			;reg
		jnz	.itoa

		xchg	edx, esi

	.next:
	;reg
	;rset	eax, -2
	inc	edx
	;push	eax
	puts	ecx, edx
	;reg
	;pop	eax
	xchg	eax, edi

%if MAX == 0 
	jmp	START
%else
	%if MAX < 128
		cmp	al, MAX
	%elif MAX == 255
		cmp	ah, 1
	%elif MAX % 256 == 0
		cmp	ah, MAX/256
	%else
		cmp	eax, MAX
	%endif

	jb	START
	;reg
	;rdump
	mov	eax, ebx
	dec	ebx
	;xchg	eax, ebx
	;zero	ebx
	int	0x80
%endif
%include "regdump2.mac"

%if 0
alloca 0
alloca 1
alloca 127
alloca 128
alloca 129

push	0
push	eax

lea	esp, [esp-12]
lea	esp, [esp-127]
lea	esp, [esp-128]
lea	esp, [esp-129]
lea	eax, [esp-12]
lea	esp, [eax-12]
lea	esp, [esp-135]
alloca 135
sub	esp, 135
set	eax, 135
sub	esp, eax

mov	al, 135
movzx	eax, al

push	135
pop	eax
%endif
