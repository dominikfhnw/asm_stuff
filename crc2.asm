true : ;nasm -Lmes -I asmlib/ -l nasm.list -f bin -o crc $0 && ls -l crc && chmod +x crc && objdump -Mintel  --no-addresses -b binary -m i386 -D crc --adjust-vma=0x3d4e5000 --start-address=0x3d4e5019 && echo && echo "foo" | ./crc; echo ret $?; exit
;true : ;nasm -Lmes -I asmlib/ -l nasm.list -f bin -o crc $0 && ls -l crc && chmod +x crc && objdump -Mintel -b binary -m i386 -D crc --adjust-vma=0x3d4e5000 --start-address=0x3d4e5019 && echo && echo "foo" | ./crc; echo ret $?; exit

; 40 inc eax
; 50 push eax (aka push 0)
; 60 pusha
; 90 nop
; b0 mov al, imm8

%define CRC32C 0
%define REG_OPT 1
%include "stdlib.mac"
bits 64

BASE	0x3d4e5000
ELF
rinit
taint	esi
;sleep 120
;rwx
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

doread:
read	STDIN, x, 1

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
push	ebx
jmp	doread

eof:
;reg
;dbg_regdump
rdump
%if 1
tohex	esi, ebx
%else
push	ecx
tohex	esi
pop	ecx
%endif
;reg
rdump
stos	`\n`

;dbg_regdump
puts	x, 9
rdump
;reg
exit

%define REG_OPT 1
; code imports
;times 8 db 0
%include "regdump2.mac"

printstatic_func:
import_printstatic
