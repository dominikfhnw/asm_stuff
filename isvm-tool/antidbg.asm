%if 0

OUT=antidbg
set -e
#set -o pipefail
if [ -n "${FULL-}" ]; then
	set -x
	rm -f $OUT $OUT.o
	nasm -I asmlib/ -f elf32 -o $OUT.o "$0" "$@" 2>&1 | grep -vF ': ... from macro '
	#ld -m elf_i386 -z noseparate-code $OUT.o -o $OUT
	if [ -n "${HARDEN-}" ]; then
		ld -z ibt -z shstk --script link -m elf_i386 -u __stack_chk_fail -u __gets_chk -z relro -z now --build-id=none --orphan-handling=warn -z noseparate-code $OUT.o -o $OUT
		readelf -Wa $OUT
		cp $OUT $OUT.full
		ls -l $OUT.full
		cat rechead2 > s.c
		elftoc -e $OUT >> s.c
		echo -e '#include <stdio.h>\nint main(void) { fwrite(&foo, 1, offsetof(elf, _end), stdout);return(0); }' >> s.c
		#strip --strip-dwo -wK'*' -R .hash -R .gnu.hash -R .gnu.version -R .gnu.version_r -R .got -R .got.plt -R .rel.plt -R .rel.got $OUT.full
		sed -i 's/PT_NULL/PT_GNU_RELRO/' s.c
		bash ./s.c
		strace -ni ./cust 127.0.0.1 ||:
		echo
		echo "## CHECKSEC"
		checksec --file=cust ||:
		echo
		echo "## HARDENING-CHECK"
		hardening-check -c cust
	else
		FLAGS="--build-id=none --orphan-handling=warn --gc-sections --print-gc-sections" 
		ld $FLAGS -m elf_i386 -z noseparate-code $OUT.o -o $OUT
		cp $OUT $OUT.full
		ls -l $OUT.full
	fi
	sstrip -z $OUT
else
	rm -f $OUT
	#nasm -I asmlib/ -f bin -o $OUT "$0" "$@"
	nasm -I asmlib/ -f bin -o $OUT "$0" "$@" 2>&1 | grep -vF ': ... from macro '
fi
ls -l $OUT
chmod +x $OUT

if [ -n "${FULL-}" ]; then
	#objdump --visualize-jumps=color -d $OUT.full
	objdump -Mintel -d $OUT.full
else
	OFF=$(  readelf -lW $OUT 2>/dev/null | awk '$2=="0x000000"{print $3}')
	START=$(readelf -hW $OUT 2>/dev/null | awk '$1=="Entry"{print $4}')
	objdump -b binary -m i386 -D $OUT --adjust-vma="$OFF" --start-address="$START"
	#objdump --visualize-jumps=color -b binary -m i386 -D $OUT --adjust-vma="$OFF" --start-address="$START"
fi

set +e
ls -l $OUT
#strace -s 64 -rni ./$OUT 127.0.0.1
echo ret $?
exit

%endif

SECTION .data follows=.text
;SH:	db '/bin/sh', 0
;SHC:	db '-c', 0
SH_HELLO: db "echo hello world", 0

SECTION .text


; /proc/sys/kernel/modules_disabled
; /proc/sys/kernel/kexec_load_disabled
; /proc/sys/kernel/yama/ptrace_scope
; /proc/sys/kernel/kptr_restrict
; /sys/kernel/security/lockdown
; mokutil --sb-state
; /proc/kcore needs CAP_SYS_RAWIO
; Try this:
; /etc/systemd/system/sshd.service:
; [Service]
; CapabilityBoundingSet=~CAP_SYS_RAWIO


;%define ELF_OFFSET 2
;%define MSG `hello, world\n`
;%strlen LEN MSG
%define REG_OPT 1

%include "stdlib.mac"
ELFSTART:
ELF

;BASE 0x0d430000
BASE 0x3d909000
;rset	eax, 4
;rset	ebx, 1

rinit

ELF_PHDR 1
;seccomp_strict
system SH_HELLO
;antistrace

clone	0x00010000 | 0x00000800 | 0x00000100 | 0x000000,0
test	eax, eax
jz	.child
.parent:
	;set	ecx, 1
	.ll:
		jmp .ll
	;jmp	.endpc

.child:
	;getppid
	;xchg	eax, ecx
	;kill	ebx, 19
	;xor	ecx, ecx
	;xor	edx, edx
	;taint	edx, ecx
	;inline_str `echo hello world\0`
	;pop	eax
	;push `-c\0\0`
	;mov	ecx, esp
	inline_str `echo hewlllo world\0`
	pop	ecx
	push `-c\0\0`
	mov	eax, esp
	push `/sh\0`
	push `/bin`

	mov	ebx, esp
	;xor	edx, edx
	;push	edx
	;rset	edx, 0
	push	0
	;lea	eax, [ebx+8]
	;lea	ecx, [ebx+12]
	push	ecx
	push	eax
	push	ebx


	execve ebx, esp, 0
	;exit_group 0
	;ptrace  PTRACE_ATTACH, ecx, 0, 0
.endpc:
antiptrace2

pop	edi
pop	edi
blankstring edi
pop	eax

printstr `evil stuff...\n`


;printnum
push	`foo\x00`
;push	0
;taint	eax
procname esp
pop	eax
pop	eax
;undumpable


%define COPY 1
%if COPY
	mmap	0, 0x100000, 7, 34, x, 0

	mov	esi, .p1
	mov	ecx, EEE - .p1
	memcpy	eax, esi, ecx
	jmp	eax
	taint	eax
%endif

.p1:
secretstack 0x800000
push	0
push	0
push	0
printstr "haha secret stack"

.reg1: reg
;munmap	ebp, 0x1000
inline_str `antidbg\0`
.unl: unlink	pop
push	`/\0`
chdir	esp
%if COPY
	munmap	ELFSTART-0x60, 0x1000
%endif


;clone   0x800 | 0x10000 | 0x100 | 0x00008000, 0
;clone   0, 0
;test	eax,eax
;jnz	.eee
;xchg	eax, ebx
;waitpid ebx, 0, 0x40000000

pause
exit 0
.eee:
%define reg_stack 0
exit 0

reg
pause
exit

%include "regdump2.mac"
EEE:


