BITS 32

%define ET_EXEC		 2
%define EM_386		 3
%define EV_CURRENT	 1

%define PT_LOAD		 1
%define PT_DYNAMIC	 2
%define PT_INTERP	 3

%define PF_X		 1
%define PF_W		 2
%define PF_R		 4

org	0x10000

ehdr:							; Elf32_Ehdr
		db	0x7F, "ELF"			;   e_ident
	buffer1: 
	times 12-$+buffer1 db	0

		dw	ET_EXEC				;   e_type
		dw	EM_386				;   e_machine
		dd	0				;   e_version
		dd	_start				;   e_entry
		dd	phdr - $$			;   e_phoff
		dd	0				;   e_shoff
		dd	0				;   e_flags
		dw	ehdrsize			;   e_ehsize
		dw	phdrsize			;   e_phentsize
		dw	1				;   e_phnum
		dw	0				;   e_shentsize
		dw	0				;   e_shnum
		dw	0				;   e_shstrndx
ehdrsize equ $ - ehdr


phdr:							; Elf32_Phdr
dd	PT_LOAD				;   p_type
dd	0				;   p_offset
dd	0x10000				;   p_vaddr
dd	0				;   p_paddr
dd	filesize			;   p_filesz
dd	memsize				;   p_memsz
dd	PF_R | PF_W | PF_X		;   p_flags
dd	0x1000				;   p_align
phdrsize equ $ - phdr

_start:

cpuid  
push   ecx
push   edx
push   ebx
mov    ecx,esp
push   4
pop    eax
push   12
pop    edx
push   1
pop    ebx
int    0x80
mov    eax,ebx
xor    ebx,ebx
int    0x80


exit_ptr equ $ + 11
_end equ $ + 15

;; End of the file image.

filesize equ $ - $$
memsize equ _end - $$
