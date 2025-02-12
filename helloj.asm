true : ; nasm -f bin -o tiny-hello.bin helloj.asm && chmod +x tiny-hello.bin; exit
	BITS	32
	ORG	0

	DB	0x7F
entry:
	inc	ebp
	dec	esp
	inc	esi
	mov	dl, 14
	mov	cl, hello
	xor	dword [ecx], 0x6C4D6549
	inc	ebx
	push	dword 0x00030002
	mov	al, 4
	int	0x80
	add	[eax], eax
	add	[eax], al
	sbb	[eax], al
	add	[eax], al
	sbb	[eax], al
	add	[eax], al
	xchg	eax, esi
	dec	ebx
	int	0x80
	DD	0x00210000-0x18
hello:	DD	0x00210001
	DB	'o, world!', 10

