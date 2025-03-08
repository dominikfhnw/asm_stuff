CC   = clang
CC   = gcc-12
LD   = $(CC)
LD   = ld
LTO  = 0
BITS = 32
SRC  = hello.c
OUT  = ab
INTERP = 1
HARDEN = 1
#PROG = DD DL_DEBUG DBG_INIT HACKY NOSTACK DYN NOSTART
PROG = HACKY DYN NOSTART HARDEN

### end user config

export INTERP
#export RELEASE=1
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

ifeq ($(HARDEN),0)
LDFLAGS0=--gc-sections --print-gc-sections -z norelro -z noseparate-code
LDFLAGS=$(LDFLAGS0) --build-id=none --orphan-handling=warn --script=$(SCRIPT) --print-map
else
LDFLAGS0=--gc-sections --print-gc-sections -z noseparate-code -u __stack_chk_fail -u __gets_chk -z now -z ibt -z shstk -z relro
LDFLAGS=$(LDFLAGS0) --build-id=none --orphan-handling=warn --print-map
endif
LDFLAGS+=-z nocopyreloc -V

#CFLAGS_IPXE=-march=i386 -fomit-frame-pointer -fstrength-reduce -falign-jumps=1 -falign-loops=1 -falign-functions=1 -mpreferred-stack-boundary=2 -mregparm=3 -mrtd -freg-struct-return -m32 -fshort-wchar -Os -ffreestanding -fcommon -Wall -W -Wformat-nonliteral  -fno-dwarf2-cfi-asm -fno-exceptions  -fno-unwind-tables -fno-asynchronous-unwind-tables -Wno-address -Wno-stringop-truncation -Wno-address-of-packed-member -ffunction-sections
#CFLAGS0=-fmodulo-sched -fmerge-all-constants -fipa-pta -fgraphite-identity -floop-nest-optimize -ftree-coalesce-vars -ftree-loop-if-convert -ftree-loop-distribution -floop-interchange -fivopts -fno-align-functions -fallow-store-data-races -ffunction-sections -fdata-sections -fstdarg-opt
#CFLAGS0=-ffunction-sections -fdata-sections
#CFLAGS0+=-falign-functions=1 -falign-loops=1 -fomit-frame-pointer
#CFLAGS0+=-ffast-math -fno-exceptions -fomit-frame-pointer -funsafe-math-optimizations -fvisibility=hidden -march=pentium4
CFLAGS=$(CFLAGS0) -fwhole-program -std=gnu99 -U_FORTIFY_SOURCE -masm=intel -fno-asynchronous-unwind-tables -fno-stack-clash-protection -fno-stack-protector -fcf-protection=none -fno-PIC -fno-plt
#CFLAGS=$(CFLAGS0) -fno-builtin -masm=intel -fno-pie -fno-PIE -fno-pic -fno-PIC -fno-plt
#CFLAGS=$(CFLAGS0) -std=gnu99 -U_FORTIFY_SOURCE -fsanitize=address -fno-builtin -masm=intel -fno-pie -fno-PIE -fno-pic -fno-PIC -fno-plt
WARNINGS=-Wall -Wextra -Wno-old-style-declaration -Wno-unused-function -Wno-multichar

ifeq ($(LD),$(CC))
P := -Wl,--
Q := -Wl,-z,
LDFLAGS := $(subst --,$P,$(LDFLAGS))
LDFLAGS := $(subst -z ,$Q,$(LDFLAGS))
LEXTRA += -m$(BITS) -nostartfiles
ifeq ($(HARDEN),0)
LEXTRA += -no-pie
else
LEXTRA += -pie
endif
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
#LIBS=-lasan -lubsan -lgcc -lgcc_s -lc
LEXTRA=-m$(FORMAT) $(DL) $(LIBDIR) --as-needed --hash-style=sysv

ifeq ($(HARDEN),0)
LEXTRA += -no-pie
else
LEXTRA += -pie
endif

ifeq ($(INTERP),0)
LOAD:=$(DL)
DL=
else
DL:=--dynamic-linker $(DL)
endif

endif

MTUNE ?= i486
ifeq ($(CC),gcc-12)
EXTRA=-Oz -mtune=$(MTUNE) -mpreferred-stack-boundary=$(STACK)
endif
ifeq ($(CC),gcc)
EXTRA=-Os -mtune=$(MTUNE) -mpreferred-stack-boundary=$(STACK)
endif
ifeq ($(CC),clang)
EXTRA=-Oz -Wno-unknown-warning-option
endif

REC = rec
COMPILE=$(CC) $(EXTRA) $(CFLAGS) -m$(BITS) $(PROG) $^

compile: $(SRC)
	$(COMPILE) $(WARNINGS) -gdwarf-4 -c
	@$(COMPILE) -w -fverbose-asm -S -o $(OUT).s
	$(LD) $(LEXTRA) $(LDFLAGS) $(FILES) $(LIBS) > map
	@cat rechead2 > $(REC).c
	@elftoc -e $(OUT)p >> $(REC).c
	@echo '#include "whiten.h"\n#include <stdio.h>\nint main(void) { fwrite(&foo, 1, offsetof(elf, _end), stdout);return(0); }' >> $(REC).c
	@#sed -E 's/libc\.so\.6[^"]+"/libm.so"/;s/R_386_GLOB_DAT/R_386_32/g;/ DT_(DEBUG|HASH|STRSZ|ADDRNUM|VER.*|REL.*),/d' $(REC).c > $(REC)2.c
	@#sed -E 's/libc\.so\.6[^"]+"/libm.so"/;s/R_386_GLOB_DAT/R_386_32/g;/ DT_(HASH|STRSZ|ADDRNUM|VER.*),/d' $(REC).c > $(REC)2.c
	@#sed -E 's/R_386_GLOB_DAT/R_386_32/g;/ DT_(HASH|STRSZ|ADDRNUM|VER.*),/d' $(REC).c > $(REC)2.c
	#@sed -E 's/libc\.so\.6[^"]+"/libm.so"/;s/R_386_GLOB_DAT/R_386_32/g;/ DT_(HASH|STRSZ|ADDRNUM|VER.*),/d' $(REC).c > $(REC)2.c
	#
	#NONHARDEN		@sed -E 's/(dlsym.*)?libc\.so\.6([^"]+)?"/libm.so\\0"/;/R_386_GLOB_DAT/d; /DT_NEEDED/s/ 7 / 1 /; /dynstr/s/28/9/;/ DT_(NEEDED|HASH|STRSZ|ADDRNUM|VER.*|REL.*|DEBUG),/d; /0, 0.*STT_FUNC/d; ' $(REC).c > $(REC)2.c
	#@sed -E 's/(dlsym.*)?libc\.so\.6([^"]+)?"/libm.so\\0"/;/R_386_GLOB_DAT/d; /DT_NEEDED/s/ 7 / 1 /; /dynstr/s/28/9/;/ DT_(NEEDED|HASH|STRSZ|ADDRNUM|VER.*|REL.*),/d; ' $(REC).c > $(REC)2.c
	@sed -E 's/(dlsym.*)?libc\.so\.6/libm.so\\0\\0/;/R_386_GLOB_DAT/d; /DT_NEEDED/s/ 7 / 1 /; /dynstr/s/28/9/;/ DT_(NEEDED|HASH|STRSZ|ADDRNUM|VER.*|REL.*|TEXTREL),/d; ' $(REC).c > $(REC)2.c
	#@sed -E 's/(dlsym.*)?libc\.so\.6/libm.so/;/R_386_GLOB_DAT/d; /XDT_NEEDED/s/ 7 / 1 /; /Xdynstr/s/28/9/;' $(REC).c > $(REC)2.c
	@sed -i '3a #include "whiten.h"\n' $(REC)2.c
	@sed -i '/DT_SYMTAB/a { DT_NEEDED, { 1 } },\n' $(REC)2.c
	@$(CC) $(REC)2.c -o dorec
	@./dorec > $(OUT)
	@#ls -l $(OUT)

strip: compile dostrip

dostrip:
	@strip --strip-dwo -wK'*' -R .hash -R .gnu.hash -R .gnu.version -R .gnu.version_r -R .got -R .got.plt -R .rel.plt -R .rel.got $(OUT)
	@cp $(OUT) $(OUT)b
	@sstrip -z $(OUT)b
	@ls -l $(OUT)
	@echo
	$(LOAD) ./$(OUT)b || echo "return $$?"
	@bash ./sfx.sh $(OUT)b
	@bash ./whiten.sh $(OUT)b
	@bash ./sfx.sh $(OUT)b-white

.PHONY: map
map:
	@sed -n '/^Linker script and memory map/,$${/^\./{/^[^ ]*$$/d;/0x0$$/d;p}}' map |\
	mawk '{a=a+$$3;printf "%20s %20s %5d\n",$$1,$$2,$$3,$$2-l;l=$$2;}END{printf "%20s %20s %5d\n","TOTAL","",a}'
