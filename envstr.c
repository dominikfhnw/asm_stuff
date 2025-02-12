#if 0
OPT="-nostdlib -nostartfiles -Wall -Wno-unused-command-line-argument -Wl,-z,norelro -Wl,-z,execstack -Wl,-z,noseparate-code -Wl,--gc-sections -Wl,--build-id=none -fno-asynchronous-unwind-tables -fno-stack-clash-protection -fno-stack-protector -fcf-protection=none -no-pie -fno-pie -fno-plt -fwhole-program -fverbose-asm -m32 -Oz envstr.c"
BASE=$(basename "$0" .c)
gcc-12 $OPT -w -S -o ${BASE}-gcc.asm
gcc-12 $OPT -g -o ${BASE}-gcc
clang $OPT -w -S -o ${BASE}-clang.asm
clang $OPT -gdwarf-4 -o ${BASE}-clang
cp ${BASE}-gcc{,-strip}
cp ${BASE}-clang{,-strip}
sstrip -z ${BASE}-gcc-strip
sstrip -z ${BASE}-clang-strip
ls -l ${BASE}-gcc-strip ${BASE}-clang-strip
exit
#endif
#define DEBUG 0
#define NOSTART 1

#if DEBUG
#include <stdio.h>
#define dprintf(...) printf(__VA_ARGS__)
#else
#define dprintf(...)
#endif

#if NOSTART
#include "libcero.h"
#else
#include <unistd.h>
#include <stdlib.h>
#endif

int main(int argc, char** argv){
	char* ptr = argv[0];
	puts_inline("start...");
	dprintf("argv0 %p\n", ptr);
	int* stack = (int*)ptr;
	int* orig = (int*)ptr;
	puts_inline("ffffff");
	while(*stack++ != 0){
		//stack += 4;
		puts_inline("stack");
		write(1, stack, 4);
		dprintf("stack %p %x\n", stack, *stack);
	}
	size_t stacksize = 4*(stack-orig);
	dprintf("stack %p %p %d\n", stack, orig, stacksize);
	puts_inline("success");
	

	int ret = write(STDOUT_FILENO, orig, stacksize);
	puts_inline("exit");
	exit(ret);

}
