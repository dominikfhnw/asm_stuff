#if CERO
#include "libcero.h"
#else
#include <unistd.h>
#endif

#define HEXLEN 2*sizeof(size_t)
typedef size_t native;

#if CERO
static void hexprint2(native a){
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
		: "=a"(a));
}
#endif

static char out[HEXLEN+1];

static void hexprint3(native a){
	union data{
		native a;
		char b[sizeof(native)];
	};
	union data d;
	d.a = __builtin_bswap32(a);

	char out[HEXLEN+1];
	for(unsigned char i=0; i<HEXLEN/2; i++){
		char p = ((d.b[i] & 0xF0)>>4);
		char o = (d.b[i] & 0xF);
		if(p>9)
			p += 'a' - '9' - 1;
		//a = a >> 4;	
		if(o>9)
			o += 'a' - '9' - 1;
		out[2*i] = p + '0'; 
		out[2*i+1] = o + '0';
	}
	out[HEXLEN] = '\n';
	write(1, (void*)out, HEXLEN+1);
}


__attribute__(( regparm(1) )) static void xxprint(native a){
	//volatile char out[HEXLEN+1];
	for(unsigned char i=0; i<HEXLEN; i++){
		char o = a & 0xF;
		out[HEXLEN-1-i] = o + 'G';
		//out[HEXLEN-1-i] = o + 'K';
		a = a >> 4;	
	}
	out[HEXLEN] = '\n';
	write(1, (void*)out, HEXLEN+1);
}

__attribute__(( regparm(1) )) static void hexprint(native a){
	//volatile char out[HEXLEN+1];
	for(unsigned char i=0; i<HEXLEN; i++){
		char o = a & 0xF;
		if(o>9)
			o += 'A' - '9' - 1;
		out[HEXLEN-1-i] = o + '0';
		a = a >> 4;	
	}
	out[HEXLEN] = '\n';
	write(1, (void*)out, HEXLEN+1);
}

static void regdump(){
	size_t len = 8*sizeof(size_t);
	ASM(
	"pusha\n"
	);
}

//char buf[1024] = "hello world";
int main(){
	return 42;
	//out[HEXLEN] = '\n';
	volatile int argc = 2;
	//dbg_inline("start");
	return argc * 6;	
	//while(1){sleep(0x7f);}
	//puts(buf);
	//buf[1] = 'a';
	//puts(buf);
	//const void* ptr = out;
	hexprint(0x1034cdef);
	xxprint(0x1034cdef);
//	hexprint3(0x1234cdef);
//	hexprint(0xffffffff);
	hexprint(0xcafebabe);
	xxprint(0xcafebabe);
	//end_process();
//	hexprint3(0xcafebabe);
	//puts(" $\n");
	//__builtin_unreachable;
	return 0;
	//return 42;
}
