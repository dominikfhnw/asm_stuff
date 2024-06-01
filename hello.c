#if 0
gcc -DDD2 -no-pie -Os -g -fsanitize=address,undefined -m32 -masm=intel $0 && ./a.out
exit
#endif
static void* (*dlsym2)(int zero, const char*);
__attribute__((used)) static void* (*dlsym3)(int zero, const char*);
static int (*printf2)(const char*, ...);
#include "mini.h"

#include <stdio.h>
#include <unistd.h>

#include <stdint.h>
#include <link.h>

#if DYN
#define ELF_BASE_ADDRESS 0x400000
#define printf(...)
#else
#define ELF_BASE_ADDRESS 0x8048000
#endif

//static void dnload(void);
static void* dnload_find_symbol(int search);
static const struct link_map* elf32_get_link_map();
static const void* elf32_get_dynamic_address_by_tag(const void *dyn, Elf32_Sword tag);
static int (*puts2)(const char *);
//IMPORT(puts, int, const char *);

//SYMBOL(text);
//SYMBOL(dynamic);
//SYMBOL(dynstr);
//SYMBOL(dynsym);
//SYMBOL(interp);
__attribute__((section (".text.unlikely"))) const char text[0];
__attribute__((section (".text"))) const char text2[0];
__attribute__((section (".rodata.first"))) const char rodata[0];

/*
static int put2(const char *str, size_t len){
	int ret;
	asm volatile(
		"xor eax, eax\n"
		"xor edx, edx\n"
		"xor ebx, ebx\n"
		"mov al, 4\n"
		"mov dl, %[len]\n"
		"inc ebx\n"
		"int 0x80\n"
	: "=a" (ret) : [len] "i" (len) , "c" (str) : "ebx", "edx"
	);
	return ret;
}
*/
#if !DD
#define dputs(...)
#define dprintf(...)
#else
#include <stdio.h>
#define dputs(...) puts(__VA_ARGS__)
#define dprintf(...) printf(__VA_ARGS__)
#endif

#if DD2
#define DN_DBG(...) dbg2(__VA_ARGS__)
#define DN_PRINTF(...) printf(__VA_ARGS__)
#else
#define DN_DBG(...)
#define DN_PRINTF(...)
#endif

int main(){

	dnload_find_symbol(0x79736c64);
	// TODO: find better way to force-use dlsym
	asm volatile("" :: "r"(&dlsym));
	return 42;
}

static const struct link_map* elf32_get_link_map()
{
	// ELF header is in a fixed location in memory.
	// First program header is located directly afterwards.
	const Elf32_Ehdr *ehdr = (const Elf32_Ehdr*)ELF_BASE_ADDRESS;
	const Elf32_Phdr *phdr = (const Elf32_Phdr*)((size_t)ehdr + (size_t)ehdr->e_phoff);
	// Find the dynamic header by traversing the phdr array.
	for(; (phdr->p_type != PT_DYNAMIC); ++phdr) { }
	// Find the debug entry in the dynamic header array.
	{
		const struct r_debug *debug = (const struct r_debug*)elf32_get_dynamic_address_by_tag((const void*)phdr->p_vaddr, DT_DEBUG);
		return debug->r_map;
	}
}

static uint32_t sdbm_hash(const uint8_t *op)
{
	uint32_t ret = 0;
	for(;;)
	{
		uint32_t cc = *op++;
		if(!cc)
		{
			return ret;
		}
		ret = ret * 65599 + cc;
	}
}

static const void* elf32_get_dynamic_address_by_tag(const void *dyn, Elf32_Sword tag)
{
	const Elf32_Dyn *dynamic = (Elf32_Dyn*)dyn;
	for(;;)
	{
		//dprintf("dyntab 0x%x %d 0x%x\n", dynamic, dynamic->d_tag, dynamic->d_un.d_ptr);
		if(dynamic->d_tag == tag)
		{
			return (const void*)dynamic->d_un.d_ptr;
		}
		else if(dynamic->d_tag == 0)
		{
			dputs("!!!end of table");
			return (const void*)0;
		}
		++dynamic;
	}
}

static const void* elf32_get_library_dynamic_section(const struct link_map *lmap, Elf32_Sword op)
{
	const void *ret = elf32_get_dynamic_address_by_tag(lmap->l_ld, op);
	if(ret==0){
		dputs("!!!empty section");
		return 0;
	}
	dprintf("boop %p %p\n", ret, lmap->l_addr);
	const void *f =  (ret < (void*)lmap->l_addr) ? (uint8_t*)ret + (size_t)lmap->l_addr : ret;
	return f;
}

static void loopy(uint32_t volatile numchains, const Elf32_Sym* symtab, const char* strtab, const struct link_map* lmap, int search){
	DN_PRINTF("loopy: num:%x sym:0x%x str:0x%x lmap:0x%x\n", numchains, symtab, strtab, lmap);
	uint32_t ii;
	for(ii = 0; (ii < numchains); ++ii)
	{
		const Elf32_Sym* sym = &symtab[ii];
		const char *name = &strtab[sym->st_name];
		const int nn = *(int*)&strtab[sym->st_name];
		#if DD2
		DN_PRINTF("%d: %s %x %x\n", ii, name, nn, sym);
		DN_PRINTF("SEARCH %x\n", search);
		#endif
		void* val = (void*)((const uint8_t*)sym->st_value + (size_t)lmap->l_addr);
		if(nn == search){
			DN_DBG("found");
			dlsym2 = val;
		}
		//printf("n %s\tval %d\tlmap %d\tval %p\n", name,sym->st_value, lmap->l_addr, val);

		//sputs(name);
		#if DL_DEBUG
		//printf("%4d: %p %s\n", ii, val, name);
		#endif
	}
}

//__attribute__((noinline))
void* dnload_find_symbol(int search)
{
	dprintf("Link start\n");
	//IMPORT_STACK(printf, int, const char *, ...);
#ifdef HACKY
	const struct link_map* lmap = xlink_map;
#else
	const struct link_map* lmap = elf32_get_link_map();
#endif
	for(;;)
	{
		if(lmap == 0){
			return 0;
		}
		DN_DBG("ITER");
		DN_PRINTF("NAME: %s (%p)\n", lmap->l_name, lmap);
		const void* base = lmap->l_addr;
		const char* strtab;
		const Elf32_Sym* symtab;
		uint32_t* hashtable = 0;
		const Elf32_Dyn *dynamic = (Elf32_Dyn*)lmap->l_ld;

		//DN_PRINTF("HASHpre: %p %p\n", hashtable, 0);
		for(;;)
		{
			int ptr = dynamic->d_un.d_ptr;
			if(ptr < base)
				ptr = ptr + base;

			//printf("mmm %p %d\n", ptr, dynamic->d_tag);
			switch (dynamic->d_tag){
				case DT_STRTAB:
					DN_DBG("strtab");
					strtab = (const char*)ptr;
					break;
				case DT_SYMTAB:
					DN_DBG("symtab");
					symtab = (const Elf32_Sym*)ptr;
					break;
				case DT_HASH:
					DN_DBG("!!!!hash");
					hashtable = (const uint32_t*)ptr;
					break;
				case DT_NULL:
					DN_DBG("END");
					goto end;
			}
			++dynamic;
		}
		end:
		DN_PRINTF("STRTAB: %p %p\n", strtab, elf32_get_library_dynamic_section(lmap, DT_STRTAB));
		DN_PRINTF("SYMTAB: %p %p\n", symtab, elf32_get_library_dynamic_section(lmap, DT_SYMTAB));
		DN_PRINTF("HASH:   %p %p\n", hashtable, elf32_get_library_dynamic_section(lmap, DT_HASH));
		if(hashtable == 0){
			DN_DBG("EMPTY HASH");
			goto next;
		}
		uint32_t volatile numchains = hashtable[1]; /* Number of symbols. */
		loopy(numchains, symtab, strtab, lmap, search);
		next: lmap = lmap->l_next;
	}
}
/*
static void dnload(void)
{
	unsigned ii;
	for(ii = 0; (24 > ii); ++ii)
	{
		//void **iter = ((void**)&g_symbol_table) + ii;
		// *iter = dnload_find_symbol(*(uint32_t*)iter);
		dnload_find_symbol(0);
	}
}
*/


