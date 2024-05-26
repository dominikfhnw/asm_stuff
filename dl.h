#ifdef DYN

// this probably means we couldn't import a function:
#pragma GCC diagnostic error "-Wimplicit-function-declaration"

// needed for RTLD_DEFAULT:
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stddef.h>

#define IMPORT(...) static IMPORT_GLOBAL(__VA_ARGS__)

#define IMPORT_GLOBAL(...) MKFN(IMPG,##__VA_ARGS__)
#define MKFN(fn,...) MKFN_N(fn,##__VA_ARGS__,9,8,7,6,5,4,3,2,1,0)(__VA_ARGS__)
#define MKFN_N(fn, NAME, RET, n0,n1,n2,n3,n4,n5,n6,n7,n8,n,...) fn##n

#define IMPG1(NAME, RET, P1) \
	RET NAME(P1 p1){\
		IMPORT_STACK(NAME, RET, P1);\
		return NAME(p1);\
	}

#define IMPG2(NAME, RET, P1, P2) \
	RET NAME(P1 p1, P2 p2){\
		IMPORT_STACK(NAME, RET, P1, P2);\
		return NAME(p1, p2);\
	}


#define IMPG3(NAME, RET, P1, P2, P3) \
	RET NAME(P1 p1, P2 p2, P3 p3){\
		IMPORT_STACK(NAME, RET, P1, P2, P3);\
		return NAME(p1, p2, p3);\
	}

#define IMPORT_STACK(NAME, RET, ...) \
	_Pragma("GCC diagnostic push")\
	_Pragma("GCC diagnostic ignored \"-Wpedantic\"")\
	RET (*(NAME))(__VA_ARGS__) = dlsym(RTLD_DEFAULT, #NAME);\
	_Pragma("GCC diagnostic pop")\
	dlerr()

#define DLOPEN_OLD(lib) \
	void *dl;\
	dl = dlopen((lib), RTLD_LAZY);\
	dlerr()

#ifdef DEBUG
#include <stdlib.h>
#include <stdio.h>
void dlerr(){
	char *error;
	error = dlerror();
	if (error != NULL) {
		fprintf(stderr, "%s\n", error);
		exit(EXIT_FAILURE);
	}
}
#else
#define dlerr()
#endif

#else
#define IMPORT(RET, NAME, ...)
#define DLOPEN(lib)
#endif

