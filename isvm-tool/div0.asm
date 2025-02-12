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

%define REG_OPT 1
%define ISNOTVM 1

%include "stdlib.mac"
ELF
BASE 0x3d409000

;xor	eax,eax

;clc
;salc
;idiv	al
;div	al
;exit	42

ELF_PHDR 1
times 8	nop

rinit 
shl	eax, 2
lea	eax, [5*eax]

times 8	nop

setfz	eax, 20
imul	ebx
imul	eax, ebx, 20
idiv	ecx
