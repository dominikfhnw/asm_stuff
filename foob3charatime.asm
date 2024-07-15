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

%ifenv %!DEBUG
%defstr DEBUG %!DEBUG
%endif

%define START _st2
%include "stdlib.mac"
%include "regdump.mac"

BASE	0x054a9000
ELF
ELF_PHDR full
_st2:

;mov	esi, esp
push	eax
mov	ecx, esp
;dec	ch
;add	esp, -12
;set	eax, 1234567898
set	eax, 123
;zero	edx
;mov	dl, `\n` - '0'
;setfz	edx, (`\n` - '0') % 255
;setfz	edx, 218

;setfz	ebx, 10
push	10
pop	edi
inc	ebx
;push	10
;pop	ebp

;setfz	ebx, 11
dbg_regdump
.loop:
;doloop 10
	div	edi

	or	dl, '0'
	mov	[ecx], dl

	dbg_regdump
	xchg	eax,esi
	mov	al, 4
	mov	dl, 1
	int	0x80
	xchg	eax,esi
	cdq
	
	;dbg_regdump
	;cmp	0, eax
	test	eax,eax
	;dbg_regdump
	;dec ebx
	;dbg_regdump
;endloop
jnz .loop
dbg_regdump
mov	[ecx], byte 10
mov	al, 4
inc	edx
int	0x80

rwx
exit

xchg	eax, ebx
int	0x80


%include "regdump2.mac"
