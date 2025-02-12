%line 7+1 asmlib/elf.mac
[bits 32]
[extern _start]

%line 13+1 asmlib/elf.mac

%line 17+1 asmlib/elf.mac











%line 43+1 asmlib/elf.mac



%line 29+1 asmlib/elf.mac
 db 0x7F, "ELF"
 dd 1
 dd 0
 dd $$
 dw 2
 dw 3
 dd _start - 3
 dd _start - 3
 _start:
 dd 4
%line 56+1 sntp.asm
[org 0x05ffb000]


 add eax, 359 - 259
%line 364+1 asmlib/generic.mac
 mov bl, 2
%line 176+1 asmlib/generic.mac

%line 515+1 asmlib/generic.mac

%line 176+1 asmlib/generic.mac

%line 364+1 asmlib/generic.mac
 mov cl, 2
%line 176+1 asmlib/generic.mac

%line 515+1 asmlib/generic.mac

%line 176+1 asmlib/generic.mac

%line 56+1 asmlib/syscall.mac
 int 0x80
%line 49+1 asmlib/elf.mac
 times $$-$+41 nop
%line 55+1 asmlib/elf.mac
 db 169
%line 60+1 asmlib/elf.mac

 dw 0x20
 db 1


 db 0
%line 70+1 sntp.asm
db 0x68
db 130,60,204,10

db 0x68
dw 2
db 123/256, 123 % 256

xchg eax, ebx
%line 513+1 asmlib/generic.mac
 mov eax, 362


%line 176+1 asmlib/generic.mac

%line 538+1 asmlib/generic.mac




%line 543+1 asmlib/generic.mac
 mov ecx, esp
%line 274+1 asmlib/generic.mac

%line 176+1 asmlib/generic.mac

%line 364+1 asmlib/generic.mac
 mov dl, 16
%line 176+1 asmlib/generic.mac

%line 515+1 asmlib/generic.mac

%line 176+1 asmlib/generic.mac

%line 56+1 asmlib/syscall.mac
 int 0x80
%line 5+1 asmlib/generic.mac
 add esp, -44
%line 81+1 sntp.asm
push 0x9



mov ecx, esp
%line 513+1 asmlib/generic.mac
 mov eax, 369


%line 176+1 asmlib/generic.mac

%line 538+1 asmlib/generic.mac




%line 453+1 asmlib/generic.mac
 mov dl, 48
%line 515+1 asmlib/generic.mac

%line 176+1 asmlib/generic.mac

%line 56+1 asmlib/syscall.mac
 int 0x80
%line 513+1 asmlib/generic.mac
 mov eax, 371


%line 176+1 asmlib/generic.mac

%line 538+1 asmlib/generic.mac




%line 56+1 asmlib/syscall.mac
 int 0x80
%line 90+1 sntp.asm
mov eax, [ecx+40]
bswap eax

sub eax, 2_208_988_800

%line 97+1 sntp.asm
 push esi
 push eax
%line 513+1 asmlib/generic.mac
 mov eax, 264


%line 176+1 asmlib/generic.mac

%line 284+1 asmlib/generic.mac

%line 289+1 asmlib/generic.mac

%line 292+1 asmlib/generic.mac

%line 298+1 asmlib/generic.mac

%line 308+1 asmlib/generic.mac

%line 317+1 asmlib/generic.mac

%line 324+1 asmlib/generic.mac

%line 330+1 asmlib/generic.mac



%line 433+1 asmlib/generic.mac

%line 227+1 asmlib/generic.mac

%line 247+1 asmlib/generic.mac

%line 253+1 asmlib/generic.mac

%line 259+1 asmlib/generic.mac

%line 436+1 asmlib/generic.mac



%line 451+1 asmlib/generic.mac


 mov bl, 0
%line 515+1 asmlib/generic.mac

%line 176+1 asmlib/generic.mac

%line 543+1 asmlib/generic.mac
 mov ecx, esp
%line 274+1 asmlib/generic.mac

%line 176+1 asmlib/generic.mac

%line 56+1 asmlib/syscall.mac
 int 0x80
%line 103+1 sntp.asm
 inc ebx
 xchg eax, ebx
 int 0x80
%line 110+1 sntp.asm



