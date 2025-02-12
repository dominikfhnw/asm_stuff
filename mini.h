#define BREAK() __asm__("int 0x3")
#ifdef BREAKPOINT
#define MAYBEBREAK() BREAK()
#else
#define MAYBEBREAK()
#endif

#define SYMBOL(NAME) __attribute__((section ("." #NAME))) const char (NAME)[0]
//#define SYMPRINT(NAME) printf("%s: %1$p %1$s\n", #NAME, NAME)
#define SYMPRINT(NAME) printf(#NAME ": %1$p %1$s\n", NAME)


#include "dbg.h"
#include "dl.h"

#ifdef NOSTART

//IMPORT(puts, int, const char *)
__attribute__ ((noreturn,always_inline)) static void _exit(int status){
	IMPORT_STACK(_exit, void, int);
	_exit(status);
	__builtin_unreachable();
}

// fake function in a section that gets deleted anyway, just so that
// the compiler believes us that we are in fact a dynamic executable
__attribute__ ((used, section(".got.plt"), optimize("-O0"))) void fake(){
	void* ptr = &dlsym;
}

// another fake function. It will make hardening-check believe we have stack clash protection
#if HARDEN
__attribute__ ((noreturn,used)) static void fakestackclash(){
	asm volatile(
		"1:\n"
		"cmp	ax, 0x1000\n"
		"jz	1b\n"
		"sub	ax, 0x1000\n"
		"or	al, 0x0\n"
		"jmp	1b\n"
	);
}
#endif

// DEFINITION OF MAIN()

#ifndef DYN
#include <unistd.h>
#endif
#define main static fakemain
// predeclaration
int main();

#if defined(__GNUC__) && !defined(__llvm__) && !defined(__INTEL_COMPILER)
#define REALLY_GCC
#define GCCATTR externally_visible, naked
//#define GCCATTR externally_visible
#else
#define GCCATTR
#endif
static void *xlink_map;
__attribute__((noreturn, used, GCCATTR )) void _start(){
	/*
	if(xlink_map == 0){
		dbg2("/lib/ld* <prog>, dummy!");
	}else{
		dbg2("init");
	}
	*/
	// https://sourceware.org/git/?p=glibc.git;a=blob;f=sysdeps/x86_64/elf/start.S;h=3c2caf9d00a0396ef2b74adb648f76c6c74ff65f;hb=cvs/glibc-2_9-branch
	// push stack position on stack
	// TODO: does not seem to be needed anymore
	#ifndef NOSTACK
	#ifdef __amd64
	asm("push rsp"); 
	#elif __i386
	asm volatile(
	//	"xor ebp, ebp\n"
	//	"pop esi\n"	
	//	"mov ecx, esp\n"
	//	"and esp, 0xfffffff0\n"
	//	"push eax\n"
	//	"push esp\n"
	//	"push edx\n"
		"mov ebp, esp\n" // not from original source
	);
	//__asm__("push esp"); 
	#else
	#error unsupported architecture
	#endif
	#endif

	void *link_map;
	// save EAX register in link map. Has to be the first command.
	asm volatile("" : "=a" (link_map));

	void (*exit2)(int);
	exit2 = DNLOAD(link_map, 'exit');
	exit2(111);
	__builtin_unreachable();

#if DBG_INIT
	asm volatile(
		"push 2\n"
		"push 4\n"
		"test eax, eax\n"
		"jnz 1f\n"
		"call 0f\n"
		".ascii \"/lib/ld* <prog>, dummy!\\n\"\n"
		"0: push 24\n"
		"jmp 2f\n"
		"1: call 3f\n"
		".ascii \"init\\n\"\n"
		"3: push 5\n"
		"2: pop edx\n"
		"pop ecx\n"
		"pop eax\n"
		"pop ebx\n"
		"int 0x80\n"
		: : : "eax", "ebx", "ecx", "edx"
	);
#endif

	//dbg("init");
	//return syscall3(SYS_write, STDERR_FILENO, (int)s, n);
/*
	int retw;
	asm volatile(
		"push 2\n"
		push 1f - 0f # string size\n"
		"call 1f\n"
		"0: .ascii \"hello\\n\"\n"
		"1:\n"
		"push 4\n"
		
		"pop eax\n"
		"pop ecx\n"
		"pop edx\n"
		"pop ebx\n"

		"int 0x80\n"
		"nop\n"
		: "=a" (retw) : : "ebx", "ecx", "edx"
	);
*/
//	dbg("init");
//	dbg2("init");
	MAYBEBREAK();
	

	int ret = fakemain();
#if DBG_INIT
	dbg2("end");
#endif
	//asm volatile("0: jmp 0b");
	IMPORT_STACK(exit, void, int);
	exit(ret);
	__builtin_unreachable();
	//IMPORT_STACK(fflush, int, int);
	//fflush(0);
	//_exit(ret);
}
#endif

