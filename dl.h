#ifdef DYN

__attribute__((section (".dlptr"))) void* (*dlsym_ptr)(void * restrict, const char * restrict);

#define DLSYM dlsym2

// this probably means we couldn't import a function:
#pragma GCC diagnostic error "-Wimplicit-function-declaration"

// needed for RTLD_DEFAULT:
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stddef.h>

#include "dnl.c"

#define UNUSED __attribute__((unused))
#define ABORT() __asm__("int 0x3")
#define IMPORT(...) static IMPORT_GLOBAL(__VA_ARGS__)

#define DNLOAD(lmap,name) dnload_find_symbol(lmap, __builtin_bswap32(name))

// some macro magic from stackoverflow to call a function that has the
// parameter count in the function name
// TODO: maybe better with an external script, especially because functions
// which return void are also a problem at the moment
// edit: ...and variadic functions are also completely borked of course

#define IMPORT_GLOBAL(...) MKFN(IMPORT_GLOBAL,##__VA_ARGS__)
#define MKFN(fn,...) MKFN_N(fn,##__VA_ARGS__,9,8,7,6,5,4,3,2,1,0)(__VA_ARGS__)
#define MKFN_N(fn, NAME, RET, n0,n1,n2,n3,n4,n5,n6,n7,n8,n,...) fn##n

#define IMPORT_GLOBAL1(NAME, RET, P1) \
	RET NAME(P1 p1){\
		IMPORT_STACK_PARTIAL(NAME, RET, P1);\
		return NAME(p1);\
		_Pragma("GCC diagnostic pop")\
	}

#define IMPORT_GLOBAL2(NAME, RET, P1, P2) \
	RET NAME(P1 p1, P2 p2){\
		IMPORT_STACK_PARTIAL(NAME, RET, P1, P2);\
		return NAME(p1, p2);\
		_Pragma("GCC diagnostic pop")\
	}

#define IMPORT_GLOBAL3(NAME, RET, P1, P2, P3) \
	RET NAME(P1 p1, P2 p2, P3 p3){\
		IMPORT_STACK_PARTIAL(NAME, RET, P1, P2, P3);\
		return NAME(p1, p2, p3);\
		_Pragma("GCC diagnostic pop")\
	}

#define IMPORT_GLOBAL4(NAME, RET, P1, P2, P3, P4) \
	RET NAME(P1 p1, P2 p2, P3 p3, P4 p4){\
		IMPORT_STACK_PARTIAL(NAME, RET, P1, P2, P3, P4);\
		return NAME(p1, p2, p3, p4);\
		_Pragma("GCC diagnostic pop")\
	}

#define IMPORT_GLOBAL5(NAME, RET, P1, P2, P3, P4, P5) \
	RET NAME(P1 p1, P2 p2, P3 p3, P4 p4, P5 p5){\
		IMPORT_STACK_PARTIAL(NAME, RET, P1, P2, P3, P4, P5);\
		return NAME(p1, p2, p3, p4, p5);\
		_Pragma("GCC diagnostic pop")\
	}

#define IMPORT_GLOBAL6(NAME, RET, P1, P2, P3, P4, P5, P6) \
	RET NAME(P1 p1, P2 p2, P3 p3, P4 p4, P5 p5, P6 p6){\
		IMPORT_STACK_PARTIAL(NAME, RET, P1, P2, P3, P4, P5, P6);\
		return NAME(p1, p2, p3, p4, p5, p6);\
		_Pragma("GCC diagnostic pop")\
	}

// missing the last pragma
#define IMPORT_STACK_PARTIAL(NAME, RET, ...) \
	_Pragma("GCC diagnostic push")\
	_Pragma("GCC diagnostic ignored \"-Wpedantic\"")\
	RET (*(NAME))(__VA_ARGS__) = DLSYM(RTLD_DEFAULT, #NAME);\
	dlerr()

// with last pragma
#define IMPORT_STACK(...) \
	IMPORT_STACK_PARTIAL(__VA_ARGS__);\
	_Pragma("GCC diagnostic pop")

#define DLOPEN(lib) \
	dlopen2((lib), RTLD_LAZY);\
	dlerr()

#ifdef DEBUG
void dlerr(){
	char *error;
	error = dlerror();
	if (error != NULL) {
		_Pragma("GCC diagnostic push")\
		_Pragma("GCC diagnostic ignored \"-Wpedantic\"")\
		int (*myputs)(const char *) = DLSYM(RTLD_DEFAULT, "puts");
		_Pragma("GCC diagnostic pop")
		myputs("dlerr: ");
		myputs(error);
		ABORT();
	}
}
#else
#define dlerr()
#endif

UNUSED static void* dlopen2(const char* lib, int flags){
	IMPORT_STACK(dlopen, void*, const char*, int);
	return dlopen(lib, flags);
}

#else
#define IMPORT(...)
#define IMPORT_STACK(...)
#define IMPORT_GLOBAL(...)
#define DLOPEN(...) 0
#endif

