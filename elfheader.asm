true : ;yasm -f bin -o elfheader $0 && ls -l elfheader && chmod +x elfheader && objdas elfheader && ./elfheader; echo ret $?; exit

;; true.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o true true.asm && chmod +x true
;;	ln true false

BITS 32
START equ _start2
		org	0x68400000

		db	0x7F, "ELF"
		dd	1
		dd	0
		dd	$$			; vaddr
		dw	2
		dw	3
		dd	START 			; garbage/filesz
		dd	START 			; start/memsz
		dd	4
_start:

times 10-$+_start db	0x90
		;db	169
		dw	0x20
		dw	1

_start2:
