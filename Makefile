CC   = clang
CC   = gcc
LD   = ld
LD   = $(CC)
LTO  = 1
BITS = 32
SRC  = hello.c
OUT  = strip3

OBJ=$(SRC:.c=.o)
FILES=$(OBJ) -o $(OUT)

LDFLAGS0=--gc-sections --print-gc-sections -z norelro -z noseparate-code
LDFLAGS=$(LDFLAGS0) --build-id=none --orphan-handling=warn --script=o4 --print-map
LDFLAGS+=-z nodlopen -z nocopyreloc

#CFLAGS0=-ffunction-sections -fdata-sections
#CFLAGS0+=-falign-functions=1 -falign-loops=1 -fomit-frame-pointer
CFLAGS=$(CFLAGS0) -fwhole-program -fno-asynchronous-unwind-tables -ffat-lto-objects -fno-stack-clash-protection -fno-stack-protector -fcf-protection=none -fno-pie -fno-PIE -fno-pic -fno-PIC -fno-plt


ifeq ($(LTO),1)
LD = $(CC)
LEXTRA = -flto
endif

ifeq ($(LD),$(CC))
P := -Wl,--
Q := -Wl,-z,
LDFLAGS := $(subst --,$P,$(LDFLAGS))
LDFLAGS := $(subst -z ,$Q,$(LDFLAGS))
LEXTRA += -m$(BITS) -no-pie -nostartfiles
else

LIBDIR=$(shell $(CC) -m$(BITS) -print-search-dirs | sed -n '/^libraries: =/{s///;s/:/\n/g;p}' | xargs readlink -e | sort -u | sed 's/^/-L /')

DL=-dynamic-linker
ifeq ($(BITS),64)
FORMAT=elf_x86_64
DL+=/lib64/ld-linux-x86-64.so.2
else
FORMAT=elf_i386
DL+=/lib/ld-linux.so.2
endif
ifeq ($(BITS),x32)
FORMAT=elf32_x86_64
DL+=/libx32/ld-linux-x32.so.2
endif
LIBS=-lgcc -lgcc_s -lc
LEXTRA=-m$(FORMAT) $(DL) $(LIBDIR) --as-needed --hash-style=gnu

endif

ifeq ($(CC),gcc)
EXTRA=-Os
endif
ifeq ($(CC),clang)
EXTRA=-Oz
endif

compile: $(SRC)
	$(CC) $(EXTRA) $(CFLAGS) -m$(BITS) -DNOSTART -flto -c $^
	$(CC) $(EXTRA) $(CFLAGS) -m$(BITS) -DNOSTART -S -fverbose-asm $^
	$(LD) $(LEXTRA) $(LDFLAGS) $(FILES) $(LIBS) > map
	@ls -l $(OUT)

strip: compile
	@strip -R .gnu.hash -R .gnu.version -R .got -R .rel.plt -R .rel.got $(OUT) -o $(OUT)b
	@sstrip -z $(OUT)b
	@ls -l $(OUT)b
	@./$(OUT)b || echo "return $$?"

debug: hello.c
	$(CC) -g -DNOSTART -nostartfiles hello.c -o strip3 -Wl,-M > map
	@ls -l strip3

.PHONY: map
map:
	@sed -n '/^Linker script and memory map/,$${/^\./{/^[^ ]*$$/d;/0x0$$/d;p}}' map |\
	mawk '{a=a+$$3;printf "%20s %20s %5d %5d\n",$$1,$$2,$$3,$$2-l;l=$$2;}END{printf "%20s %20s %5d\n","TOTAL","",a}'
