#include <sys/syscall.h>
#include <stddef.h>
#define STDERR_FILENO 2

static int syscall3(int nr, int arg0, int arg1, int arg2){
	asm volatile(
		"int 0x80"
		: "+a" (nr) : "b" (arg0), "c" (arg1), "d" (arg2) 
	);
	return nr;
}

static int put(const char *s, size_t n){
	return syscall3(SYS_write, STDERR_FILENO, (int)s, n);
}

static int __dbg_nonl(const char *s){
	size_t n = __builtin_strlen(s);
	return syscall3(SYS_write, STDERR_FILENO, (int)s, n);
}

#define DBG_PUSH \
	"push ebx\n"\
	"push edx\n"\
	"push ecx\n"\
	"push eax\n"

#define DBG_POP	\
	"pop eax\n"\
	"pop ecx\n"\
	"pop edx\n"\
	"pop ebx\n"
 
#define DBG_LEN(STRING)	__builtin_strlen(STRING)+1
#define DBG_SYSCALL	SYS_write
#define DBG_FD		STDERR_FILENO
#define DBG_OP(STRING)	: : [syscall]"g"(DBG_SYSCALL), [fd]"g"(DBG_FD), [size]"g"(DBG_LEN(STRING)) 

#define dbg3(STRING) asm volatile("DBG%=:\n"\
 		DBG_PUSH\
		"push %[fd]\n"\
		"push %[size]\n"\
		"call 0f\n"\
		".ascii \""\
		STRING\
		"\\n\"\n"\
		"0: push %[syscall]\n"\
		DBG_POP\
		"int 0x80\n"\
		DBG_POP\
		DBG_OP(STRING)\
	);


#define dbg2(STRING) asm volatile("DBG%=:\n"\
		"push %[fd]\n"\
		"push %[size]\n"\
		"call 0f\n"\
		".ascii \""\
		STRING\
		"\\n\"\n"\
		"0: push %[syscall]\n"\
		DBG_POP\
		"int 0x80\n"\
		DBG_OP(STRING) : "eax", "ebx", "ecx", "edx"\
	);


#define dbg(STR) __dbg_nonl(STR "\n")

