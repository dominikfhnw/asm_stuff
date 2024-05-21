CC   = clang
CC   = gcc
LD   = ld
LD   = $(CC)
BITS = 32
SRC  = hello.c

OBJ=$(SRC:.c=.o)
FILES=$(OBJ) -o strip3

LDFLAGS0=--gc-sections --print-gc-sections -z norelro -z noseparate-code
LDFLAGS=$(LDFLAGS0) --build-id=none --orphan-handling=warn --script=o4 --print-map
#CLDFLAGS=$(shell echo $(LDFLAGS) | sed -E 's/--/-Wl,&/g;s/-z /-Wl,-z,/g')

ifeq ($(LD),$(CC))
P := -Wl,--
Q := -Wl,-z,
LDFLAGS := $(subst --,$P,$(LDFLAGS))
LDFLAGS := $(subst -z ,$Q,$(LDFLAGS))
LEXTRA := -m$(BITS) -no-pie -nostartfiles
else

DL=-dynamic-linker
ifeq ($(BITS),64)
FORMAT=elf_x86_64
DL+=/lib64/ld-linux-x86-64.so.2
else
FORMAT=elf_i386
DL+=/lib/ld-linux.so.2
endif
ifeq ($(BITS),x32)
FORMAT=elf32_x86_64
DL+=/libx32/ld-linux-x32.so.2
endif
LIBS=-lgcc -lgcc_s -lc
LEXTRA=-m$(FORMAT) $(DL) $(LIBDIR) --as-needed --hash-style=gnu

endif

CFLAGS0=-ffunction-sections -fdata-sections
CFLAGS0+=-falign-functions=1 -falign-loops=1 -fomit-frame-pointer
CFLAGS=$(CFLAGS0) -fno-plt

ifeq ($(CC),gcc)
EXTRA=-Os
endif
ifeq ($(CC),clang)
EXTRA=-Oz
endif

LIBDIR=$(shell $(CC) -m$(BITS) -print-search-dirs | sed -n '/^libraries: =/{s///;s/:/\n/g;p}' | xargs readlink -e | sort -u | sed 's/^/-L /')

compile: $(SRC)
	@#echo LDFLAGS $(LDFLAGS)
	@#echo LDFLAGS $(CLDFLAGS)
	$(CC) $(EXTRA) $(CFLAGS) -m$(BITS) -DNOSTART -c $^
	@#objcopy -v --gap-fill 0x41 --set-section-alignment '.symtab'=1 hello.o hello2.o && rm hello.o && mv hello2.o hello.o
	#$(LD) -m$(BITS) -no-pie -nostartfiles $(LDFLAGS) $(FILES) $(LIBS) > map
	$(LD) $(LEXTRA) $(LDFLAGS) $(FILES) $(LIBS) > map
	#$(LD) -m$(FORMAT) $(DL) $(LIBDIR) --as-needed --hash-style=gnu $(LDFLAGS) $(FILES) $(LIBS) > map
	@ls -l strip3

strip: compile
	@strip -R .gnu.hash -R .gnu.version -R .got strip3 -o strip3b
	@sstrip -z strip3b
	@ls -l strip3b
	@./strip3b || echo "return $$?"


.PHONY: old
old:
	gcc -Os -mpreferred-stack-boundary=4 -ffunction-sections -fdata-sections -falign-functions=1 -falign-jumps=1 -falign-loops=1 -fomit-frame-pointer -fno-plt -no-pie  -m32 -DNOSTART -nostartfiles hello.c -Wl,-To4
	@strip -R .gnu.hash -R .gnu.version -R .got strip3 -o strip3b
	@sstrip -z strip3b
	@ls -l strip3b
	@./strip3b

.PHONY: static
static: hello.c
	diet -Os gcc $(CFLAGS) -Wl,-Tstatic hello.c -o strip3 -Wl,-M > map
	@ls -l strip3
	@strip -R .gnu.hash -R .gnu.version -R .got strip3 -o strip3b
	@sstrip -z strip3b
	@ls -l strip3b

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

