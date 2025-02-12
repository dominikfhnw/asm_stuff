%if 0

OUT=dns
set -e
set -o pipefail
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
		ld -m elf_i386 -z noseparate-code $OUT.o -o $OUT
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
	objdump --visualize-jumps=color -d $OUT.full
else
	OFF=$(  readelf -lW $OUT 2>/dev/null | awk '$2=="0x000000"{print $3}')
	START=$(readelf -hW $OUT 2>/dev/null | awk '$1=="Entry"{print $4}')
	objdump --no-addresses -b binary -m i386 -D $OUT --adjust-vma="$OFF" --start-address="$START"
	#objdump --visualize-jumps=color -b binary -m i386 -D $OUT --adjust-vma="$OFF" --start-address="$START"
fi

set +e
ls -l $OUT
strace -s 64 -rni ./$OUT 127.0.0.1
echo ret $?
exit

%endif

%define PORT		53
%define TIMEOUT		1
%define SET		0
%define LOCAL		0
%define FRACTION	0
%define PARSE		0
%define PRINT		0

%ifndef IP
	%if LOCAL
		%define IP	127,0,0,1
	%else
		%define IP	1,0,0,1
	%endif
%endif

%define PAUSE		0

%define NTP_OFFSET 2_208_988_800 ; first day of unix vs NTP timestamp


%define REG_OPT		1
%define REG_SIMPLE	0
%define stack_cleanup	0

%define errarg	1
%define errval	1

%include "stdlib.mac"
;%include "hardening.mac"
ELF

rinit

%if PARSE
	%if ELF_CUSTOM
		BASE 0x3d589000
	%else
		pop	eax
	%endif

	rset	eax, -2
	pop	esi
	pop	esi
	taint	esi
	pop	ecx
	pop	ecx
	sub	ecx, esi
	taint	ecx
	push	edi
	mov	edi, esp
	taint	edi
	ELF_PHDR 1

	%if errarg
		cmp	al, 2
		jne	end1
		rset	eax, 2
	%endif
	;reg

	;zero	ebx
	;mov	ecx, edx
	;set	ebp, 10
	.l:

		lodsb
		sub 	al, '0'
		;reg

		js .sign
		imul	edx, edx, 10
		add	edx, eax
		taint	edx
		loop	.l

		.sign:
		%if errval
			cmp	esp, edi
			jne	.f
			test	edx, edx
			jz	end1	
			.f
		%endif
		xchg	eax, edx
		stosb
		taint	eax

		taint	edx
		cdq
		
	loop .l
	;taint	ebx
	rset	edx, 0
	rset	eax, -2

	;rdump
	;taint	edx
	;sub	edi, 4
	reg
	;test	eax, eax
	;mov	al, [edi-4]
	;dec	eax
	;js	end1
	;reg
	;mov	edi, [edi-4]
%else
	%if ELF_CUSTOM
	        BASE 0x05ffb000
	        add     eax, SYS_socket - 259
	        rset    eax, SYS_socket
	%endif
%endif

socket:
set	ebx, 2
mov	ecx, ebx
rset	ecx, 2
socket	AF_INET, SOCK_DGRAM, IPPROTO_IP

%if !PARSE
	ELF_PHDR 1
%endif

%define	SOCKET ebx
;reg

xchg	eax, SOCKET
rset	eax, 2
taint	ebx

%if TIMEOUT
timeout:
	alarm	SOCKET
	rset	eax, 0
%endif


connect:
connect SOCKET, 1,0,0,1, PORT
rset	eax, 0 ; OPTIMISTIC

packet:
alloca	128
mov	ecx, esp
taint	ecx

%if 1
	mov	[ecx+2], dword 0x1000001
%else
	mov	[ecx+2], byte 1
	mov	[ecx+5], byte 1
%endif


mov	esi, query
lea	edi, [ecx+12]
set	edx, 18
xchg	ecx, edx
rep	movsb
xchg	ecx, edx
taint	esi, edi

send:
send	SOCKET, ecx, 46

recv:
recv	SOCKET, ecx, 46

add	esp, 42
;push	`\10\10\10\10`
db	0x68
dw	AF_INET
db      0, 123
.2:
connect	SOCKET, esp, 16
send	SOCKET, ecx, 46

decode:

set	ebx, 0
end1:
xchg	eax, ebx
inc	eax
int	0x80

%include "regdump2.mac"

;section .data
query:
	db 4, "pool", 3, "ntp", 3, "org", 0, 0, 1, 0, 1
