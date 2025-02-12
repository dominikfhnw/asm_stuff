#if 0
gcc -Wall -Wextra -Wpedantic -fanalyzer -DDD2 -no-pie -Os -g -fsanitize=address,undefined -m32 -masm=intel $0 && ./a.out
exit
#endif
static void* (*dlsym2)(void*, const char*);
static void (*exit2)(int);
__attribute__((used)) static void* (*dlsym3)(int zero, const char*);
//static int (*printf2)(const char*, ...);
#include "mini.h"

#include <stdio.h>
#include <unistd.h>

#include <stdint.h>
//#include <link.h>

//static void dnload(void);
//static int (*puts2)(const char *);
//IMPORT(puts, int, const char *);

//SYMBOL(text);
//SYMBOL(dynamic);
//SYMBOL(dynstr);
//SYMBOL(dynsym);
//SYMBOL(interp);
__attribute__((section (".text.unlikely"))) const char text[0];
__attribute__((section (".text"))) const char text2[0];
__attribute__((section (".rodata.first"))) const char rodata[0];

/*
static int put2(const char *str, size_t len){
	int ret;
	asm volatile(
		"xor eax, eax\n"
		"xor edx, edx\n"
		"xor ebx, ebx\n"
		"mov al, 4\n"
		"mov dl, %[len]\n"
		"inc ebx\n"
		"int 0x80\n"
	: "=a" (ret) : [len] "i" (len) , "c" (str) : "ebx", "edx"
	);
	return ret;
}
*/

int main(){

	exit2 = DNLOAD(xlink_map, 'exit');
	exit2(23);
	__builtin_unreachable();
// void (*exit2)(int);
	//((int(*)(int))pvExample)(5);
	((void(*)(int))dnload_find_symbol(xlink_map, 'tixe'))(42);
	((void(*)(int))dnload_find_symbol(xlink_map, 0x74697865))(42);
	//((*exit)(int))(dnload_find_symbol(0x74697865))(42);
	//((*exit)(int))(dnload_find_symbol(0x74697865))(42);
	__builtin_unreachable();
	return 42;
}
