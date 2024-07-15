true : ;out=$(basename $0 .asm);yasm -f bin -o $out $0 && ls -l $out && chmod +x $out && objdas $out && strace ./$out; echo ret $?; exit

;; true.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o true true.asm && chmod +x true
;;	ln true false
%define SYSCALL int 0x80
;%define SYSCALL sysenter

BITS 32
START equ _start
		org	0x3d490000

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
add	dl, 3
mov	ebx, $$

jmp	_start2
times $$-$+42	db	0x90
		;db	169
		dw	0x20
		dw	1

_start2:
add	al, 125
SYSCALL
;int	0

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
