true : ;nasm -I asmlib/ -f bin -o isvm $0 && ls -l isvm && chmod +x isvm && objdump -b binary -m i386 -D isvm  -z --adjust-vma=0x3d400000 --start-address=0x3d400019 && ./isvm; echo ret $?; exit
;; true.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o true true.asm && chmod +x true
;;	ln true false

%define FOO 3
%include "stdlib.mac"
ELF
BASE 0x3d504000

		cpuid
	%if FOO == 3
		dec	ecx
		sets	cl
		foo:
		pop	eax
	%elif FOO == 2
		dec	ecx
		js foo
		inc ebx
		foo:
		pop	eax
	%elif FOO == 1
		rol	ecx, 1
		salc
		pop	ebx
		xchg 	eax, ebx
	%else
		rol	ecx, 1
		adc     bl, 0
		pop	eax
	%endif

		int	0x80
		;cmc
		;salc
		;inc	eax
		;xchg	eax,ebx
ELF_PHDR

%if 0
.hardening:
cmp	ax, 0x1000
jb	.hardening
sub	ax, 0x1000
or	al, 0x0
jmp	.hardening
%endif

%if 0
cmovs ebx, eax
sets bl
js bar
inc ebx
bar:
%endif
