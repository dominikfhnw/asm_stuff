#if 0
gcc -no-pie -Os -g -fsanitize=address,undefined -m32 -masm=intel $0 && ./a.out
exit
#endif
#include "mini.h"

#include <stdio.h>
#include <unistd.h>

#include <stdint.h>
#include <link.h>

#if DYN
#define ELF_BASE_ADDRESS 0x400000
#else
#define ELF_BASE_ADDRESS 0x8048000
#endif

//static void dnload(void);
static void* dnload_find_symbol(uint32_t hash);
static int (*puts2)(const char *);
static void* (*dlsym2)(int zero, const char*);
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

//extern int __attribute__ ((alias (""))) var_alias;
int main(){
//	asm volatile("lfence" ::: "memory");

	printf("dlsym2 %p\n", dlsym2);
	dnload_find_symbol(0);
	//IMPORT_STACK(printf, int, const char *, ...);
#if 1
	//printf("LINK_MAP %p\n", xlink_map);
	//put(rodata, dynsym - rodata);
	//put("\n**********\n",12);
	//put(text2, dynamic - text2);
	//put("\n**********\n",12);
	dlsym_ptr = &dlsym;
	//printf("ret %d\n", ret);
	//IMPORT_STACK(puts, int, const char *);
	//puts2 = dlsym(RTLD_DEFAULT, "puts");
	//puts2("Hello World!");

	//SYMPRINT(interp);
	//SYMPRINT(text2);
	//SYMPRINT(rodata);
	//SYMPRINT(dynstr);
	//SYMPRINT(dynsym);
	//SYMPRINT(dynamic);
	printf("dlsym %p\n", dlsym_ptr);
	printf("dlsym2 %p\n", dlsym2);
#endif
	//printf("loca %p\n", puts2);
	//printf("impo %p\n", &puts);

//	BREAK();
	//puts("fo");
	return 42;
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
	//IMPORT_STACK(printf, int, const char *, ...);
	const Elf32_Dyn *dynamic = (Elf32_Dyn*)dyn;
	for(;;)
	{
		#if 1
		//dprintf("dyn 0x%x\n", dynamic);
		//if(dynamic == 0){
		//	dprintf("zeri tag\n");
		////	return 0;
		//}
		dprintf("dyntab 0x%x %d 0x%x\n", dynamic, dynamic->d_tag, dynamic->d_un.d_ptr);
		#endif
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
	//dprintf("too far\n");
	//return 0;
}

static const void* elf32_get_library_dynamic_section(const struct link_map *lmap, Elf32_Sword op)
{
	//IMPORT_STACK(printf, int, const char *, ...);
	const void *ret = elf32_get_dynamic_address_by_tag(lmap->l_ld, op);
	// Sometimes the value is an offset instead of a naked pointer.
	#if 1
	if(ret==0){
		dputs("!!!empty section");
		//asm volatile("hlt");
		return 0;
	}
	dprintf("boop %p %p\n", ret, lmap->l_addr);
	#endif
	//return (ret < (void*)lmap->l_addr) ? (uint8_t*)ret + (size_t)lmap->l_addr : ret;
	const void *f =  (ret < (void*)lmap->l_addr) ? (uint8_t*)ret + (size_t)lmap->l_addr : ret;
	//dprintf("bxxoop %p \n", f);
	return f;
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
	
//__attribute__((optimize("-O0")))
static void loopy(uint32_t volatile numchains,const Elf32_Sym* symtab, const char* strtab,const struct link_map* lmap){
	dprintf("loopy: num:%x sym:0x%x str:0x%x lmap:0x%x\n", numchains, symtab, strtab, lmap);
	uint32_t ii;
	for(ii = 0; (ii < numchains); ++ii)
	{
		const Elf32_Sym* sym = &symtab[ii];
		#if 0
		if(sym == 0){
			dputs("!!!empty sym\n");
			return;
		}
		#endif
		//dprintf("o%d: %x %x\n", ii, sym, sym->st_name);
		const char *name = &strtab[sym->st_name];
		const int nn = *(int*)&strtab[sym->st_name];
		dprintf("p%d: %s %x %x\n", ii, name, nn, sym);
		void* val = (void*)((const uint8_t*)sym->st_value + (size_t)lmap->l_addr);
		if(nn == 0x79736c64){
			dbg2("dlsym");
			dlsym2 = val;
		}
		//printf("n %s\tval %d\tlmap %d\tval %p\n", name,sym->st_value, lmap->l_addr, val);
		#if DD
		if(name == 0){
			dputs("!!!empty name\n");
			return;
		}
		if(val == 0){
			dputs("!!!empty val\n");
			return;
		}
		#endif

		#if DL_DEBUG
		printf("%4d: %p %s\n", ii, val, name);
		#else
		//sputs(name);
		#endif
		/*
		if(sdbm_hash((const uint8_t*)name) == hash)
		{
			return (void*)((const uint8_t*)sym->st_value + (size_t)lmap->l_addr);
		}
		*/
	}
}

//__attribute__((optimize("-Os")))
void* dnload_find_symbol()
{
	//IMPORT_STACK(printf, int, const char *, ...);
	dprintf("Link start\n");
#ifdef HACKY
	const struct link_map* lmap = xlink_map;
#else
	const struct link_map* lmap = elf32_get_link_map();
#endif
	//lmap = lmap->l_next;
	for(;;)
	{
		if(lmap == 0){
			dputs("!!!empty lmap\n");
			return 0;
		}
		dprintf("Link map %p\n", lmap);
		//if(lmap->l_name == 0){
		//	dputs("!!!empty name\n");
		//	goto next;
		//} else {
			//printf("NAM: %s", lmap->l_name);
			//sputs("name:");
			//sputs(lmap->l_name);
		//}
		/* Find symbol from link map. We need the string table and a corresponding symbol table. */
		//dprintf("strtab pre\n");
		//#endif
		const char* strtab = (const char*)elf32_get_library_dynamic_section(lmap, DT_STRTAB);
		#if DD
		if(strtab == 0){
			dputs("!!!empty strtab\n");
			goto next;
		}
		dprintf("strtab 0x%x\n",strtab);
		dprintf("symtab pre\n");
		#endif
		const Elf32_Sym* symtab = (const Elf32_Sym*)elf32_get_library_dynamic_section(lmap, DT_SYMTAB);
		#if DD
		if(symtab == 0){
			dputs("!!!empty symtab\n");
			goto next;
		}
		dprintf("symtab %p\n",symtab);
		dprintf("hashtab pre\n");
		#endif
		const uint32_t* hashtable = (const uint32_t*)elf32_get_library_dynamic_section(lmap, DT_HASH);
		//asm volatile("int 3" ::: "memory");
		if(hashtable == 0){
			//IMPORT_STACK(printf, int, const char *, ...);
			dputs("!!!empty hashtable\n");
			goto next;
		}
		dprintf("hashtable %p\n",hashtable);
		uint32_t volatile numchains = hashtable[1]; /* Number of symbols. */
		dprintf("num %d\n", numchains);
		loopy(numchains, symtab, strtab, lmap);
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


