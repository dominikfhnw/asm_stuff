true : ;nasm -I asmlib/ -l nasm.list -f bin -o print $0 && ls -l print && chmod +x print && objdump -b binary -m i386 -D print --adjust-vma=0x3d400000 --start-address=0x3d400019 && echo strace -i ./print foobar; echo ret $?; exit
;; true.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o true true.asm && chmod +x true
;;	ln true false

%define DEBUG 1
%define OPT 1
%define PROPER 1

%include "generic.mac"
%include "regdump.mac"
%include "elf.mac"
%include "syscall.mac"

BITS 32
START equ _start - 3
;START equ s2

		org	0x684a9000
		ELF
ff:		
		mov	edi, 8[esp]
		setfz	ecx, 4096
		push	edi			; edi, ecx, eax
						; free: ebx, edx, esi, ebp
		;setfz	edx, -1

	loopy:
	repne	scasb
		ELF_PHDR 1


		
		push	10
		fild	dword [esp]
		fldpi
		doloop 8
			fld st1
			fmul
		endloop
		fist	dword [esp]
		pop	eax
		dbg_regdump
		exit 0

		xor	eax, eax
		dbg_regdump
		add	eax, strict byte -128
		dbg_regdump
		xor	eax, eax
		dec	eax
		mov	al, 0
		dbg_regdump
		xor	eax, eax
		dec	ax
		dbg_regdump
		xor	eax, eax
		add	al, 255
		dbg_regdump
		xor	eax, eax
		mov	al, 255
		dbg_regdump
		xor	eax, eax
		mov	ah, 255
		dbg_regdump
		xor	eax, eax
		mov	al, 255
		dbg_regdump
		xor	eax, eax
		mov	ah, 255
		bswap	eax
		dbg_regdump
		xor	eax, eax
		inc	eax
		bswap	eax
		;sub	eax, strict byte 127
		dbg_regdump
		exit 0

		doloop 260

			sub al, 1
			dbg_regdump
		endloop
		exit

		;dprint "henlo"
		dbg_regdump
		exit 42
		

		;dbg_regdump
		mov	byte -1[edi], byte 0xa
		dec	ecx
		dbg_regdump
		jns	loopy

		dbg_regdump
		%if OPT
		;setfz	eax, SYS_write
		%if PROPER
		inc	ebx
		%endif
		pop	ecx
		pop	eax
	;.swpsys:
		int	0x80
		%else
		puts pop, x
		%endif

		dbg_regdump

		%if PROPER
		%if OPT
		;jmp .swpsys
		xchg	eax, ebx
		int	0x80
		%else
		exit
		%endif
		%endif
		

%include "regdump2.mac"

add cl,al
db 0x02, 0xc8
db 0x00, 0xc1
		%if 0
		add	al, 0x1
		mov	al, 0x1
		mov	ah, 0x1
		mov	ax, 0x1
		add	cl, 0x1
		mov	cl, 0x1
		mov	ch, 0x1
		sar	eax, 1
		sar	al, 1
		sar	eax, 1
		shr	eax, 12
		shr	eax, 12
		sal	eax, 1
		sal	eax, 12
		sar	eax, 1
		sar	eax, 12
		rol	eax, 12
		rol	eax, 1
		ror	eax, 12
		ror	eax, 1

		shr	ecx, 12
		shr	ecx, 12
		sal	ecx, 12
		sal	ecx, 12
		rol	ecx, 12
		ror	ecx, 12

		bts	ecx, 12
		bts	ecx, eax

		mov	eax, 0x1000
		mov	ecx, 0x1000
		set	ecx, 140
		set	ecx, 0x1000
		times 8	nop
		set	ecx, 0x100
		set	ecx, 0xff00
		set	ecx, 0x1001
		set	ecx, 127
		set	ecx, 128
		set	eax, 128
		zero	eax
		sub	al, -1
		add	al, -1
		lahf
		cpuid
		set	eax, 0xFFFF
		set	ebx, DEBUG
		mov	ax, 0xFFFF
		mov	bx, 0xFFFF

		;sub	esi, 8192
		dec	esi
		;inc	esi
		shl	esi, 13
		set	ebp, 0xffffe000
	%endif
