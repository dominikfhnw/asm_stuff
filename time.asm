true : ;nasm -Lmesp -l nasm.list -I asmlib/ -f bin -o isvm $0 && ls -l isvm && chmod +x isvm && objdump -b binary -m i386 -D isvm  -z --adjust-vma=0x3d400000 --start-address=0x3d400019 && echo ./isvm; echo ret $?; exit
;; true.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o true true.asm && chmod +x true
;;	ln true false

%macro jmp 1
%warning haha %? %1
%? %1
%endmacro

%include "stdlib.mac"

BASE	0x3d0db000
ELF
;%defalias __set_num setfz
.time:
	;time
	int 0x80
	ELF_PHDR jump
	__print_init
jmp bitset
	nop
	nop
	;push 0
	;pop eax
	dbg_regdump
	;zero	ecx, edx, ebx
	__print_loop
	__print_finish
	dbg_regdump
	;zero ecx
	;;zero	eax
	dbg_regdump
	sleep 1
jmp START



;lea	edx, [dl+30]
;lea	dl, [dl+30]
%undefalias set
%include "regdump2.mac"
memset	esp, 0, 12
%define reg_keepflags 0
%define reg_stack 1
setfz	esp, 12
setfz	edi, 12
setfz	eax, 12
setfz	ebx, 12
times 12 nop
bitset:
setfz	eax, 0
setfz	eax, 1
setfz	eax, 2
setfz	eax, 4
setfz	eax, 8
setfz	eax, 16
setfz	eax, 32
setfz	eax, 64
setfz	eax, 128
setfz	eax, 256
setfz	eax, 512
setfz	eax, 1024
setfz	eax, 2048
setfz	eax, 4096
setfz	eax, 8192
setfz	eax, 16384
setfz	eax, 32768
setfz	eax, 65536
setfz	eax, 131072
setfz	eax, 262144
setfz	eax, 524288
setfz	eax, 1048576
zero	eax
bts	eax, 16
dbg_regdump
zero	eax
inc	eax
shl	eax, 16
dbg_regdump
zero	eax
dec	eax
sal	eax, 12
dbg_regdump
zero	eax
inc	eax
ror	eax, 1
dbg_regdump
zero	eax
inc	eax
ror	eax, 2
dbg_regdump
zero	eax
inc	eax
bswap	eax
dbg_regdump
zero	eax
inc	eax
not	eax
dbg_regdump
zero	eax
dec	eax
mov	ah, 0
inc	eax
dbg_regdump

printstr "GOOOG"
doloop 255
zero	eax
mov	ah, cl
neg	eax
dbg_regdump
endloop

%macro pow 1
%assign res %1 & -%1
%if res == %1
%warning miau res
%else
%warning not a pow2
%endif
%endmacro

set eax, 128
