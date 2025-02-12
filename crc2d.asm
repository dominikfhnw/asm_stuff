true : ;nasm -Lmes -I asmlib/ -l nasm.list -f bin -o crc $0 && ls -l crc && chmod +x crc && objdump -Mintel  --no-addresses -b binary -m i386 -D crc --adjust-vma=0x3d4e5000 --start-address=0x3d4e5019 && echo && echo "foo" | ./crc; echo ret $?; exit
;true : ;nasm -Lmes -I asmlib/ -l nasm.list -f bin -o crc $0 && ls -l crc && chmod +x crc && objdump -Mintel -b binary -m i386 -D crc --adjust-vma=0x3d4e5000 --start-address=0x3d4e5019 && echo && echo "foo" | ./crc; echo ret $?; exit

; 40 inc eax
; 50 push eax (aka push 0)
; 60 pusha
; 90 nop
; b0 mov al, imm8

%define CRC32C 0
%define REG_OPT 1
%define FILE 1
%include "stdlib.mac"

BASE	0x3d4e9000
ELF flobb
rinit
taint	esi
;sleep 120
;rwx
%if FILE
	pop	ebx
	dec	ebx
	jz	.stdin
	pop	ebx
	open	pop, 0
	rdump
	xchg	eax, ebx
	%assign reg_eax_val reg_ebx_val
	%assign reg_ebx_val -2
	rdump
	.stdin:
%endif
; Comment out to stomp over args and env
;sub	esp, 9
mov	edi, esp
mov	ecx, esp
;rwx
;reg
;sleep 120
;exit
taint	ecx, edi
set	edx, 1
rdump

doread:
taint	eax
read	ebx, ecx, 1	; write one byte to the end of the stack
		; we can read it back by popping a dword from the stack

ELF_PHDR 1

dec	eax
js	eof

pop	eax
%if CRC32C
	crc32	esi, al
%else
	lea	esi, [9*esi]
	add	esi, eax
	ror	esi, 12
%endif
;reg		
rdump
push	ebp	; push another null on top of stack
jmp	doread

eof:
rdump
tohex	esi, ebx
rdump
stos	`\n`

puts	x, 9
rdump
;reg
xchg	eax, ebx
sub	ebx, edx
int	0x80
;exit

;zero	ecx
;%assign reg_stack 0
;set	eax, -103
;zero	eax,edx
%define REG_OPT 1
; code imports
;times 8 db 0
%include "regdump2.mac"

printstatic_func:
import_printstatic
