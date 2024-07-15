true : ;out=$(basename $0 .asm);yasm -f bin -o $out $0 && ls -l $out && chmod +x $out && objdas $out && strace -i ./$out; echo ret $?; exit

;; true.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o true true.asm && chmod +x true
;;	ln true false
%define SYSCALL int 0x80

BITS 32
START equ _start
		org	0x68490000

		db	0x7F, "ELF"
		dd	1
		dd	0
		dd	$$			; vaddr
		dw	2
		dw	3
		dd	START -2		; garbage/filesz
		dd	START -2		; start/memsz
_start:
		dd	4
mov	ebx, $$
add	al, 125
pop	edx
dec	edx
;jmp	_start2
times $$-$+41	db	0x90
		db	169
		dw	0x20
		dw	1

_start2:
SYSCALL

;; initialize base pointer
mov	ebp, esp

%if 0
push 29
pop eax
SYSCALL
%endif
%if 0
mov	edx, 162
;; unneeded if top of stack < 1e9
push	edx
push	edx
mov	ebx,esp

xor	ecx,ecx
; ecx = 0
; edx = 162
; ebx = esp
_loop:
mov	eax,edx
SYSCALL
jmp	_loop

%endif

