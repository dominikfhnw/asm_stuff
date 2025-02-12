#include <stddef.h>

#if defined(__has_builtin)
#define HAS_BUILTIN(builtin) __has_builtin(builtin)
#else
#define HAS_BUILTIN(builtin) (0)
#endif

#  if HAS_BUILTIN(__builtin_unreachable)
#    define BUILTIN_UNREACHABLE() __builtin_unreachable()
#  else
#    define BUILTIN_UNREACHABLE() 
#  endif

//#if HAS_BUILTIN(strlen)
//#  define STRLEN strlen
//#elif HAS_BUILTIN(__builtin_strlen)
#if HAS_BUILTIN(__builtin_strlen)
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

#ifdef size_t
typedef size_t native;
#elif __M2__
typedef SCM native;
#elif SUBC
typedef unsigned long int native;
#else
typedef __SIZE_TYPE__ native;
#endif

/* Un*x */
void _exit(int status);
/* C99 */
void _Exit(int status);
/* K&R */
void exit(int status);

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
#include <asm/unistd.h>

INLINE size_t syscall1(size_t nr, size_t arg0){
	size_t ret;
	ASM(
		SYSCALL
		: "=a" (ret) : "0" (nr), ARG0 (arg0)
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
#warning "ooo"
	__builtin__exit(status);
#elif C99
#warning "C99oo"
	_Exit(status);
#elif UNIX
#warning "uni"
	_exit(status);
#else
#warning "def"
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

INLINE size_t mystrlen(const char *s)
{
	const char *a = s;
	for(; *s != 0; s += 1){}
	return s-a;
}

/* Those are not in the C99 list of acceptable freestanding headers, so
   don't include them if we don't need them */
#if !ASM_EXTENDED && !M2_DIRECT && UNIX
#include <sys/types.h>
ssize_t write(int fd, const void *buf, size_t count);
#include <unistd.h>
#else
#include <stdio.h>
#endif
static inline size_t syscall3(size_t nr, size_t arg0, size_t arg1, size_t arg2){
	size_t ret;
	ASM(
		SYSCALL
		: "=a" (ret) : "0" (nr), ARG0 (arg0), ARG1 (arg1), ARG2 (arg2)
	);
	return ret;
}


static inline void stderr_write(const char *s){
	size_t n = __builtin_strlen(s);
	syscall3(__NR_write, STDERR_FILENO, (size_t)s, n);
}
#include <string.h>
#include <unistd.h>
int main(){
	char *s = "hello world\n";
	size_t n = __builtin_strlen(s);
	syscall3(__NR_write, STDERR_FILENO, (size_t)s, n);
	//stderr_write("hello world\n");
	exit_zero();
}
