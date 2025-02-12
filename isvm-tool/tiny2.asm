  ; tiny.asm
  
  BITS 32
  
                org     0x08048000
  
  ehdr:
                db      0x7F, "ELF", 1, 1, 1    ; e_ident
        times 9 db      0
                dw      2                       ; e_type
                dw      3                       ; e_machine
                dd      1                       ; e_version
                dd      _start                  ; e_entry
                dd      phdr - $$               ; e_phoff
                dd      0                       ; e_shoff
                dd      0                       ; e_flags
                dw      ehdrsz                  ; e_ehsize
                dw      phdrsz                  ; e_phentsize
  phdr:         dd      1                       ; e_phnum       ; p_type
                                                ; e_shentsize
                dd      0                       ; e_shnum       ; p_offset
                                                ; e_shstrndx
  ehdrsz        equ     $ - ehdr
                dd      $$                                      ; p_vaddr
  _start:       xor     eax, eax                                ; p_paddr
                jmp     short part2
                dd      filesz                                  ; p_filesz
                dd      filesz                                  ; p_memsz
                dd      5                                       ; p_flags
                dd      0x1000                                  ; p_align
  phdrsz        equ     $ - phdr
  
  part2:        inc     eax
                mov     bl, 42
                int     0x80
  
  filesz        equ     $ - $$
