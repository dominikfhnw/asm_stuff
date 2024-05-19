#CC=gcc -Os -fno-plt -no-pie -ffunction-sections -fdata-sections -Wl,--gc-sections -fno-exceptions -Wl,-z,norelro,-z,execstack,--build-id=none -Wl,-To4

CFLAGS=-fno-plt -no-pie -Wl,--build-id=none -Wl,-To4
CC=gcc -Os $(CFLAGS)
CC=clang -Oz $(CFLAGS)

compile: hello.c
	$(CC) -nostartfiles hello.c -o strip3 -Wl,-M > map
	@ls -l strip3

strip: compile
	@strip -R .gnu.hash -R .gnu.version -R .got strip3
	@sstrip -z strip3
	@ls -l strip3
	@./strip3

.PHONY: map
map:
	@sed -n '/^Linker script and memory map/,$${/^\./{/^[^ ]*$$/d;/0x0$$/d;p}}' map |\
	mawk '{a=a+$$3;printf "%20s %20s %5d %5d\n",$$1,$$2,$$3,$$2-l;l=$$2;}END{printf "%20s %20s %5d\n","TOTAL","",a}'

define hello =
#include <stdio.h>
#include <unistd.h>
int main(){
	puts("hello world\n");
}

void _start(){
	// https://sourceware.org/git/?p=glibc.git;a=blob;f=sysdeps/x86_64/elf/start.S;h=3c2caf9d00a0396ef2b74adb648f76c6c74ff65f;hb=cvs/glibc-2_9-branch
	/*
	__asm__("xorl %ebp, %ebp\n\ 
		movq %rdx, %r9\n\ 
		popq %rsi\n\ 
		movq %rsp, %rdx\n\ 
		andq  $~15, %rsp\n\ 
		pushq %rax\n\ 
	");
	*/
	__asm__("pushq %rsp"); 
	int ret;
	ret = main();
	_exit(ret);
}
endef

hello.c:
	$(file > $@,$(hello))
	@:
