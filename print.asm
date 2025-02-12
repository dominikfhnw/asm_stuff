true : ;nasm -Iasmlib/ -f bin -o print $0 && ls -l print && chmod +x print && objdump -b binary -m i386 -D print  -z --adjust-vma=0x3d400000 --start-address=0x3d400019 && echo strace -i ./print foobar; echo ret $?; exit
;; true.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o true true.asm && chmod +x true
;;	ln true false

;START equ _start - 3
%define START _start - 3

%include "stdlib.mac"

%define REPLACE 0

BASE	0x3d499000

ELF
	; set ecx to -1
	;dec	ecx	; encoded in memory address
	pop	edi	;argc
	; start of arg/env/aux string area
	pop	edi
	push	edi	;needed later by write syscall
	; find end of string area marked by a dword == 0
	repne	scasd

	; ecx contains 0 - (number of doublewords)
	; multiply by -4 to get number of bytes
	mov	dl, 10	;newline
	inc	ebx	;STDOUT
;reg
	.strrep:
	dec	edi

ELF_PHDR jump
	;reg
		;add	al, [edi]
		cmpxchg	[edi], dl
		;jnz	.notzero
		;mov	[edi], byte 0x0A
		;.notzero:
		mov	al, 0
		cmp	edi, esp
		reg
	ja	.strrep
	;zero	ebx	

	imul	edx, ecx, -4
	pop	ecx
	mov	al, SYS_write
	int	0x80
reg
	;xchg	eax, ebx
	;sub	ebx, edx
	;int	0x80

reg

%include "regdump2.mac"
