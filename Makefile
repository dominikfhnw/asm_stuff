#CC=gcc -Os -fno-plt -no-pie -ffunction-sections -fdata-sections -Wl,--gc-sections -fno-exceptions -Wl,-z,norelro,-z,execstack,--build-id=none -Wl,-To4

LDFLAGS0=--gc-sections --print-gc-sections -z norelro -z noseparate-code
LDFLAGS=--build-id=none --orphan-handling=warn -To4

#CFLAGS0=-ffunction-sections -fdata-sections
CFLAGS0+=-falign-functions=1 -falign-loops=1 -fomit-frame-pointer
#CFLAGS=-fno-plt -no-pie -Wl,--build-id=none -Wl,-To4 -Wl,--orphan-handling=discard
#CFLAGS=-fno-plt -no-pie -Wl,--build-id=none -Wl,--orphan-handling=warn -Wl,-To4
CFLAGS=$(CFLAGS0) -fno-plt -no-pie

CC = clang
CC = gcc

ifeq ($(CC),gcc)
EXTRA=-Os
endif
ifeq ($(CC),clang)
EXTRA=-Oz
endif

LIB=$(shell $(CC) -m32 -print-search-dirs | sed -n '/^libraries: =/{s///;s/:/\n/g;p}' | xargs readlink -e | sort -u | sed 's/^/-L /')

SRC=hello.c
OBJ=$(SRC:.c=.o)

compile: $(SRC)
	@#$(CC) -dM -DNOSTART -nostartfiles -E hello.c
	$(CC) $(EXTRA) $(CFLAGS) -m32 -DNOSTART -nostartfiles -c $^
	@#strace -s 1024 -fe trace=execve $(CC) -m32 -DNOSTART -nostartfiles hello.c -o foo
	@#$(LD) $(LIB) -m elf_i386 -as-needed -lgcc -lc -lgcc_s -dynamic-linker /lib/ld-linux.so.2 $(LDFLAGS0) $(LDFLAGS) hello.o -o strip3
	ld $(LDFLAGS0) $(LDFLAGS) -m elf_i386 --hash-style=gnu --as-needed -dynamic-linker /lib/ld-linux.so.2 $(LIB) $(OBJ) -lgcc -lgcc_s -lc -o strip3
	@ls -l strip3

strip: compile
	@strip -R .gnu.hash -R .gnu.version -R .got strip3 -o strip3b
	@sstrip -z strip3b
	@ls -l strip3b
	@./strip3b


.PHONY: old
old:
	gcc -Os -mpreferred-stack-boundary=4 -ffunction-sections -fdata-sections -falign-functions=1 -falign-jumps=1 -falign-loops=1 -fomit-frame-pointer -fno-plt -no-pie  -m32 -DNOSTART -nostartfiles hello.c -Wl,-To4
	@strip -R .gnu.hash -R .gnu.version -R .got strip3 -o strip3b
	@sstrip -z strip3b
	@ls -l strip3b
	@./strip3b

.PHONY: static
static: hello.c
	diet -Os gcc $(CFLAGS0) $(CFLAGS) -Wl,-Tstatic hello.c -o strip3 -Wl,-M > map
	@ls -l strip3
	#@strip -R .gnu.hash -R .gnu.version -R .got strip3
	#@sstrip -z strip3
	#@ls -l strip3

debug: hello.c
	$(CC) -g -DNOSTART -nostartfiles hello.c -o strip3 -Wl,-M > map
	@ls -l strip3

.PHONY: map
map:
	@sed -n '/^Linker script and memory map/,$${/^\./{/^[^ ]*$$/d;/0x0$$/d;p}}' map |\
	mawk '{a=a+$$3;printf "%20s %20s %5d %5d\n",$$1,$$2,$$3,$$2-l;l=$$2;}END{printf "%20s %20s %5d\n","TOTAL","",a}'

define hello =
#include <stdio.h>
#include <unistd.h>

#ifndef NOSTART
#define MAIN int main
#else
#define MAIN void fakemain
#endif

MAIN(){
	puts("hello world");
}

#ifdef NOSTART
__attribute__((noreturn)) void _start(){
	// https://sourceware.org/git/?p=glibc.git;a=blob;f=sysdeps/x86_64/elf/start.S;h=3c2caf9d00a0396ef2b74adb648f76c6c74ff65f;hb=cvs/glibc-2_9-branch
	/*
	__asm__("xorl %ebp, %ebp\n\ 
		movq %rdx, %r9\n\ 
		popq %rsi\n\ 
		movq %rsp, %rdx\n\ 
		andq  15, %rsp\n\ 
		pushq %rax\n\ 
	");
	*/
	// push stack position on stack
#ifdef __amd64
	__asm__("pushq %rsp"); 
#elif __i386
	__asm__("push %esp"); 
#else
	#error unsupported architecture
#endif
	fakemain();
	_exit(0);
	__builtin_unreachable();
}
#endif
endef

hello.c:
	$(file > $@,$(hello))
	@:

