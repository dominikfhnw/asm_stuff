#include <stdint.h>
#include <link.h>

#define ELF_BASE_ADDRESS 0x8048000

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
		if(dynamic->d_tag == tag)
		{
			return (const void*)dynamic->d_un.d_ptr;
		}
		++dynamic;
	}
}

static const void* elf32_get_library_dynamic_section(const struct link_map *lmap, Elf32_Sword op)
{
	const void *ret = elf32_get_dynamic_address_by_tag(lmap->l_ld, op);
	// Sometimes the value is an offset instead of a naked pointer.
	return (ret < (void*)lmap->l_addr) ? (uint8_t*)ret + (size_t)lmap->l_addr : ret;
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

static void* dnload_find_symbol(uint32_t hash)
{
	const struct link_map* lmap = elf32_get_link_map();
	for(;;)
	{
		/* Find symbol from link map. We need the string table and a corresponding symbol table. */
		const char* strtab = (const char*)elf32_get_library_dynamic_section(lmap, DT_STRTAB);
		const Elf32_Sym* symtab = (const Elf32_Sym*)elf32_get_library_dynamic_section(lmap, DT_SYMTAB);
		const uint32_t* hashtable = (const uint32_t*)elf32_get_library_dynamic_section(lmap, DT_HASH);
		unsigned numchains = hashtable[1]; /* Number of symbols. */
		unsigned ii;
		for(ii = 0; (ii < numchains); ++ii)
		{
			const Elf32_Sym* sym = &symtab[ii];
			const char *name = &strtab[sym->st_name];
			if(sdbm_hash((const uint8_t*)name) == hash)
			{
				return (void*)((const uint8_t*)sym->st_value + (size_t)lmap->l_addr);
			}
		}
		lmap = lmap->l_next;
	}
}

static void dnload(void)
{
	unsigned ii;
	for(ii = 0; (24 > ii); ++ii)
	{
		void **iter = ((void**)&g_symbol_table) + ii;
		*iter = dnload_find_symbol(*(uint32_t*)iter);
	}
}


