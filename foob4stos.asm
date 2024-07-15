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

mov	edi, esp
add	esp, -12
;set	eax, 1234567898
;set	ebx, 1234
set	ebx, 0x1337BEEF
;setfz	edx, (`\n` - '0') % 255
setfz	edx, 9
;setfz	eax, 10
std

setfz	eax, 10
stosb
;mov	[ecx], byte 10
;add	[ecx], byte 10
;xchg	[ecx], byte 10
;setfz	ebx, 10
;set	eax, 0x10

dbg_regdump
.loop:
	;mov	[ecx], al

	mov     eax, ebx
	and     al, 0x0f        ; isolate low nibble
	cmp     al, 10          ; set CF according to digit>9
	sbb     al, 0x69        ; read CF, set CF and conditionally set AF, and wrap AL to > 99h
	das                     ; magic, which happens to work
	;dbg_regdump
	;dec	ecx
	;mov	[ecx], al
	stosb
	shr	ebx, 4
	dbg_regdump
	;test	ebx,ebx

jnz .loop
;mov	al, `\n`
;stosb
;dbg_regdump
mov	al, SYS_write

;set	edx, 9
add	bl, 1
mov	ecx, edi
inc	ecx
int	0x80
xchg	eax, ebx
zero	ebx

int	0x80

%include "regdump2.mac"
