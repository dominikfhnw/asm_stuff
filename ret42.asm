true : ;nasm -Ov -Lmesp -l nasm.list -I asmlib/ -f bin -o isvm $0 && ls -l isvm && chmod +x isvm && objdump -b binary -m i386 -D isvm  -z --adjust-vma=0x3d400000 --start-address=0x3d400019 && ./isvm; echo ret $?; exit
;; true.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o true true.asm && chmod +x true
;;	ln true false
%include "stdlib.mac"

ELF
%if 1
	BASE	0x3d904000
	setfz	ebx, 42
	int	0x80
	db "EXIT42"
%else
	BASE	0x3d909000
	set	ecx, $$
	;exit	42
%endif

ELF_PHDR
