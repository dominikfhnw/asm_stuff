#if 0
OUT=strip3
LOAD=/lib/ld-linux.so.2
o=$(basename "$0" .c)
gcc "$0" -o "$o"
out=cust
./"$o" > "$out"
make dostrip OUT="$out"
ls -l "$out"c "$OUT"c
cmp "$OUT"c "$out"c
exit
#endif
#include <stdio.h>
#include <stddef.h>
#include <elf.h>

#define ADDR_TEXT 0x00400000

enum sections
{
  SHN_TEXT = 1, SHN_RODATA, SHN_DYNSTR, SHN_DYNSYM, SHN_GNU_VERSION_R,
  SHN_REL_DYN, SHN_GOT_PLT, SHN_DYNAMIC, SHN_HASH, SHN_GNU_VERSION, SHN_GOT,
  SHN_SYMTAB, SHN_STRTAB, SHN_SHSTRTAB, SHN_COUNT
};

typedef struct elf
{
  Elf32_Ehdr      ehdr;
  Elf32_Phdr      phdrs[2];
  unsigned char   text[21];
  char            rodata[18];
  char            dynstr[28];
  unsigned char   pad[1];
  Elf32_Sym       dynsym[2];
  Elf32_Word      gnu_version_r[8];
  Elf32_Rel       rel_dyn[1];
  Elf32_Addr      got_plt[3];
  Elf32_Dyn       dynamic[19];
  Elf32_Word      hash[5];
  Elf32_Half      gnu_version[2];
  Elf32_Addr      got[1];
  Elf32_Sym       symtab[10];
  char            strtab[81];
  char            shstrtab[123];
  Elf32_Shdr      shdrs[SHN_COUNT];
  unsigned char   _end[0];
} elf;

elf foo =
{
  /* ehdr */
  {
    { 0x7F, 'E', 'L', 'F', ELFCLASS32, ELFDATA2LSB, EV_CURRENT, ELFOSABI_SYSV,
      0, 0, 0, 0, 0, 0, 0, 0 },
    ET_EXEC, EM_386, EV_CURRENT, ADDR_TEXT + offsetof(elf, text),
    offsetof(elf, phdrs), offsetof(elf, shdrs), 0, sizeof(Elf32_Ehdr),
    sizeof(Elf32_Phdr), sizeof foo.phdrs / sizeof *foo.phdrs,
    sizeof(Elf32_Shdr), sizeof foo.shdrs / sizeof *foo.shdrs, SHN_SHSTRTAB
  },
  /* phdrs */
  {
    { PT_LOAD, offsetof(elf, phdrs), ADDR_TEXT + offsetof(elf, phdrs),
      ADDR_TEXT + offsetof(elf, phdrs),
      offsetof(elf, symtab) - offsetof(elf, phdrs),
      offsetof(elf, symtab) - offsetof(elf, phdrs), PF_R | PF_W | PF_X,
      0x1000 },
    { PT_DYNAMIC, offsetof(elf, dynamic), ADDR_TEXT + offsetof(elf, dynamic),
      ADDR_TEXT + offsetof(elf, dynamic), sizeof foo.dynamic,
      sizeof foo.dynamic, PF_R | PF_W, sizeof(Elf32_Addr) }
  },
  /* text */
  {
    0x68, 0x89, 0x00, 0x40, 0x00, 0x6A, 0x00, 0xFF, 0x15, 0xBC, 0x01, 0x40,
    0x00, 0x68, 0x8E, 0x00, 0x40, 0x00, 0xFF, 0xD0, 0xCC
  },
  /* rodata */
  "puts\0Hello World!",
  /* dynstr */
  "\0dlsym\0libc.so.6",
  /* pad */
  { 0 },
  /* dynsym */
  {
    { 0, 0, 0, 0, 0, SHN_UNDEF },
    /* dlsym */
    { 1, 0, 0, ELF32_ST_INFO(STB_GLOBAL, STT_FUNC), STV_DEFAULT, SHN_UNDEF }
  },
  /* gnu_version_r */
  {
    0x00010001, 0x00000007, 0x00000010, 0x00000000, 0x069691B4, 0x00020000,
    0x00000011, 0x00000000
  },
  /* rel_dyn */
  {
    /* dlsym */
    { ADDR_TEXT + offsetof(elf, got), ELF32_R_INFO(1, R_386_GLOB_DAT) }
  },
  /* got_plt */
  {
    ADDR_TEXT + offsetof(elf, dynamic), 0, 0
  },
  /* dynamic */
  {
    { DT_NEEDED, { 7 } }, /* libc.so.6 */
    { DT_STRTAB, { ADDR_TEXT + offsetof(elf, dynstr) } },
    { DT_SYMTAB, { ADDR_TEXT + offsetof(elf, dynsym) } },
    { DT_STRSZ, { sizeof foo.dynstr } },
    { DT_REL, { ADDR_TEXT + offsetof(elf, rel_dyn) } },
    { DT_RELSZ, { sizeof foo.rel_dyn } },
    { DT_RELENT, { sizeof(Elf32_Rel) } },
    { DT_HASH, { ADDR_TEXT + offsetof(elf, hash) } },
    { DT_NULL, { 0 } },
    { DT_NULL, { 0 } },
    { DT_NULL, { 0 } },
    { DT_NULL, { 0 } },
    { DT_NULL, { 0 } },
    { DT_NULL, { 0 } }
  },
  /* hash */
  {
    1, 2,
    1,
    0, 0
  },
  /* gnu_version */
  {
    0, 2
  },
  /* got */
  {
    0
  },
  /* symtab */
  {
    { 0, 0, 0, 0, 0, SHN_UNDEF },
    /* hello.c */
    { 1, 0, 0, ELF32_ST_INFO(STB_LOCAL, STT_FILE), STV_DEFAULT, SHN_ABS },
    { 0, 0, 0, ELF32_ST_INFO(STB_LOCAL, STT_FILE), STV_DEFAULT, SHN_ABS },
    /* _DYNAMIC */
    { 9, ADDR_TEXT + offsetof(elf, dynamic), 0,
      ELF32_ST_INFO(STB_LOCAL, STT_OBJECT), STV_DEFAULT, SHN_DYNAMIC },
    /* _GLOBAL_OFFSET_TABLE_ */
    { 18, ADDR_TEXT + offsetof(elf, got_plt), 0,
      ELF32_ST_INFO(STB_LOCAL, STT_OBJECT), STV_DEFAULT, SHN_GOT_PLT },
    /* _edata */
    { 40, ADDR_TEXT + offsetof(elf, dynamic), 0,
      ELF32_ST_INFO(STB_GLOBAL, STT_NOTYPE), STV_DEFAULT, SHN_GOT_PLT },
    /* _end */
    { 47, ADDR_TEXT + offsetof(elf, dynamic), 0,
      ELF32_ST_INFO(STB_GLOBAL, STT_NOTYPE), STV_DEFAULT, SHN_GOT_PLT },
    /* _start */
    { 57, ADDR_TEXT + offsetof(elf, text), sizeof foo.text,
      ELF32_ST_INFO(STB_GLOBAL, STT_FUNC), STV_DEFAULT, SHN_TEXT },
    /* __bss_start */
    { 52, ADDR_TEXT + offsetof(elf, dynamic), 0,
      ELF32_ST_INFO(STB_GLOBAL, STT_NOTYPE), STV_DEFAULT, SHN_GOT_PLT },
    /* dlsym@GLIBC_2.34 */
    { 64, 0, 0, ELF32_ST_INFO(STB_GLOBAL, STT_FUNC), STV_DEFAULT, SHN_UNDEF }
  },
  /* strtab */
  "\0hello.c\0_DYNAMIC\0_GLOBAL_OFFSET_TABLE_\0_edata\0_end\0__bss_start\0dl"
    "sym@GLIBC_2.34",
  /* shstrtab */
  "\0.symtab\0.strtab\0.shstrtab\0.text\0.rodata\0.dynstr\0.dynsym\0.gnu.ver"
    "sion_r\0.rel.dyn\0.got.plt\0.dynamic\0.hash\0.gnu.version\0.got",
  /* shdrs */
  {
    { 0, SHT_NULL, 0, 0, 0, 0, SHN_UNDEF, 0, 0, 0 },
    /* .text */
    { 27, SHT_PROGBITS, SHF_EXECINSTR | SHF_ALLOC,
      ADDR_TEXT + offsetof(elf, text), offsetof(elf, text), sizeof foo.text,
      SHN_UNDEF, 0, 1, 0 },
    /* .rodata */
    { 33, SHT_PROGBITS, SHF_STRINGS | SHF_ALLOC | SHF_MERGE,
      ADDR_TEXT + offsetof(elf, rodata), offsetof(elf, rodata),
      sizeof foo.rodata, SHN_UNDEF, 0, 1, 1 },
    /* .dynstr */
    { 41, SHT_STRTAB, SHF_ALLOC, ADDR_TEXT + offsetof(elf, dynstr),
      offsetof(elf, dynstr), sizeof foo.dynstr, SHN_UNDEF, 0, 1, 0 },
    /* .dynsym */
    { 49, SHT_DYNSYM, SHF_ALLOC, ADDR_TEXT + offsetof(elf, dynsym),
      offsetof(elf, dynsym), sizeof foo.dynsym, SHN_DYNSTR, 1,
      sizeof(Elf32_Addr), sizeof(Elf32_Sym) },
    /* .gnu.version_r */
    { 57, SHT_GNU_verneed, SHF_ALLOC,
      ADDR_TEXT + offsetof(elf, gnu_version_r), offsetof(elf, gnu_version_r),
      sizeof foo.gnu_version_r, SHN_DYNSTR, 1, sizeof(Elf32_Word), 0 },
    /* .rel.dyn */
    { 72, SHT_REL, SHF_ALLOC, ADDR_TEXT + offsetof(elf, rel_dyn),
      offsetof(elf, rel_dyn), sizeof foo.rel_dyn, SHN_DYNSYM, SHN_UNDEF,
      sizeof(Elf32_Addr), sizeof(Elf32_Rel) },
    /* .got.plt */
    { 81, SHT_PROGBITS, SHF_WRITE | SHF_ALLOC,
      ADDR_TEXT + offsetof(elf, got_plt), offsetof(elf, got_plt),
      sizeof foo.got_plt, SHN_UNDEF, 0, sizeof(Elf32_Addr),
      sizeof(Elf32_Addr) },
    /* .dynamic */
    { 90, SHT_DYNAMIC, SHF_WRITE | SHF_ALLOC,
      ADDR_TEXT + offsetof(elf, dynamic), offsetof(elf, dynamic),
      sizeof foo.dynamic, SHN_DYNSTR, 0, sizeof(Elf32_Addr),
      sizeof(Elf32_Dyn) },
    /* .hash */
    { 99, SHT_HASH, SHF_ALLOC, ADDR_TEXT + offsetof(elf, hash),
      offsetof(elf, hash), sizeof foo.hash, SHN_DYNSYM, 0, sizeof(Elf32_Word),
      sizeof(Elf32_Word) },
    /* .gnu.version */
    { 105, SHT_HIOS, SHF_ALLOC, ADDR_TEXT + offsetof(elf, gnu_version),
      offsetof(elf, gnu_version), sizeof foo.gnu_version, SHN_DYNSYM, 0,
      sizeof(Elf32_Half), sizeof(Elf32_Half) },
    /* .got */
    { 118, SHT_PROGBITS, SHF_WRITE | SHF_ALLOC,
      ADDR_TEXT + offsetof(elf, got), offsetof(elf, got), sizeof foo.got,
      SHN_UNDEF, 0, sizeof(Elf32_Addr), sizeof(Elf32_Addr) },
    /* .symtab */
    { 1, SHT_SYMTAB, 0, 0, offsetof(elf, symtab), sizeof foo.symtab,
      SHN_STRTAB, 5, sizeof(Elf32_Addr), sizeof(Elf32_Sym) },
    /* .strtab */
    { 9, SHT_STRTAB, 0, 0, offsetof(elf, strtab), sizeof foo.strtab,
      SHN_UNDEF, 0, 1, 0 },
    /* .shstrtab */
    { 17, SHT_STRTAB, 0, 0, offsetof(elf, shstrtab), sizeof foo.shstrtab,
      SHN_UNDEF, 0, 1, 0 }
  },
  /* _end */
  { }
};
int main(void) { return fwrite(&foo, 1, offsetof(elf, _end), stdout); }
