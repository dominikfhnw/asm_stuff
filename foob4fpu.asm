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

%define DEBUG 0
%define START _st2
%include "stdlib.mac"
%include "regdump.mac"

BASE	0x054a9000
ELF
ELF_PHDR full
_st2:

mov	ecx, esp
add	esp, -12
push 1234567898
fild	dword [esp]
fbstp	[esp]
pop	ebx
;push 123
;set	ebx, 0xBEEF1337
;setfz	edx, (`\n` - '0') % 255
;setfz	edx, 9
;setfz	eax, 10

;add	[ecx], byte 10
;xchg	[ecx], byte 10
;setfz	ebx, 10
;set	eax, 0x10
;setfz	edx, 10
mov	[ecx], byte 10
;push	8
;pop	esi
%define FIXED 0

dbg_regdump
.loop:
	mov     eax, ebx
	and     al, 0x0f        ; isolate low nibble
	or	al, '0'
	;dbg_regdump
	dec	ecx
	xchg	[ecx], al
	inc	edx
	shr	ebx, 4
	%if FIXED
	cmp	edx,8
	%endif
	dbg_regdump
jnz .loop
dbg_regdump

mov	al, SYS_write
inc	ebx
inc	edx
int	0x80

xchg	eax, ebx
zero	ebx
int	0x80

%include "regdump2.mac"
