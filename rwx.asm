true : ;nasm -Lmesp -l nasm.list -I asmlib/ -f bin -o isvm $0 && ls -l isvm && chmod +x isvm && objdump -b binary -m i386 -D isvm  -z --adjust-vma=0x3d400000 --start-address=0x3d400019 && ./isvm; echo ret $?; exit
;; true.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o true true.asm && chmod +x true
;;	ln true false
%include "stdlib.mac"
%define HACKY_RWX 0

BASE	0x3d7db000
ELF
;pusha
set	ebx, $$
%if HACKY_RWX
	mov	dl,7
	dec	ecx
	ELF_PHDR jump
%else
	lea	ecx, [ebx+START-$$]
	ELF_PHDR jump
	mov	dl,7
%endif
dbg_regdump
int	0x80
;rwx
;popa
;mov	al,0
;zero	eax
;dbg_regdump
;rwx
;sleep 1
;rdrand	eax
time
printnumexit
;rorx	edx, eax, 4
;time
;dbg_regdump
;pause
%include "regdump2.mac"
;time
