true : ;nasm -Ox -I asmlib/ -l nasm.list -f bin -o crc $0 && ls -l crc && chmod +x crc && objdump -Mintel -b binary -m i386 -D crc --adjust-vma=0x3d4e5000 --start-address=0x3d4e5019 && echo && echo "foo" | ./crc; echo ret $?; exit
;; true.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o true true.asm && chmod +x true
;;	ln true false

; 40 inc eax
; 50 push eax (aka push 0)
; 60 pusha
; 90 nop
; b0 mov al, imm8

%include "stdlib.mac"
%define CRC32C 0

org	0x3d4e5000

ELF
;%define reg_fromzero 1
;sc_param2	esp
;sc_param3	1
;sc_nr		SYS_read

ELF_PHDR 1

;sc_exec
reg
doread:
read STDIN, esp, 1

%if 0
set eax, 2
add al, 127
stc
call regdump
printstatic "foo"
call regdump
exit 11
%endif

;%define reg_fromzero 0
;dbg_regdump "before test"
test	eax,eax
;ddprint "after test"
;dbg_regdump
;push	0
jz	eof

pop	eax
%if CRC32C
	crc32	esi, al
%else
	lea	esi, [9*esi]
	add	esi, eax
	ror	esi, 12
%endif
		
reg
push	0
jmp	doread

eof:
reg
;dbg_regdump
sub	esp, 9
mov	edi, esp
tohex	esi
push	0x0a
pop	eax
stosb

;dbg_regdump
;push	4
;pop	eax
sub	al, 6
;xor	ebx,ebx
inc	ebx
push	9
pop	edx
mov	ecx, esp
int	0x80
;call	[gs:0x10]
;call	[dword gs:0x10]
;dbg_regdump
xchg	eax, ebx
zero	ebx
;dbg_regdump
int	0x80


; code imports
%include "regdump2.mac"

times 8 db 0
printstatic_func:
import_printstatic
