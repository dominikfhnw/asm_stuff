//#define NOHEADERS
#ifndef NOHEADERS
#include <stddef.h>
#else

#if __M2__
typedef SCM size_t;
#elif __MESC__
/* this seems to get parsed specially */
#ifndef __MES_SIZE_T
#define __MES_SIZE_T
typedef unsigned long size_t;
#endif

#else
typedef __SIZE_TYPE__ size_t;
#endif

#if __linux__
#if __i386__
#define __NR_exit 1
#define __NR_write 4
#elif __x86_64__
#define __NR_exit 60
#define __NR_write 1
#endif
#endif

#endif


/* compilers that only implement a subset of C99 */
#if __M2__
#define SUBC 1
#if NOASM || !__i386__
#include <stdlib.h>
#else
#define M2_DIRECT 1
#endif
#define const  
#endif

#if __MESC__
#define SUBC 1
#endif

#if !__M2__ && defined(__has_builtin)
#define HAS_BUILTIN(builtin) __has_builtin(builtin)
#else
#define HAS_BUILTIN(builtin) (0)
#endif

#if SUBC
#define UNREACHABLE
#else
#  if HAS_BUILTIN(__builtin_unreachable)
#    define UNREACHABLE __builtin_unreachable();
#  else
#    define UNREACHABLE 
#  endif
#endif

#if HAS_BUILTIN(strlen)
#  define STRLEN strlen
#elif HAS_BUILTIN(__builtin_strlen)
#  define STRLEN __builtin_strlen
#else
#define STRLEN mystrlen
#endif

#ifndef STDERR_FILENO
#define STDERR_FILENO 2
#endif
#ifndef STDOUT_FILENO
#define STDOUT_FILENO 1
#endif

#if defined(__x86_64__)
#define SYSCALL "syscall\n"
#define ARG0 "D"
#define ARG1 "S"
#define ARG2 "d"
#elif defined(__i386__)
#define SYSCALL "int $0x80\n"
#define ARG0 "b"
#define ARG1 "c"
#define ARG2 "d"
#endif

#if defined(__GNUC__) && !defined(__llvm__) && !defined(__INTEL_COMPILER)
#define REALLY_GCC
#define GCCATTR externally_visible, naked
#else
#define GCCATTR
#endif

#if 0
#define MAIN int main
#else
#define MAIN __attribute__((used, GCCATTR)) void _start
#endif

typedef size_t native;

/* Un*x */
void _exit(int status);
/* C99 */
void _Exit(int status);
/* K&R */
//void exit(int status);
/* K&R */
/*
 Note: Clang is a lying jerk about having a __builtin_strlen function - 
 it is merely an alias for strlen. So we have to do this forward declaration
 so that it doesn't complain about its own lie
*/
size_t strlen(const char *s);

/* mesCC/M2-Planet do not support complicated ifs */
#if !SUBC && __STDC_VERSION__ >= 199901L
#define C99 1
#else
#define C99 0
#endif

/* boldly assume we're running M2-Planet on a unix system */
#if __M2__ || __linux__ || __unix__
#define UNIX 1
#else
#define UNIX 0
#endif

#define ASM __asm__ __volatile__

#if !NOASM && !SUBC && ( defined(__x86_64__) || defined(__i386__) )

#define HAS_ASM 1
#define ASM_EXTENDED 1

#else
#define HAS_ASM 0
#define ASM_EXTENDED 0
#endif

#if SUBC
#define NORETURN void
#define INLINE 
#define UNUSED

#elif !C99 && __STRICT_ANSI__
#  define NORETURN __attribute__((noreturn)) static void
#  define INLINE static 
#  define UNUSED __attribute__((unused))
#else
#  define NORETURN __attribute__((always_inline, noreturn)) static inline void
#  define INLINE __attribute__((always_inline)) static inline
#  define UNUSED __attribute__((unused))
#endif

#if ASM_EXTENDED
#ifndef __NR_exit
#include <asm/unistd.h>
#endif

#define RETURN_FAIL __NR_exit

INLINE native syscall1(native nr, native arg0){
	native ret;
	ASM(
		SYSCALL
		: "=a" (ret) : "0" (nr), ARG0 (arg0)
	);
	return ret;
}

INLINE native syscall3(native nr, native arg0, native arg1, native arg2){
	native ret;
	ASM(
		SYSCALL
		: "=a" (ret) : "0" (nr), ARG0 (arg0), ARG1 (arg1), ARG2 (arg2)
	);
	return ret;
}

NORETURN exit_syscall(int status){
	syscall1(__NR_exit, status);
	UNREACHABLE
}

NORETURN exit_nonzero_syscall(){
	native junk1;
	native junk2;
	ASM(
		"push %[nr]\n" 
		"pop %0\n" 
		"mov %0, %1\n" 
		SYSCALL
		: "=a" (junk1), "=" ARG0 (junk2) : [nr] "i" (__NR_exit)
	);
	UNREACHABLE
}


NORETURN exit_zero_syscall(){
	native junk1;
	native junk2;
	ASM(
		"push %[nr]\n" 
		"pop %0\n" 
		"xor %k1, %k1 # automatically extended to 64bit on AMD64\n" 
		SYSCALL
		: "=a" (junk1), "=" ARG0 (junk2) : [nr] "i" (__NR_exit)
	);
	UNREACHABLE
}

NORETURN exit_dontcare_syscall(){
	native junk1;
	ASM(
		"push %[nr]\n" 
		"pop %0\n" 
		SYSCALL
		: "=a" (junk1) : [nr] "i" (__NR_exit)
	);
	UNREACHABLE
}

INLINE const void* write_syscall(int fd, const void* buf, size_t count){
	return (const void*)syscall3(__NR_write, fd, (native)buf, count);
}

INLINE const void* write(int fd, const void* buf, size_t count) __attribute__((alias("write_syscall"))); 
#else
#define RETURN_FAIL 1
#endif

#if M2_DIRECT
int write(int fd, char* buf, unsigned count) {
	asm("lea_ebx,[esp+DWORD] %12"
		"mov_ebx,[ebx]"
		"lea_ecx,[esp+DWORD] %8"
		"mov_ecx,[ecx]"
		"lea_edx,[esp+DWORD] %4"
		"mov_edx,[edx]"
		"mov_eax, %4"
		"int !0x80");
}
#endif

NORETURN exit_func(int status){
#if HAS_BUILTIN(__builtin__exit)
	__builtin__exit(status);
#elif C99
	_Exit(status);
#elif UNIX
	_exit(status);
#else
	exit(status);
#endif
}

#define MICROOPTIMIZE 0
#if MICROOPTIMIZE
#define CONSTANT_OPTIMIZE(status) __builtin_constant_p(status)
#else
#define CONSTANT_OPTIMIZE(status) (0)
#endif

NORETURN exit_wrap(int status){
#if ASM_EXTENDED
	if(CONSTANT_OPTIMIZE(status)){
		if(status == 0){
			exit_zero_syscall();
		}else{
			exit_syscall(status);
		}
	} else {
		exit_syscall(status);
	}
#else
	exit_func(status);
#endif
}
NORETURN exit(int status) __attribute__((alias("exit_wrap"))); 

NORETURN exit_nonzero(){
#if ASM_EXTENDED
	exit_nonzero_syscall();
#else
	exit_wrap(RETURN_FAIL);
#endif
}

NORETURN end_process(){
#if HAS_ASM && defined(__x86_64__)
	ASM(".byte 6");
	UNREACHABLE
#elif HAS_ASM && defined(__i386__)
	ASM("hlt");
	UNREACHABLE
#elif HAS_BUILTIN(__builtin_trap)
	__builtin_trap();
#else
	exit_zero();
#endif
}

INLINE native mystrlen(const char *s)
{
	const char *a = s;
	for(; *s != 0; s += 1){}
	return s-a;
}

/* Those are not in the C99 list of acceptable freestanding headers, so
   don't include them if we don't need them */
#if ASM_EXTENDED
#elif UNIX
#include <sys/types.h>
ssize_t write(int fd, const void *buf, size_t count);
#else
#include <stdio.h>
#endif

INLINE void stderr_write(const char *s){
#if ASM_EXTENDED || UNIX
	write(STDERR_FILENO, s, STRLEN(s));
#else
	fputs(s, stderr);
#endif
}
#define inline_string(name, value) \
	char* name;\
	ASM(\
		"istart%=: call inline%=\n"\
		".ascii \""\
		value\
		"\\n\"\n"\
		"inline%=: pop %0\n"\
		"# mov inline%= - istart%= - 5, %%edx\n"\
		: "=r" (name)\
	)

#define puts_inline(string) {\
	inline_string(puts, string);\
	write(STDOUT_FILENO, puts, __builtin_strlen(string)+1);\
}
#define dbg_inline(string) {\
	inline_string(dbg, string);\
	write(STDERR_FILENO, dbg, __builtin_strlen(string)+1);\
}
//#include <alloca.h>
INLINE native isvm(){
	native featc;
	native leaf = 1;
	//char* o = alloca(12);
	ASM(
		"xor %%eax, %%eax\n"
		"inc %%eax\n"
		"pusha\n"
		"cpuid\n"
		"and %%ecx, %%ecx\n"
		"popa\n"
		"js 1f\n"
		"inc %%ebx\n"
		"1:\n"
		SYSCALL
	: "+a"(leaf), "=c"(featc) ::"bx","dx","memory");
	return featc >> 31;
}
	
NORETURN cpuid6(){
	ASM(
		//"xor %%eax, %%eax\n"		// manufacturer
		"cpuid\n"
		"pusha\n"
		"mov %%esp, %%ecx\n"		// write
		"add $16, %%ecx\n"
		"push $4\n"
		"pop %%eax\n"
		"push $1\n"
		"pop %%ebx\n"
		"push $12\n"
		"pop %%edx\n"
		SYSCALL
		"xchg %%ebx, %%eax\n"
		"xor %%ebx, %%ebx\n"
		SYSCALL
	::: "memory", "ax","bx","cx","dx");
	UNREACHABLE
}
NORETURN cpuid5(){
	ASM(
		"push $0xa\n"			// processor
		"mov $0x80000004, %%esi\n"
		"1: mov %%esi, %%eax\n"
		"cpuid\n"
		"push %%edx\n"
		"push %%ecx\n"
		"push %%ebx\n"
		"push %%eax\n"
		"dec %%esi\n"
		"cmp $1, %%si\n"
		"jg 1b\n"
		"mov $0x203a500a, %%edi\n"
		"push %%edi\n"
		"xor %%eax, %%eax\n"		// manufacturer
		"cpuid\n"
		"push %%ecx\n"
		"push %%edx\n"
		"push %%ebx\n"
		"mov $0x4d0a, %%di\n"
		"push %%edi\n"
		"mov %%esi, %%eax\n"		// hypervisor
		"shr $1, %%eax\n"
		"cpuid\n"
		"push %%edx\n"
		"push %%ecx\n"
		"push %%ebx\n"
		"mov $0x5648, %%di\n"
		"push %%edi\n"
		"mov %%esp, %%ecx\n"		// write
		"push $4\n"
		"pop %%eax\n"
		//"movzx %%si, %%ebx\n"
		"push $1\n"
		"pop %%ebx\n"
		"push $0x55\n"
		"pop %%edx\n"
		SYSCALL
		"xchg %%ebx, %%eax\n"
		"xor %%ebx, %%ebx\n"
		SYSCALL
	::: "memory", "ax","bx","cx","dx");
	UNREACHABLE
}

INLINE void cpuid4(native mode){
	native junk1;
	const void* sp;
	//char* o = alloca(12);
	ASM(
		"cpuid\n"
		"push %%edx\n"
		"push %%ecx\n"
		"push %%ebx\n"
		"push %%eax\n"
		"mov %%esp, %0\n"
	: "=b,c,d"(sp), "=c,d,b"(junk1), "=d,b,c"(junk1) : "a,a,a"(mode) :"memory");
	//: "+S"(sp), "=b"(junk1), "=c"(junk2), "=d"(junk3) : "a"(mode) :"memory");
	write(1, sp, 16);
}

INLINE void cpuid3(native mode){
	native junk1;
	const void* sp;
	//char* o = alloca(12);
	ASM(
		"cpuid\n"
		"push %%edx\n"
		"push %%ecx\n"
		"push %%ebx\n"
		"mov %%esp, %0\n"
	: "=b,c,d"(sp), "=c,d,b"(junk1), "=d,b,c"(junk1) : "a,a,a"(mode) :"memory");
	//: "+S"(sp), "=b"(junk1), "=c"(junk2), "=d"(junk3) : "a"(mode) :"memory");
	write(1, sp, 12);
}

INLINE void cpuid2(native mode){
	native junk1;
	const void* sp;
	//char* o = alloca(12);
	ASM(
		"cpuid\n"
		"push %%ecx\n"
		"push %%edx\n"
		"push %%ebx\n"
		"mov %%esp, %0\n"
	: "=b,c,d"(sp), "=c,d,b"(junk1), "=d,b,c"(junk1) : "a,a,a"(mode) :"memory");
	//: "+S"(sp), "=b"(junk1), "=c"(junk2), "=d"(junk3) : "a"(mode) :"memory");
	write(1, sp, 12);
}

INLINE void cpuid(){
	ASM(
		"xor %%eax, %%eax\n"
		"cpuid\n"
		"push %%ecx\n"
		"push %%edx\n"
		"push %%ebx\n"
		"mov %%esp, %%ecx\n"
		"push $4\n"
		"pop %%eax\n"
		"push $2\n"
		"pop %%ebx\n"
		"push $12\n"
		"pop %%edx\n"
		SYSCALL
	//: "=b,c,d"(sp), "=c,d,b"(junk1), "=d,b,c"(junk1) : "a,a,a"(mode) :"memory");
	::: "memory", "ax","bx","cx","dx");
	//: "+S"(sp), "=b"(junk1), "=c"(junk2), "=d"(junk3) : "a"(mode) :"memory");
}

static int main(){
	//puts_inline("hello world");
	write(STDOUT_FILENO, "hello world\n", 13);
	exit(0);
}

MAIN(){
#if 0
	dbg_inline("hello world");
#else
	//stderr_write("hello world\n");
#endif
	//exit(isvm());
	/*
	cpuid(0);
	write(1, "\n", 1);
	cpuid3(0x40000000);
	write(1, "\n", 1);
	cpuid4(0x80000002);
	cpuid4(0x80000003);
	cpuid4(0x80000004);
	write(1, "\n", 1);
	*/
	//cpuid5();
	exit(42);


	/*
	{
		__label__ string;
		asm goto(""::::string);
		if(0){
		string:	ASM(
				".ascii \""
				"hello world"
				"\\n\"\n"
			);
		}	
		write(STDERR_FILENO, &&string, 12);
	}
	*/
	//native ret = main();
	#if 1
	//exit(ret);
	#else
	//exit_nonzero();
	exit(42);
	#endif
}
