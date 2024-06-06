/* compilers that only implement a subset of C */
#if __M2__
#define SUBC 1
#define const  
#endif
#if __MESC__
#define SUBC 1
#endif

#if defined(__has_builtin)
#  define HAS_BUILTIN(builtin) __has_builtin(builtin)
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

#if HAS_BUILTIN(__builtin_strlen)
#define STRLEN __builtin_strlen
#else
#define STRLEN mystrlen
#endif

#ifndef STDERR_FILENO
#define STDERR_FILENO 2
#endif

#if defined(__x86_64__)
//#warning "detected x64"
#define SYSCALL "syscall"
#define ARG0 "D"
#define ARG1 "S"
#define ARG2 "d"
#elif defined(__i386__)
//#warning "detected x86"
#define SYSCALL "int $0x80"
#define ARG0 "b"
#define ARG1 "c"
#define ARG2 "d"
#endif


#ifdef size_t
typedef size_t native;
#elif __M2__
typedef SCM native;
#elif SUBC
typedef unsigned long int native;
#else
typedef __SIZE_TYPE__ native;
#endif

// Un*x
void _exit(int status);
// C99
void _Exit(int status);
// K&R
void exit(int status);
//
//ssize_t write(int fd, const void *buf, size_t count);
//int fputs(const char *s, FILE *stream);

/* mesCC/M2-Planet do not support complicated ifs */
#if !SUBC && __STDC_VERSION__ >= 199901L
#define C99 1
#else
#define C99 0
#endif

/* boldly assume we're running M2-Planet on a unix system */
#if __M2__ || __unix__
//#if __unix__
#define UNIX 1
#else
#define UNIX 0
#endif

#define ASM __asm__ __volatile__

#if !__M2__ && ( defined(__x86_64__) || defined(__i386__) )

#if SUBC
#define ASM_EXTENDED 0
#else
#define ASM_EXTENDED 1
#endif

#else
#define HAS_ASM 0
#define ASM_EXTENDED 0
#endif

#ifdef SUBC
#define NORETURN void
#define INLINE 
#define UNUSED
#else
#define NORETURN __attribute__((always_inline, noreturn)) static inline void
#define INLINE __attribute__((always_inline)) static inline
#define UNUSED __attribute__((unused)) static inline
#endif

#if ASM_EXTENDED
#include <asm/unistd.h>

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
	BUILTIN_UNREACHABLE();
}

NORETURN end_process(){
#if HAS_ASM && defined(__x86_64__)
	ASM(".byte 6");
#elif HAS_ASM && defined(__i386__)
	ASM("hlt");
#elif HAS_BUILTIN(__builtin_trap)
	__builtin_trap();
#else
	exit_func(0);
#endif
	BUILTIN_UNREACHABLE();
}

INLINE native mystrlen(const char *s)
{
	const char *a = s;
	for(; *s != 0; s += 1){}
	return s-a;
}

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

int main(){
	stderr_write("hello world\n");
	end_process();
}
