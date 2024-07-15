true : ;out=$(basename $0 .asm);nasm -f bin -o $out $0 && ls -l $out && chmod +x $out && objdas $out && ./$out; echo ret $?; echo size: $(( $(wc -c<$out) - 55)); exit

;; true.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o true true.asm && chmod +x true
;;	ln true false
%define SYSCALL int 0x80

BITS 32
CPU 386
START equ _start
		org	0x68490000

		db	0x7F, "ELF"
		dd	1
		dd	0
		dd	$$			; vaddr
		dw	2
		dw	3
		dd	START -2		; garbage/filesz
		dd	START -2		; start/memsz
_start:
		dd	4
mov	ebx, $$
add	al, 125
pop	edx
dec	edx
;jmp	_start2
times $$-$+41	db	0x90
		db	169
		dw	0x20
		dw	1

_start2:
SYSCALL

; 58 byte no label
; 69 byte count label
; 83 byte 1byte label
; 94 byte full label

; count labels: 11 bytes
; 1byte labels: 25 bytes	+14 bytes
; full  labels: 36 bytes	+11 bytes

; each of those adds 4 byte of code and 1*REGS of stack used
;%define SPACE 1
%define NEWLINE 1
%define EXTENDED 0

%define LABEL 1
%define ALTLABEL 0

%if LABEL || ALTLABEL
%define SPACE 1
%else
%define SPACE 0
%endif

%if LABEL && ALTLABEL
%error cant have LABEL and ALTLABEL together
%endif

%define REGS 9
%define RECORD (8 + LABEL + ALTLABEL + SPACE + NEWLINE + EXTENDED)
; eax ecx edx ebx esp ebp esi edi eflags
;  AX  CX  DX  BX  SP  BP  SI  DI  FL
;  A   C   D   B   S   P   s   d   f
;hlt

regdump:
pusha
pushf			; save processor state on stack

%if LABEL
call	.begin
.labels:
	%if LABEL == 2
	db "FLDISIBPSPBXDXCXAX"
	%else
	db "fdsPSBDCA"
	%endif
.begin:
pop	esi
mov	edx, esp
%else
mov	esi, esp
%endif

%if ALTLABEL
push	'Z'
pop	edx
%endif

add	esp, -RECORD*REGS
mov	edi, esp	; alloca

push	REGS
pop	ecx

.loop2:
%if EXTENDED
push	'E'
pop	eax
stosb			; whitespace
%endif

%if LABEL == 2
lodsw			; load description text
stosw			; store it
%elif LABEL == 1
lodsb			; load description text
stosb			; store it
%endif

%if ALTLABEL
mov	eax, edx
stosb
dec	edx
%endif

%if SPACE
push	0x20
pop	eax
stosb			; whitespace
%endif

%if LABEL
xchg	edx, esi	; switch back to the pusha registers on the stack
%endif

push	ecx

	;; clobbers: eax, ebx, ecx
	push	8            ; 8 hex digits
	pop	ecx

	lodsd
	mov	ebx, eax
	.loop:		    ;do{
	rol	ebx, 4       ; rotate high nibble to the bottom

	mov	eax, ebx
	and	al, 0x0f     ; isolate low nibble
	cmp	al, 10          ; set CF according to digit>9
	sbb	al, 0x69        ; read CF, set CF and conditionally set AF, and wrap AL to > 99h
	das                 ; magic, which happens to work

	stosb               ; *edi++ = al
	loop	.loop       ; }while(--ecx)

pop	ecx

%if LABEL
xchg	edx, esi	; back again to description text
%endif

%if NEWLINE
push	0x0a
pop	eax
stosb
%endif

loop	.loop2
;hlt

push	4
pop	eax
push	1
pop	ebx
mov	ecx, esp     ; buf
push	RECORD*REGS
pop	edx
int	0x80
add	esp, edx
popf
popa
;hlt

exit:
xor	eax,eax
xor	ebx,ebx
inc	eax
;xchg	eax,ebx       ; _NR_exit
int	0x80

