true : ;OUT=cpuf; nasm -I asmlib/ -f bin -o $OUT $0 "$@" && ls -l $OUT && chmod +x $OUT && objdump -b binary -m i386 -D $OUT  -z --adjust-vma=0x3d504000 --start-address=0x3d504019 && ./$OUT; echo ret $?; exit
;; true.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o true true.asm && chmod +x true
;;	ln true false
%include "stdlib.mac"
ELF
BASE 0x3d409000
		;reg
		cpuid
		;mov	ecx, 1
		;reg
		xchg	eax, ecx
		pop	ecx
		;reg
		ror	eax, cl
		;reg
		salc
		;reg
		xor	ebx, ebx
		;test	eax, 0x10020
		;reg
		test	eax, 0x10020
		;reg
		inc	ebx
		;set	ebx, 1
		xchg 	eax, ebx
		int	0x80
%include "regdump2.mac"
