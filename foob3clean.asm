true : ;nasm -Lmes -l nasm.list -Iasmlib/ -f bin -o print $0 && ls -l print && chmod +x print && objdas print && echo strace -i ./print foobar; echo ret $?; exit
;true : ;nasm -Iasmlib/ -f bin -o print $0 && ls -l print && chmod +x print && objdump -Mintel -b binary -m i386 -D print --adjust-vma=0x3d400000 --start-address=0x3d400019 && echo strace -i ./print foobar; echo ret $?; exit

; debug build:
; nasm -I asmlib/ -f elf32 foob.asm
; ld -m elf_i386 -z noseparate-code foob.o
; sstrip to get it to +50 bytes of original

;; true.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o true true.asm && chmod +x true
;;	ln true false

%define START _st2
%include "stdlib.mac"

BASE	0x054a9000
ELF
ELF_PHDR full
_st2:

set	eax, 123

mov	ecx, esp
add	esp, -12
setfz	edx, (`\n` - '0') % 255
setfz	ebx, 10
dbg_regdump

.loop:
	add	dl, '0'
	dec	ecx
	dbg_regdump

	%define ZEROED 1
	%if ZEROED
		xchg	[ecx], dl
	%else
		mov	[ecx], dl
		cdq
	%endif
	
	inc	esi
	test	eax,eax
	div	ebx
jnz .loop

mov	al, SYS_write
xchg	edx, esi
mov	bl, 1
int	0x80
xchg	eax, ebx
sub	ebx, edx

int	0x80
%include "regdump2.mac"
;printstatic_func:
import_printstatic
