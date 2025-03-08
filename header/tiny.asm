true : ;out=$(basename $0 .asm);yasm -f bin -o $out $0 && ls -l $out && chmod +x $out && objdas $out && ./$out; echo ret $?; exit

;; true.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o true true.asm && chmod +x true
;;	ln true false

BITS 32
START equ _start1
;START equ _start0 - 3
		org	0x3d909000
		;org	0x00001000

		db	0x7F, "ELF"
		dd	1
		dd	0
		dd	$$			; vaddr
		dw	2
		dw	3
		dd	START 			; garbage/filesz
		dd	START 			; start/memsz
_start0:	dd	4

times $$-$+38	nop
		;; initialize base pointer
_start1:	mov	ebp, esp
		jmp	_start2

		;db      169
		dw	0x20
		dw	1

_start2:
	times 6	nop
