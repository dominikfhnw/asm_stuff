#if 0
exec gcc -m32 -masm=intel -nostartfiles -nostdlib -Wl,--script=o4 -Wl,--dynamic-linker=/home/balou/interp -Og $0 -o abort
#exec gcc -m32 -masm=intel -nostartfiles -nostdlib -Og -gdwarf-4 $0 -o abort
#endif

#include "dbg.h"
//#include <stdio.h>
//#include <unistd.h>
//#include "debug-trap.h"

void _start(){
	//__builtin_trap();
	//psnip_trap();
	dbg2("hello world");
	__builtin_trap();
	__builtin_unreachable();
	//_exit(0);
}
