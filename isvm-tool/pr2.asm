true : ;OUT=pr2;nasm -I ../asmlib/ -f bin -o $OUT $0 "$@" 2>&1 | grep -vF ' ... from macro ' && ls -l $OUT && chmod +x $OUT && objdump -b binary -m i386 -D $OUT -z --adjust-vma=0x3d504000 --start-address=0x3d504019 && ./$OUT; echo -e "\nret $?"; exit
;; true.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o true true.asm && chmod +x true
;;	ln true false


%include "stdlib.mac"
%define REG_OPT 1
ELF
BASE 0x68904000
	shl	eax, 30
	;rinit
	;reg
	;bts	eax, 30
	;reg
	;setfz	eax, 0x40000000
	;reg
	cpuid
	pop	eax
	rset	eax, 4
	push	edx
	push	ecx
	push	ebx

ELF_PHDR 1
	putsexit esp, 12

%include "regdump2.mac"
	
