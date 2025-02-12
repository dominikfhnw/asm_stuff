  BITS 32
  
                org     0x08048000
  
  ehdr:                                                 ; Elf32_Ehdr
                db      0x7F, "ELF", 1, 1, 1            ;   e_ident
        times 9 db      0
                dw      2                               ;   e_type
                dw      3                               ;   e_machine
                dd      1                               ;   e_version
                dd      _start                          ;   e_entry
                dd      phdr - $$                       ;   e_phoff
                dd      0                               ;   e_shoff
                dd      0                               ;   e_flags
                dw      ehdrsz                          ;   e_ehsize
                dw      phdrsz                          ;   e_phentsize
                dw      1                               ;   e_phnum
                dw      0                               ;   e_shentsize
                dw      0                               ;   e_shnum
                dw      0                               ;   e_shstrndx
  ehdrsz        equ     $ - ehdr
  
  phdr:                                                 ; Elf32_Phdr
                dd      1                               ;   p_type
                dd      0                               ;   p_offset
                dd      $$                              ;   p_vaddr
                dd      $$                              ;   p_paddr
                dd      filesz                          ;   p_filesz
                dd      filesz                          ;   p_memsz
                dd      5                               ;   p_flags
                dd      0x1000                          ;   p_align
  phdrsz        equ     $ - phdr
  
  _start:
                xor     eax, eax
                inc     eax
                mov     bl, 42
                int     0x80
  
  filesz        equ     $ - $$
