	.text
	.file	"envstr.c"
	.section	.text.start,"ax",@progbits
	.globl	_start                          # -- Begin function _start
	.type	_start,@function
_start:                                 # @_start
# %bb.0:
	subl	$12, %esp
	#APP
	movl	%esp, %ebp

	#NO_APP
	#APP
	popl	8(%esp)

	#NO_APP
	#APP
	movl	%esp, 4(%esp)

	#NO_APP
	movl	4(%esp), %ecx
	calll	fakemain
.Lfunc_end0:
	.size	_start, .Lfunc_end0-_start
                                        # -- End function
	.text
	.type	fakemain,@function              # -- Begin function fakemain
fakemain:                               # @fakemain
# %bb.0:
	pushl	%ebp
	pushl	%ebx
	pushl	%edi
	pushl	%esi
	movl	(%ecx), %edi
	#APP
	calll	inline0
	.ascii	"start...\n"
inline0:
	popl	%ecx

	#NO_APP
	pushl	$4
	popl	%esi
	xorl	%ebx, %ebx
	incl	%ebx
	pushl	$9
	popl	%edx
	movl	%esi, %eax
	#APP
	int	$128

	#NO_APP
	#APP
	calll	inline1
	.ascii	"ffffff\n"
inline1:
	popl	%ecx

	#NO_APP
	pushl	$7
	popl	%edx
	movl	%esi, %eax
	#APP
	int	$128

	#NO_APP
	movl	%esi, %ebp
	xorl	%ebx, %ebx
	incl	%ebx
.LBB1_1:                                # =>This Inner Loop Header: Depth=1
	cmpl	$0, -4(%edi,%ebp)
	je	.LBB1_3
# %bb.2:                                #   in Loop: Header=BB1_1 Depth=1
	#APP
	calll	inline2
	.ascii	"stack\n"
inline2:
	popl	%ecx

	#NO_APP
	pushl	$6
	popl	%edx
	movl	%esi, %eax
	#APP
	int	$128

	#NO_APP
	leal	(%edi,%ebp), %ecx
	movl	%esi, %edx
	movl	%esi, %eax
	#APP
	int	$128

	#NO_APP
	addl	$4, %ebp
	jmp	.LBB1_1
.LBB1_3:
	#APP
	calll	inline3
	.ascii	"success\n"
inline3:
	popl	%ecx

	#NO_APP
	pushl	$8
	popl	%edx
	xorl	%esi, %esi
	incl	%esi
	movl	%esi, %ebx
	pushl	$4
	popl	%eax
	#APP
	int	$128

	#NO_APP
	movl	%edi, %ecx
	movl	%ebp, %edx
	pushl	$4
	popl	%ebp
	movl	%ebp, %eax
	#APP
	int	$128

	#NO_APP
	movl	%eax, %edi
	#APP
	calll	inline4
	.ascii	"exit\n"
inline4:
	popl	%ecx

	#NO_APP
	pushl	$5
	popl	%edx
	movl	%ebp, %eax
	#APP
	int	$128

	#NO_APP
	movl	%edi, %ebx
	movl	%esi, %eax
	#APP
	int	$128

	#NO_APP
.Lfunc_end1:
	.size	fakemain, .Lfunc_end1-fakemain
                                        # -- End function
	.ident	"Ubuntu clang version 14.0.0-1ubuntu1.1"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym _start
