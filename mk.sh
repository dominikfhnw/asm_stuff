set -v
ARCH=x86
rm -f out.M1 out.hex2 out

./bin/M2-Planet \
	--architecture ${ARCH} \
	  -f M2libc/sys/types.h \
 	  -f M2libc/stddef.h \
	-f M2libc/stdio.h \
	-f M2libc/${ARCH}/linux/bootstrap.c \
	-f M2libc/sys/utsname.h \
	-f M2libc/${ARCH}/linux/unistd.c \
	"$@" -o out.M1

M1 -f M2libc/x86/x86_defs.M1 -f M2libc/x86/libc-core.M1 -f out.M1 --little-endian --architecture x86 -o out.hex2
hex2 -f M2libc/x86/ELF-x86.hex2 -f out.hex2 --little-endian --architecture x86 --base-address 0x8048000 -o out
