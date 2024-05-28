CC   = clang
CC   = gcc
LD   = $(CC)
LD   = ld
LTO  = 0
BITS = 32
SRC  = hello.c
OUT  = Xstrip3
INTERP = 0
PROG = NOSTACK DYN NOSTART

### end user config

PROG := $(patsubst %,-D%,$(PROG))
OBJ=$(SRC:.c=.o)
FILES=$(OBJ) -o $(OUT)p

ifeq ($(LTO),1)
LD = $(CC)
LEXTRA = -flto
endif

ifeq ($(INTERP),0)
LD=ld
SCRIPT=nointerp
else
SCRIPT=o4
endif

LDFLAGS0=--gc-sections --print-gc-sections -z norelro -z noseparate-code
LDFLAGS=$(LDFLAGS0) --build-id=none --orphan-handling=warn --script=$(SCRIPT) --print-map
LDFLAGS+=-z nocopyreloc -V

#CFLAGS0=-ffunction-sections -fdata-sections
#CFLAGS0+=-falign-functions=1 -falign-loops=1 -fomit-frame-pointer
#CFLAGS0+=-ffast-math -fno-exceptions -fomit-frame-pointer -funsafe-math-optimizations -fvisibility=hidden -march=pentium4
CFLAGS=$(CFLAGS0) -fno-asynchronous-unwind-tables -fno-stack-clash-protection -fno-stack-protector -fcf-protection=none -fno-pie -fno-PIE -fno-pic -fno-PIC -fno-plt
WARNINGS=-Wpedantic -Wall -Wextra -Wno-old-style-declaration

ifeq ($(LD),$(CC))
P := -Wl,--
Q := -Wl,-z,
LDFLAGS := $(subst --,$P,$(LDFLAGS))
LDFLAGS := $(subst -z ,$Q,$(LDFLAGS))
LEXTRA += -m$(BITS) -no-pie -nostartfiles
else

LIBDIR=$(shell $(CC) -m$(BITS) -print-search-dirs | sed -n '/^libraries: =/{s///;s/:/\n/g;p}' | xargs readlink -e | sort -u | sed 's/^/-L /')

ifeq ($(BITS),64)
FORMAT=elf_x86_64
DL=/lib64/ld-linux-x86-64.so.2
STACK=3
else
FORMAT=elf_i386
DL=/lib/ld-linux.so.2
STACK=2
endif
ifeq ($(BITS),x32)
FORMAT=elf32_x86_64
DL=/libx32/ld-linux-x32.so.2
STACK=3
endif
LIBS=-lgcc -lgcc_s -lc
LEXTRA=-m$(FORMAT) $(DL) $(LIBDIR) --as-needed --hash-style=sysv

ifeq ($(INTERP),0)
LOAD:=$(DL)
DL=
else
DL:=--dynamic-linker $(DL)
endif

endif

ifeq ($(CC),gcc)
EXTRA=-Os -flto -fwhole-program -ffat-lto-objects -mpreferred-stack-boundary=$(STACK)
endif
ifeq ($(CC),clang)
EXTRA=-Oz -Wunknown-warning-option
endif

REC = rec
COMPILE=$(CC) $(EXTRA) $(CFLAGS) -m$(BITS) $(PROG) $^

compile: $(SRC)
	$(COMPILE) $(WARNINGS) -c
	@$(COMPILE) -fno-lto -fverbose-asm -S
	$(LD) $(LEXTRA) $(LDFLAGS) $(FILES) $(LIBS) > map
	elftoc -e $(OUT)p > $(REC).c
	@echo '#include "whiten.h"\n#include <stdio.h>\nint main(void) { fwrite(&foo, 1, offsetof(elf, _end), stdout);return(0); }' >> $(REC).c
	#sed -E 's/libc\.so\.6[^"]+"/libm.so"/;s/R_386_GLOB_DAT/R_386_32/g;/ DT_(DEBUG|HASH|STRSZ|ADDRNUM|VER.*|REL.*),/d' $(REC).c > $(REC)2.c
	sed -E 's/libc\.so\.6[^"]+"/libm.so"/;s/R_386_GLOB_DAT/R_386_32/g;/ DT_(DEBUG|HASH|STRSZ|ADDRNUM|VER.*),/d' $(REC).c > $(REC)2.c
	sed -i '3a #include "whiten.h"\n' $(REC)2.c
	@$(CC) $(REC)2.c -o dorec
	@./dorec > $(OUT) ||:
	@#ls -l $(OUT)

strip: compile dostrip

dostrip:
	@strip -R .hash -R .gnu.hash -R .gnu.version -R .gnu.version_r -R .got -R .got.plt -R .rel.plt -R .rel.got $(OUT) -o $(OUT)b
	@#cp $(OUT) $(OUT)b
	@sstrip -z $(OUT)b
	@ls -l $(OUT) $(OUT)b
	$(LOAD) ./$(OUT)b || echo "return $$?"
	bash ./sfx.sh $(OUT)b

debug: hello.c
	$(CC) -g -DNOSTART -nostartfiles hello.c -o strip3 -Wl,-M > map
	@ls -l strip3

.PHONY: map
map:
	@sed -n '/^Linker script and memory map/,$${/^\./{/^[^ ]*$$/d;/0x0$$/d;p}}' map |\
	mawk '{a=a+$$3;printf "%20s %20s %5d %5d\n",$$1,$$2,$$3,$$2-l;l=$$2;}END{printf "%20s %20s %5d\n","TOTAL","",a}'
