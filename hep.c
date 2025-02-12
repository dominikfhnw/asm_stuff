#include <stdio.h>
#include <unistd.h>

__attribute__((noreturn)) void _start(){
#ifdef __amd64
	__asm__("pushq %rsp"); 
#elif __i386
	__asm__("push %esp"); 
#else
	#error unsupported architecture
#endif
	puts("hello world");
	_exit(0);
	__builtin_unreachable();
}
