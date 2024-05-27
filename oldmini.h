#ifdef NOSTART
#define main static fakemain

#define DYN
#define NOSTACK
//#define DEBUG

#include "dl.h"
// predeclaration
int main();

#if defined(__GNUC__) && !defined(__llvm__) && !defined(__INTEL_COMPILER)
#define REALLY_GCC
#define GCCATTR externally_visible, naked
#else
#define GCCATTR
#endif
__attribute__((noreturn, used, GCCATTR )) void _start(){
	// https://sourceware.org/git/?p=glibc.git;a=blob;f=sysdeps/x86_64/elf/start.S;h=3c2caf9d00a0396ef2b74adb648f76c6c74ff65f;hb=cvs/glibc-2_9-branch
	// push stack position on stack
	#ifndef NOSTACK
	#ifdef __amd64
	__asm__("pushq %rsp"); 
	#elif __i386
	__asm__("push %esp"); 
	#else
	#error unsupported architecture
	#endif
	#endif

	IMPORT(int, puts, const char *);
	puts("exit");
	//IMPORT(int, printf, const char *, ...);
	//printf("hello world %d\n", dl);

	int ret = fakemain();
	IMPORT(void, _exit, int);
	_exit(ret);
	__builtin_unreachable();
}
#endif
