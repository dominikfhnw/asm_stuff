set -ue

time=time
time=

ARCH="-m32"
OPT="-Oz"

echo -e "\n*** GCC"
OUT1=port-gcc
$time gcc-12 -fanalyzer -pedantic -Wall -Wextra -fno-plt -U_FORTIFY_SOURCE  -Wl,-z,norelro -Wl,-z,execstack -Wl,-z,noseparate-code -Wl,--script=linkscript-static -ffreestanding -nostartfiles -nostdlib -fwhole-program $ARCH $OPT -g hello3.c -Wl,--build-id=none  -fno-asynchronous-unwind-tables -fno-stack-clash-protection -fno-stack-protector -fcf-protection=none -no-pie -fno-pie -o "$OUT1"
#$time gcc-12 -fanalyzer -pedantic -Wall -Wextra -fno-plt -U_FORTIFY_SOURCE  -Wl,-z,norelro -Wl,-z,execstack -Wl,-z,noseparate-code -nostartfiles -nostdlib -fwhole-program $ARCH $OPT hello3.c -Wl,--build-id=none  -fno-asynchronous-unwind-tables -fno-stack-clash-protection -fno-stack-protector -fcf-protection=none -no-pie -fno-pie -S -w -fverbose-asm
cp "$OUT1" "${OUT1}b"
strip -s -R .shstrtab -R '.note*' -R '.comment*' "${OUT1}b"
sstrip -z "${OUT1}b"
ls -l "${OUT1}b"
p="${OUT1}p"
dd if="${OUT1}b" bs=4096 skip=1 of="$p"
bash elfheader.asm
dd if=elfheader of="$p" conv=notrunc
chmod +x "$p"
ls -l "$p"

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


