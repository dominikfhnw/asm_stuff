#if 0
gcc -m32 -masm=intel -g -Wall -Wextra -O0 -fno-asynchronous-unwind-tables -fno-stack-clash-protection -fno-stack-protector -fcf-protection=none -no-pie -fno-pie -fno-plt -fno-PIC $0 -o sig
gcc -m32 -masm=intel -g -w -O0 -fno-asynchronous-unwind-tables -fno-stack-clash-protection -fno-stack-protector -fcf-protection=none -no-pie -fno-pie -fno-plt -fno-PIC $0 -S -fverbose-asm
exit
#endif
#define _GNU_SOURCE
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <signal.h>
#include <ucontext.h>
//#include <linux/signal.h>     /* Definition of SI_* constants */
#include <sys/syscall.h>      /* Definition of SYS_* constants */
#include <string.h>      /* Definition of SYS_* constants */

#ifdef __i386__
#define IP REG_EIP
#else
#define IP REG_RIP
#endif

/*
	altcall

	alternative calling conventions
	
	idea: use int1/int3/ud0/ud1/ud2 instead of syscall/sysenter/call:
	* install handler for SEGV/ILL/TRAP, with SIGINFO set
	* we can filter out 'real' signals from ones created by int1.. by the siginfo fields
	* idea: convert between param on stack/registers, and/or keep stack without popping
	* idea: set sycall nr or function nr as next byte after int3
	* idea: syscall does not clobber eax, instead sets parity or carry flag on
	  error, and saves the return value in some predefined memory location
	* idea: instead of "call <absolute address>" (6 bytes), do a "int1 <function-index>" (2 bytes if #func < 256)
	* idea: suffix parameter. Assume function-index of puts with direct string parameter is 1: "int1, 1, 'h', 'e', 'l', 'l', 'o', 0"

*/
void trap(int sig, siginfo_t* info, ucontext_t* ucontext){
	//puts("signal");
	printf("signal %d, siginf size %zu, ucontext size %zu\n", sig, sizeof(*info), sizeof(*ucontext));
	printf("info: signo %d, errno %d, code %d\n", info->si_signo, info->si_errno, info->si_code);
	int code = info->si_code;
	if(code > 0)
		printf("KERN info: addr %p, addr_lsb %d, lower %p, upper %p, pkey %d\n", info->si_addr, info->si_addr_lsb, info->si_lower, info->si_upper, info->si_pkey );
	else{
		printf("USER info: pid %d, uid %d, status %d\n", info->si_pid, info->si_uid, info->si_status);
		printf("USER ihex: %zX %zX %zX %zX %zX\n",               info->si_errno, info->si_code, info->si_pid, info->si_uid, info->si_status);
		unsigned char *ix = info;
		for(int i = 0; i < 128; i++){
			if(i%16==0)
				puts("");
			printf("%02X ", ix[i]);
		}
		puts("\n");
		//printf("USER ihx2: %.*s\n", 128, info);
	}
	
	greg_t *r = ucontext->uc_mcontext.gregs;
#ifdef __i386__
	printf("context IP 0x%zX, AX 0x%zX, BX 0x%zX, TRAPNO 0x%zX, EFL 0x%zX, ERR 0x%zX, SP 0x%zX\n", r[IP], r[REG_EAX], r[REG_EBX], r[REG_TRAPNO], r[REG_EFL], r[REG_ERR], r[REG_ESP]);
#else
	printf("context IP 0x%zX, AX 0x%zX, BX 0x%zX, TRAPNO 0x%zX, EFL 0x%zX, ERR 0x%zX, SP 0x%zX\n", r[IP], r[REG_RAX], r[REG_RBX], r[REG_TRAPNO], r[REG_EFL], r[REG_ERR], r[REG_RSP]);
#endif

	      if(sig == 11 && code ==   1){
		printf("SEGV_MAPERR %p IP 0x%zx\n\n", info->si_addr,r[IP] );
		//signal(SIGSEGV, SIG_DFL);
		asm volatile("hlt\n");
	}else if(sig ==  5 && code == 128){
		puts("EXEC int3\n");
		// DO NOT INCREASE EIP
		setcontext(ucontext);
	}else if(sig ==  5 && code ==   1){
		puts("EXEC int1\n");
		// DO NOT INCREASE EIP
		setcontext(ucontext);
	}else if(sig == 11 && code == 128){
		puts("EXEC hlt\n");
		// scary. this could alo be int xx instead of hlt
#ifdef __i386__
		r[IP] += 2;
#else
		r[IP] += 1; // ???
#endif
		setcontext(ucontext);
#if 1
	}else if(sig ==  4 && code  >   0){
		puts("EXEC illegal instr\n");
		// scary
		r[IP] += 2;
		setcontext(ucontext);
#endif
	}else{
		puts("RET OTHER\n");
		signal(SIGSEGV, SIG_DFL);
		asm volatile("hlt\n");
		//abort();
	}
	//sigreturn();
	pause();
}

int main(){
	//signal(SIGUSR1, trap);
	struct sigaction sa = {
		.sa_sigaction = &trap,
		.sa_flags = SA_SIGINFO,
		//.sa_flags = SA_SIGINFO | SA_NODEFER,
	};
	int ret = sigaction(SIGTRAP, &sa, NULL);
	printf("ret %d\n", ret);
	ret = sigaction(SIGSEGV, &sa, NULL);
	ret = sigaction(SIGUSR1, &sa, NULL);
	ret = sigaction(SIGINT, &sa, NULL);
	ret = sigaction(SIGILL, &sa, NULL);
	ret = sigaction(SIGCHLD, &sa, NULL);
	printf("ret %d\n", ret);
	siginfo_t info = { .si_signo = 1, .si_errno = 2, .si_code = -3, .si_pid = 4, .si_uid = 5, .si_status = 6 };
	//memset(&info, 0xFF, sizeof(info));
	printf("pid: %d\n", getpid());
	//syscall(SYS_rt_sigqueueinfo, getpid(), SIGUSR1, &info);
	//pause();
	//asm volatile(".byte 6\n");
	asm volatile("hlt\n");
	asm volatile("ud2\n");
	asm volatile("ud2\n");
	asm volatile("int3\n");
	asm volatile("int1\n");
	asm volatile(".byte 0x0f, 0xb9, 0\n");
	asm volatile(".byte 0x0f, 0x0b\n");
	asm volatile(".byte 0x0f, 0xff, 0\n");
	asm volatile("vmcall\n");
	asm volatile("mov dx, 0x3f8\noutb dx, al\n");
	kill(0,0);
	kill(0,SIGILL);
	asm volatile("int3\n");
	asm volatile("int1\n");
	return 0;
	asm volatile("int 0x1\n");
	asm volatile("int 0x2\n");
	//asm volatile("int 0x3\n");
	asm volatile("int 0x4\n");
	asm volatile("int 0x5\n");
	asm volatile("int 0x6\n");
	asm volatile("int 0x7\n");
	asm volatile("int 0x8\n");
	asm volatile("int 0x9\n");
	asm volatile("int 0xa\n");
	return 0;

	asm volatile(
		"mov edi, esp\n"
		"1: stosw\n"
		"jmp 1b\n"
	);

	puts("end");
	return 0;



	pause();
	return 0;
	asm volatile("int1\n");
	asm volatile("int1\n");
	asm volatile("int3\n");
	asm volatile(
		"mov edi, esp\n"
		"1: stosw\n"
		"jmp 1b\n"
	);
	asm volatile("mov [eax], ebx\n");
	//raise(SIGUSR1);

	/*
	puts("hello world");
	pause();
	puts("first pause done");
	while(1){ pause(); };
	puts("bye world\n");
	*/
}

/*
void _start(){
	// https://sourceware.org/git/?p=glibc.git;a=blob;f=sysdeps/x86_64/elf/start.S;h=3c2caf9d00a0396ef2b74adb648f76c6c74ff65f;hb=cvs/glibc-2_9-branch
	__asm__("#xorl %ebp, %ebp\n\
		#movq %rdx, %r9\n\
		#popq %rsi\n\
		#movq %rsp, %rdx\n\
		#andq  $~15, %rsp\n\
		#pushq %rax\n\
		pushq %rsp\n\
	");
	main();
	_exit(0);
}
*/

