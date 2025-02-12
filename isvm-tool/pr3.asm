true : ;OUT=pr3;nasm -I ../asmlib/ -f bin -o $OUT $0 "$@" 2>&1 | grep -vF ' ... from macro ' && ls -l $OUT && chmod +x $OUT && objdump -b binary -m i386 -D $OUT -z --adjust-vma=0x3d504000 --start-address=0x3d504019 && ./$OUT; echo ret $?; exit
;; true.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o true true.asm && chmod +x true
;;	ln true false


%include "stdlib.mac"
;%include "generic.mac"
%define REG_OPT 1
ELF
BASE 0x05909000
	;mov	eax, 0x80000004
	bts	eax, 31
	mov	ebp, eax
	;push	0xA
ll:	cpuid
	push	edx

ELF_PHDR 1
	push	ecx
	push	ebx
	push	eax
	dec	ebp
	reg
	mov	eax, ebp
	cmp	bp, 1
	jg	ll
	putsexit esp, 48

%include "regdump2.mac"
	
