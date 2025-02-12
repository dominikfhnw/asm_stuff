#ifdef NOSTART
#include <unistd.h>
#define main static fakemain
int main();
__attribute__((noreturn)) void _start(){
	// https://sourceware.org/git/?p=glibc.git;a=blob;f=sysdeps/x86_64/elf/start.S;h=3c2caf9d00a0396ef2b74adb648f76c6c74ff65f;hb=cvs/glibc-2_9-branch
	// push stack position on stack
	#ifdef __amd64
	__asm__("pushq %rsp"); 
	#elif __i386
	__asm__("push %esp"); 
	#else
	#error unsupported architecture
	#endif
	int ret = fakemain();
	_exit(ret);
	__builtin_unreachable();
}
#endif


#include <stdio.h>
int main(argc){
	return MUL * argc;
	//return(42);
}
