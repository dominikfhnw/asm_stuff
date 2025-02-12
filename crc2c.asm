true : ;nasm -Lmes -I asmlib/ -l nasm.list -f bin -o crc $0 && ls -l crc && chmod +x crc && objdump -Mintel  --no-addresses -b binary -m i386 -D crc --adjust-vma=0x3d4e5000 --start-address=0x3d4e5019 && echo && echo "foo" | ./crc; echo ret $?; exit

; 40 inc eax
; 50 push eax (aka push 0)
; 60 pusha
; 90 nop
; b0 mov al, imm8

%define CRC32C 0
%define REG_OPT 1
%include "stdlib.mac"

BASE	0x3d4e5000
ELF
ELF_PHDR 1
rinit
reg
doread:
taint	edx
read	STDIN, esp, 1

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
reg		
push	0
rdump
jmp	doread

eof:
reg
;dbg_regdump
sub	esp, 9
mov	edi, esp
rdump
tohex	esi
rdump
stos	`\n`

;dbg_regdump
puts	esp, 9
rdump
reg
exit

%define REG_OPT 0
; code imports
;times 8 db 0
%include "regdump2.mac"

printstatic_func:
import_printstatic
