true : ;nasm -I asmlib/ -f bin -o isvm $0 "$@" && ls -l isvm && chmod +x isvm && objdump -b binary -m i386 -D isvm  -z --adjust-vma=0x3d504000 --start-address=0x3d504019 && ./isvm; echo ret $?; exit
;; true.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o true true.asm && chmod +x true
;;	ln true false

%ifndef FOO
%define FOO 1
%endif

%define ISNOTVM 1

%include "elf.mac"
ELF
BASE 0x3d504000

		cpuid
	%if FOO == 3		; 1 free byte
		dec	ecx
		%if ISNOTVM
			sets	bl
		%else 
			setns	bl
		%endif
		pop	eax
	%elif FOO == 2		; 1 free byte
		dec	ecx
		%if ISNOTVM
			jns foo
		%else
			js foo
		%endif
		inc ebx
		foo:
		pop	eax
	%elif FOO == 1		; isnotvm: 1 free byte
		rol	ecx, 1	; isvm: no free bytes
		%if ISNOTVM
		%else
			cmc
		%endif
		salc
		pop	ebx
		xchg 	eax, ebx
	%else			; no free bytes
		rol	ecx, 1
		;cmc
		%if ISNOTVM
			adc	bl, 0
		%else
			adc	bl, -1
		%endif
		pop	eax
	%endif

		int	0x80
		;cmc
		;salc
		;inc	eax
		;xchg	eax,ebx
ELF_PHDR

%if 0
db	0

cmp	ecx, 0
test	ecx, 0
test	ecx, ecx
%endif
