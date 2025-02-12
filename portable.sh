set -ue

time=time
time=

ARCH="-m32"
OPT="-Oz"

echo -e "\n*** GCC"
OUT1=port-gcc

model=tiny
offset=$(wc -c < header/"$model")
segment=$(readelf2 -Wl header/"$model" 2>/dev/null |sed -n '/.*LOAD  *[^ ]*  */{s///;s/ .*//p}')
maxtext=
maxdata=
case $model in
teensy)
	maxtext=10
	maxdata=0
	offset="0x20"
	;;
tiny)
	maxdata=0
	;;
rwx)
	;;
*)
	echo "unknown model";exit 1;;
esac
linkscript=$(mktemp)
readonly linkscript
sed \
	-e 's/@OFFSET@/'"$offset"'/' \
	-e 's/@SEGMENT@/'"$segment"'/' \
	ld/linkscript-static > "$linkscript"

LDFLAGS="-Wl,--undefined=main -Wl,--gc-sections -Wl,--print-gc-sections -Wl,-Map=map -Wl,-z,norelro -Wl,-z,execstack -Wl,-z,noseparate-code -Wl,--script=$linkscript -Wl,--build-id=none"
CFLAGS="-fno-asynchronous-unwind-tables -fno-stack-clash-protection -fno-stack-protector -fcf-protection=none -no-pie -fno-pie -fno-plt" 
WARN="-fanalyzer -pedantic -Wall -Wextra -Wno-old-style-declaration"
BLAH="-DCERO -U_FORTIFY_SOURCE -ffreestanding -nostartfiles -nostdlib -fwhole-program"
gcc-12 -w $LDFLAGS $CFLAGS $BLAH $ARCH $OPT hello4.c -fverbose-asm -S
$time gcc-12 $WARN $LDFLAGS $CFLAGS $BLAH $ARCH $OPT -g hello3.c -o "$OUT1"

textsize=$(( $(sed -n "/^\.text  *[^ ]* */{s///p}" map) ))
datasize=$(( $(sed -n "/^\.data  *[^ ]* */{s///p}" map) ))
cp "$OUT1" "${OUT1}b"
strip -s -R .shstrtab -R '.note*' -R '.comment*' "${OUT1}b"
sstrip -z "${OUT1}b"
ls -l "${OUT1}b"
p="${OUT1}p"
set -x
dd if="${OUT1}b" bs=4096 skip=1 of="$p" status=none
echo ".text $textsize"
if [ -n "$maxdata" ] && [[ $datasize -gt $maxdata ]]; then
	echo "data too big/not writable for model ($datasize > $maxdata)"
	exit 12
fi
if [ -n "$maxtext" ] && [[ $textsize -gt $maxtext ]]; then
	echo "text too big for model ($textsize > $maxtext)"
	exit 12
fi
#bash elfheader.asm
if [ "$model" = "teensy" ]; then
	dd if=header/"$model" bs=32 count=1 of="$p" conv=notrunc status=none
	dd if=header/"$model" bs=1 count=3 seek=42 skip=42 of="$p" conv=notrunc status=none
else
	dd if=header/"$model" of="$p" conv=notrunc status=none
fi
chmod +x "$p"
ls -l "$p"

#exit
[ -n "${1-}" ] && exit

echo -e "\n*** M2-Planet"
OUT2=out
$time ./m2cc hello3.c && \
ls -l "$OUT2"

echo -e "\n*** Clang"
OUT3=port-clang
#time clang -fno-plt -U_FORTIFY_SOURCE  -Wl,-z,norelro -Wl,-z,noseparate-code -nostartfiles -e main -m32 -Oz -gdwarf-4 hello3.c -Wl,--build-id=none  -fno-asynchronous-unwind-tables -fno-stack-clash-protection -fno-stack-protector -fcf-protection=none -no-pie -fno-pie -o "$OUT3"
$time clang -Wall -Wextra -pedantic -Wno-unused -fno-plt -U_FORTIFY_SOURCE  -Wl,-z,norelro -Wl,-z,execstack -Wl,-z,noseparate-code -nostartfiles -nostdlib $ARCH $OPT -gdwarf-4 hello3.c -Wl,--build-id=none  -fno-asynchronous-unwind-tables -fno-stack-clash-protection -fno-stack-protector -fcf-protection=none -no-pie -fno-pie -o "$OUT3"
cp "$OUT3" "${OUT3}b"
strip -s -R .shstrtab -R '.note*' -R '.comment*' "${OUT3}b"
sstrip -z "${OUT3}b"
ls -l "${OUT3}b"

#exit 

echo -e "\n*** mesCC"
OUT4=port-mes
$time mescc hello3.c -o "$OUT4"
ls -l "$OUT4"

echo -e "\n*** tcc"
OUT5=port-tcc
$time tcc -Wunsupported -Wwrite-strings -Wall -g hello3.c -o "$OUT5"
ls -l "$OUT5"


