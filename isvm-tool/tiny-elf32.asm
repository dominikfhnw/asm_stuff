;; tiny.asm: Copyright (C) 2001 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o tiny tiny.asm && chmod +x tiny

BITS 32
  
		org	0x2AB30000
ehdr:
		db	0x7F, "ELF", 1, 1, 1, 0	; e_ident
	times 8 db	0
		dw	2			; e_type
		dw	3			; e_machine
		dd	1			; e_version
		dd	_start			; e_entry
		dd	phdr - $$		; e_phoff
		dd	0			; e_shoff
		dd	0			; e_flags
		dw	ehdrsz			; e_ehsize
		dw	phdrsz			; e_phentsize
phdr:		dd	1			; e_phnum	; p_type
						; e_shentsize
		dd	0			; e_shnum	; p_offset
ehdrsz		equ	$ - ehdr		; e_shstrndx
		dw	0					; p_vaddr
_start:		mov	bl, 42		; set ebx to exit code
		xor	eax, eax	; set eax to 1		; p_paddr
		inc	eax		; 1 = exit syscall
		cmp	eax, strict dword filesz		; p_filesz
		int	0x80		; exit(bl)		; p_memsz
		dw	0
		dd	7					; p_flags
		dd	0x1000					; p_align
phdrsz		equ	$ - phdr
  
filesz		equ	$ - $$
