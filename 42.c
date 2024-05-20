#include <unistd.h>

void _start(){
	// push stack position on stack
	#ifdef __amd64
	__asm__("pushq %rsp"); 
	#elif __i386
	__asm__("push %esp"); 
	#else
	#error unsupported architecture
	#endif

	_exit(42);
}
