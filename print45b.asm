true : ;nasm -Iasmlib/ -f bin -o print $0 && ls -l print && chmod +x print && objdump -b binary -m i386 -D print  -z --adjust-vma=0x3d400000 --start-address=0x3d400019 && echo strace -i ./print foobar; echo ret $?; exit
;; true.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o true true.asm && chmod +x true
;;	ln true false

%include "stdlib.mac"
BASE  0x05439000
ELF

pop	ecx
pop	ecx
dec	edx
int	0x80
xchg	eax, ebx
int	0x80
ELF_PHDR
