true : ;OUT=pr;nasm -I asmlib/ -f bin -o $OUT $0 "$@" && ls -l $OUT && chmod +x $OUT && objdump -b binary -m i386 -D $OUT -z --adjust-vma=0x3d504000 --start-address=0x3d504019 && ./$OUT; echo ret $?; exit
;; true.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o true true.asm && chmod +x true
;;	ln true false


%include "elf.mac"
%include "generic.mac"
%include "syscall.mac"
%define REG_OPT 1
ELF
BASE 0x68909000
	;push eax
	cpuid
	pop	eax
	rset	eax, 4
	%if 1
	push	ecx
	push	edx
	push	ebx
	%else
	pusha
	add	esp,16
	%endif

	set	edx, 12
ELF_PHDR 1
	putsexit esp, 12

