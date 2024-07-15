	.file	"envstr.c"
# GNU C17 (Ubuntu 12.3.0-1ubuntu1~22.04) version 12.3.0 (x86_64-linux-gnu)
#	compiled by GNU C version 12.3.0, GMP version 6.2.1, MPFR version 4.1.0, MPC version 1.2.1, isl version isl-0.24-GMP

# GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
# options passed: -m32 -mtune=generic -march=i686 -Oz -fno-asynchronous-unwind-tables -fno-stack-clash-protection -fno-stack-protector -fcf-protection=none -fno-pie -fno-plt -fwhole-program
	.text
	.section	.text.start,"ax",@progbits
	.globl	_start
	.type	_start, @function
_start:
# libcero.h:17: 	ASM(
#APP
# 17 "libcero.h" 1
	mov %esp, %ebp

# 0 "" 2
# libcero.h:22: 	asm volatile(
# 22 "libcero.h" 1
	pop %eax	# argc
	
# 0 "" 2
# libcero.h:27: 	asm(
# 27 "libcero.h" 1
	mov %esp, %eax	# argv

# 0 "" 2
# envstr.c:33: 	char* ptr = argv[0];
#NO_APP
	movl	(%eax), %eax	# *argv_4, ptr
	movl	%eax, -16(%ebp)	# ptr, %sfp
# envstr.c:34: 	puts_inline("start...");
#APP
# 34 "envstr.c" 1
	call inline10
	.ascii "start...\n"
	inline10: pop %ecx	# puts

# 0 "" 2
# libcero/blob.h:175: 	ASM(
#NO_APP
	pushl	$4	#
	popl	%esi	# tmp113
	movl	%esi, %eax	# tmp113, ret
	pushl	$1	#
	popl	%ebx	# tmp114
	pushl	$9	#
	popl	%edx	# tmp115
#APP
# 175 "libcero/blob.h" 1
		int $0x80

# 0 "" 2
# envstr.c:38: 	puts_inline("ffffff");
# 38 "envstr.c" 1
	call inline19
	.ascii "ffffff\n"
	inline19: pop %ecx	# puts

# 0 "" 2
# libcero/blob.h:175: 	ASM(
#NO_APP
	pushl	$7	#
	movl	%esi, %eax	# tmp113, ret
	popl	%edx	# tmp120
#APP
# 175 "libcero/blob.h" 1
		int $0x80

# 0 "" 2
# envstr.c:36: 	int* stack = (int*)ptr;
#NO_APP
	movl	-16(%ebp), %esi	# %sfp, stack
# libcero/blob.h:175: 	ASM(
	pushl	$4	#
	popl	%edi	# tmp146
.L2:
# envstr.c:39: 	while(*stack++ != 0){
	addl	$4, %esi	#, stack
# envstr.c:39: 	while(*stack++ != 0){
	cmpl	$0, -4(%esi)	#, MEM[(int *)stack_16 + 4294967292B]
	je	.L5	#,
# envstr.c:41: 		puts_inline("stack");
#APP
# 41 "envstr.c" 1
	call inline33
	.ascii "stack\n"
	inline33: pop %ecx	# puts

# 0 "" 2
# libcero/blob.h:175: 	ASM(
#NO_APP
	pushl	$6	#
	movl	%edi, %eax	# tmp146, ret
	popl	%edx	# tmp125
#APP
# 175 "libcero/blob.h" 1
		int $0x80

# 0 "" 2
#NO_APP
	movl	%edi, %eax	# tmp146, ret
	movl	%esi, %ecx	# stack, stack
	movl	%edi, %edx	# ret, ret
#APP
# 175 "libcero/blob.h" 1
		int $0x80

# 0 "" 2
# libcero/blob.h:242: 	return (const void*)syscall3(__NR_write, fd, (native)buf, count);
#NO_APP
	jmp	.L2	#
.L5:
# envstr.c:47: 	puts_inline("success");
#APP
# 47 "envstr.c" 1
	call inline46
	.ascii "success\n"
	inline46: pop %ecx	# puts

# 0 "" 2
# libcero/blob.h:175: 	ASM(
#NO_APP
	pushl	$4	#
	popl	%edi	# tmp132
	movl	%edi, %eax	# tmp132, ret
	pushl	$1	#
	popl	%ebx	# tmp133
	pushl	$8	#
	popl	%edx	# tmp134
#APP
# 175 "libcero/blob.h" 1
		int $0x80

# 0 "" 2
# envstr.c:45: 	size_t stacksize = 4*(stack-orig);
#NO_APP
	movl	-16(%ebp), %eax	# %sfp, ptr
# libcero/blob.h:175: 	ASM(
	movl	-16(%ebp), %ecx	# %sfp, ptr
# envstr.c:45: 	size_t stacksize = 4*(stack-orig);
	subl	%eax, %esi	# ptr, stack
# libcero/blob.h:175: 	ASM(
	movl	%edi, %eax	# tmp132, ret
# envstr.c:45: 	size_t stacksize = 4*(stack-orig);
	movl	%esi, %edx	# stack, stacksize
# libcero/blob.h:175: 	ASM(
#APP
# 175 "libcero/blob.h" 1
		int $0x80

# 0 "" 2
#NO_APP
	movl	%eax, %esi	# ret, ret
# envstr.c:51: 	puts_inline("exit");
#APP
# 51 "envstr.c" 1
	call inline62
	.ascii "exit\n"
	inline62: pop %ecx	# puts

# 0 "" 2
# libcero/blob.h:175: 	ASM(
#NO_APP
	pushl	$5	#
	movl	%edi, %eax	# tmp132, ret
	popl	%edx	# tmp143
#APP
# 175 "libcero/blob.h" 1
		int $0x80

# 0 "" 2
# libcero/blob.h:157: 	ASM(
#NO_APP
	movl	%ebx, %eax	# tmp133, ret
	movl	%esi, %ebx	# ret, ret
#APP
# 157 "libcero/blob.h" 1
		int $0x80

# 0 "" 2
#NO_APP
	.size	_start, .-_start
	.ident	"GCC: (Ubuntu 12.3.0-1ubuntu1~22.04) 12.3.0"
	.section	.note.GNU-stack,"",@progbits
