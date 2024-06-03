;; tiny.asm: Copyright (C) 2002 Brian Raiter <breadbox@muppetlabs.com>
;; Licensed under the terms of the GNU General Public License, either
;; version 2 or (at your option) any later version.
;;
;; To build:
;;	nasm -f bin -o tiny tiny.asm && chmod +x tiny

BITS 32

FILL equ 0x58

%define ET_EXEC		 2
%define EM_386		 3
%define EV_CURRENT	 1

%define PT_LOAD		 1
%define PT_DYNAMIC	 2
%define PT_INTERP	 3

%define PF_X		 1
%define PF_W		 2
%define PF_R		 4

%define STT_OBJECT	 1
%define STT_FUNC	 2

%define STB_GLOBAL	 1

%define R_386_32	 1

%define DT_NULL		 0
%define DT_NEEDED	 1
%define DT_HASH		 4
%define DT_STRTAB	 5
%define DT_SYMTAB	 6
%define DT_STRSZ	10
%define DT_SYMENT	11
%define DT_REL		17
%define DT_RELSZ	18
%define DT_RELENT	19

%define R_INFO(s, r)	(((s) << 8) | (r))

		org	0x10000

ehdr:							; Elf32_Ehdr
		db	0x7F, "ELF"			;   e_ident
;; The relocation table
	times 3 db	1
reltab:							; Elf32_Rel
		dd	exit_ptr			;   r_offset
		dd	R_INFO(exit_sym, R_386_32)	;   r_info
relentsize equ $ - reltab
reltabsize equ $ - reltab

	times 1 db	FILL
		dw	ET_EXEC				;   e_type
		dw	EM_386				;   e_machine
	times 4 db	FILL
		dd	_start				;   e_entry
		dd	phdr - $$			;   e_phoff
_start:		push	byte 42
		call	[exit_ptr]
	times 2 db	FILL
		dw	phdrsize			;   e_phentsize
		dw	3				;   e_phnum

;; The interpreter segment

interp:		db	'/lib/ld-linux.so.2', 0

interpsize equ $ - interp

;; The string table

strtab:
libc_name equ $ - strtab
		db	'libm.so', 0
exit_name equ $ - strtab
		db	'exit', 0
strtabsize equ $ - strtab


;; The program segment header table, hash table, symbol table, and
;; dynamic section.

phdr:							; Elf32_Phdr
		dd	PT_LOAD				;   p_type
		dd	0				;   p_offset
		dd	$$				;   p_vaddr
	times 4 db	FILL				;   p_paddr
		dd	filesize			;   p_filesz
		dd	memsize				;   p_memsz
		dd	PF_R | PF_W | PF_X		;   p_flags
		dd	FILL				;   p_align
phdrsize equ $ - phdr
		dd	PT_DYNAMIC			;   p_type
		dd	dyntab - $$			;   p_offset
		dd	dyntab				;   p_vaddr
	times 4 db	FILL				;   p_paddr
		dd	dyntabsize			;   p_filesz
		dd	dyntabsize			;   p_memsz
		dd	PF_R | PF_W			;   p_flags
		dd	FILL				;   p_align

		dd	PT_INTERP			;   p_type
symtab:
		dd	interp - $$			;   p_offset
		dd	interp				;   p_vaddr
	times 4 db	FILL				;   p_paddr
		dd	interpsize			;   p_filesz
							;   p_memsz
							;   p_flags
							;   p_align = 1

							; Elf32_Sym
exit_sym equ 1
		dd	exit_name			;   st_name
		dd	0				;   st_value
		dd	0				;   st_size
							;   st_info = 18
							;   st_other = 0
							;   st_shndx = 0

;; The dynamic section

dyntab:
		dd	DT_RELSZ,  reltabsize
		dd	DT_RELENT, relentsize
		dd	DT_REL,	   reltab
		dd	DT_STRTAB, strtab
		dd	DT_SYMTAB, symtab
		db	DT_NEEDED
dyntabsize equ $ - dyntab + 11

exit_ptr equ $ + 11
_end equ $ + 15

;; End of the file image.

filesize equ $ - $$
memsize equ _end - $$
%assign filesize filesize
%warning EOF is at filesize memsize
