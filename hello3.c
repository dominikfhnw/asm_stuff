#define NOHEADERS
#ifndef NOHEADERS
#include <stddef.h>
#else

#if __M2__
typedef SCM size_t;
#elif __MESC__


//#ifndef __MES_SIZE_T
#define __MES_SIZE_T
typedef unsigned long size_t;
//#endif


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
#if !__i386__
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
void noop(){}
#define BUILTIN_UNREACHABLE noop
#else
#  if HAS_BUILTIN(__builtin_unreachable)
#    define BUILTIN_UNREACHABLE() __builtin_unreachable()
#  else
#    define BUILTIN_UNREACHABLE() 
#  endif
#endif

#if HAS_BUILTIN(strlen)
#  define STRLEN strlen
#elif HAS_BUILTIN(__builtin_strlen)
#  define STRLEN __builtin_strlen
#else
#  define STRLEN mystrlen
#endif

#ifndef STDERR_FILENO
#define STDERR_FILENO 2
#endif

#if defined(__x86_64__)
#define SYSCALL "syscall"
#define ARG0 "D"
#define ARG1 "S"
#define ARG2 "d"
#elif defined(__i386__)
#define SYSCALL "int $0x80"
#define ARG0 "b"
#define ARG1 "c"
#define ARG2 "d"
#endif

#define MAIN int main

typedef size_t native;

/* Un*x */
void _exit(int status);
/* C99 */
void _Exit(int status);
/* K&R */
void exit(int status);
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

#if !SUBC && ( defined(__x86_64__) || defined(__i386__) )

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
	BUILTIN_UNREACHABLE();
}

NORETURN exit_zero_syscall(){
	ASM(	"xor %eax, %eax\n"
		"xor %ebx, %ebx\n"
		"inc %eax\n"
		"int $0x80"
	);
	BUILTIN_UNREACHABLE();
}
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

NORETURN exit_wrap(int status){
#if ASM_EXTENDED
	exit_syscall(status);
#else
	exit_func(status);
#endif
}

NORETURN exit_zero(){
	exit_wrap(0);
}

NORETURN exit_fail(){
	exit_wrap(1);
}

NORETURN end_process(){
#if HAS_ASM && defined(__x86_64__)
	ASM(".byte 6");
	BUILTIN_UNREACHABLE();
#elif HAS_ASM && defined(__i386__)
	ASM("hlt");
	BUILTIN_UNREACHABLE();
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
#if ASM_EXTENDED
	native n = STRLEN(s);
	syscall3(__NR_write, STDERR_FILENO, (native)s, n);
#elif UNIX
	write(STDERR_FILENO, s, STRLEN(s));
#else
	fputs(s, stderr);
#endif
}

MAIN(){
	stderr_write("hello world\n");
#if 0
	exit_zero_syscall();
#else
	exit_zero();
#endif
}
