true : ;OUT=cpuf; nasm -I asmlib/ -f bin -o $OUT $0 "$@" 2>&1 | grep -vF ' ... from macro ' && ls -l $OUT && chmod +x $OUT && objdump -b binary -m i386 -D $OUT --adjust-vma=0x3d504000 --start-address=0x3d504019 && ./$OUT; echo ret $?; exit
;; true.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o true true.asm && chmod +x true
;;	ln true false

%define ID 7
%define REG ecx

%include "stdlib.mac"
ELF
%if ID == 7 ; EAX=7. Relies on argc being 1.
	BASE 0x3d07b000
%else ; EAX=1
	BASE 0x3d504000
%endif
		;reg
		cpuid
		ror	REG, 3
		;reg
		salc
		;reg
		pop	ebx
		xchg	eax, ebx
		;test	eax, 0x10020
		;reg
		;int	0x80
		ELF_PHDR 1
		;reg
%if 0
	;db 0
	xor	eax, eax
	setfz	eax, 0xFFFF
	reg
	%assign i 1 
	%rep    32 
		xor	eax, eax
		setfz	eax, i
		;reg
		%assign i i*2
	%endrep

	xor	eax, eax
	dec	eax
	mov	ah, 2
	reg
	;times 12 ud2
	xor	eax,eax
	setfz	eax, 0xFFFFFF00
	reg
	xor	eax,eax
	mov	ah, 255
	not	eax
	reg
%endif
%define reg_stack 0
reg
;mmap	0, 4096, 3, 0x22, 0, 0
exit

%include "regdump2.mac"
