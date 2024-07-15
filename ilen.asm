true : ;nasm -Iasmlib/ -f bin -o print $0 && ls -l print && chmod +x print && objdas ./print && echo strace -i ./print foobar; echo ret $?; exit
;; true.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o true true.asm && chmod +x true
;;	ln true false

;START equ _start - 3
%define START fff
%include "stdlib.mac"

;BASE	0x3d499000
BASE	0x10000000

ELF ff
ELF_PHDR jump
jmp fff
%include "regdump2.mac"

%if 1
push	1
mov	esi, edi
lea	esi, [edi]
imul	esi, edi, 1
push	2
lea	esi, [2*edi]
imul	esi, edi, 2
push	3
lea	esi, [3*edi]
imul	esi, edi, 3
push	4
ud2
imul	esi, edi, 4
push	5
lea	esi, [5*edi]
imul	esi, edi, 5
push	6
;lea	esi, [6*edi]
ud2
imul	esi, edi, 6
push	7
;lea	esi, [7*edi]
ud2
imul	esi, edi, 7
push	8
ud2
imul	esi, edi, 8
push	9
lea	esi, [9*edi]
imul	esi, edi, 9

times 12 nop

lea	esi, [edi+1]
lea	esi, [2*edi+1]
lea	esi, [3*edi+1]
ud2
lea	esi, [5*edi+1]
ud2
ud2
ud2
lea	esi, [9*edi+1]

times 12 nop

lea	esi, [eax+edi+1]
lea	esi, [eax+2*edi+1]
ud2
lea	esi, [eax+4*edi+1]
ud2
ud2
ud2
lea	esi, [eax+8*edi+1]
ud2

times 12 nop

lea	esi, [esp+1]
ud2
ud2
ud2
ud2
ud2
ud2
ud2
ud2

times 12 nop

lea	esi, [eax+esp+1]
ud2
ud2
ud2
ud2
ud2
ud2
ud2
ud2

; nasm -I asmlib/ -f elf32 foob.asm
; ld -m elf_i386 -z noseparate-code foob.o


shr	esi, 3
set	eax, 0
setfz	eax, 255
setfz	eax, 256
setfz	eax, 257
setfz	eax, 258
; lea m*x + c
; m = 1,2,3,5,9
; lea m*x + c + z (z being a register containing zero)
; m = 4,8
; mov m*x + 0
; m = 1
; imul m*x + 0
; m = 2,3,...
rwx

zero	eax
inc	eax
ror	eax, 1
dec	eax
dbg_regdump

zero	eax
inc	eax
ror	eax, 1
inc	eax
dbg_regdump

zero	eax
stc
rcr	eax, 1
dbg_regdump

zero	eax
inc	eax
ror	eax,1
sar	eax, 12
dbg_regdump

%endif

%imacro int32 1

%assign uint32 (+%1 % 0xFFFFFFFF)
%if %1 > 0x7FFFFFFF
	%assign sint32 -(-%1 % 0xFFFFFFFF)
%else
	%assign sint32 %1
%endif

%warning %1 signed: sint32
%warning %1 unsigned: uint32

%endmacro
%defalias usint32 int32

fff:
%if 0
	inc ebx

	zero	eax
	;inc	eax
	;dec	eax
	;dec	eax
	;mov	al,0x51
	mov	ah, bl
	bswap	eax
	;mov	al, 2

	;inc	al
	;dec	eax
	pusha
	mov	eax, ebx
	zero	ebx, edx, ecx
	printnum ':'
	popa
	reg
	crc32	eax, eax
	crc32	eax, eax
	crc32	eax, eax
	crc32	eax, eax
	crc32	eax, eax
	crc32	eax, eax
	crc32	eax, eax
	dbg_regdump
	;pusha
	;zero	ebx, edx, ecx
	;printnum
	;popa
	inc	ebx
	cmp	ebx, 255
	jbe fff
%endif

zero	eax
dec	eax
aas
; FFFFFE09 -503
int32 0xFFFFFE09
dbg_regdump

zero	eax
dec	eax
aaa
; FFFF0105 -65275
int32 0xFFFF0105
dbg_regdump

zero	eax
dec	eax
daa
; FFFFFF65 -155
int32 0xFFFFFF65
dbg_regdump

zero	eax
dec	eax
das
; FFFFFF99 -103
int32 0xFFFFFF99
dbg_regdump


zero	eax
lahf
dbg_regdump

std
zero	eax
dec	ah
sahf
dbg_regdump

pushf
pop	eax
dbg_regdump


zero	eax
inc	eax
xchg	al,ah
dbg_regdump

push	-103
push 0xFFFFFF99
set	eax, 1+2
exit
