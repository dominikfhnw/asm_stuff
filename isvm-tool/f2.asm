[bits 32]
[extern _start]
















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
[org 0x05ffb000]


 add eax, 359 - 259
 mov bl, 2



 mov cl, 2



 int 0x80
 times $$-$+41 nop
 db 169

 dw 0x20
 db 1


 db 0
db 0x68
db 130,60,204,10

db 0x68
dw 2
db 123/256, 123 % 256

xchg eax, ebx
 mov eax, 362







 mov ecx, esp


 mov dl, 16



 int 0x80
 add esp, -44
push 0x9



mov ecx, esp
 mov eax, 369







 mov dl, 48


 int 0x80
 mov eax, 371







 int 0x80
mov eax, [ecx+40]
bswap eax

sub eax, 2_208_988_800

 push esi
 push eax
 mov eax, 264























 mov bl, 0


 mov ecx, esp


 int 0x80
 inc ebx
 xchg eax, ebx
 int 0x80



