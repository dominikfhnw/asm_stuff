set -ue

echo -e "\n*** GCC"
OUT1=port-gcc
time gcc-12 -fanalyzer -pedantic -Wall -Wextra -fno-plt -U_FORTIFY_SOURCE  -Wl,-z,norelro -Wl,-z,noseparate-code -nostdinc -nostartfiles -nostdlib -ffreestanding -fwhole-program -e main -m32 -Oz -g hello3.c -Wl,--build-id=none  -fno-asynchronous-unwind-tables -fno-stack-clash-protection -fno-stack-protector -fcf-protection=none -no-pie -fno-pie -o "$OUT1"
cp "$OUT1" "${OUT1}b"
sstrip -z "${OUT1}b"
ls -l "${OUT1}b"

echo -e "\n*** M2-Planet"
OUT2=out
time m2cc hello3.c
ls -l "$OUT2"

echo -e "\n*** Clang"
OUT3=port-clang
#time clang -fno-plt -U_FORTIFY_SOURCE  -Wl,-z,norelro -Wl,-z,noseparate-code -nostartfiles -e main -m32 -Oz -gdwarf-4 hello3.c -Wl,--build-id=none  -fno-asynchronous-unwind-tables -fno-stack-clash-protection -fno-stack-protector -fcf-protection=none -no-pie -fno-pie -o "$OUT3"
time clang -Wall -Wextra -pedantic -fno-plt -U_FORTIFY_SOURCE  -Wl,-z,norelro -Wl,-z,noseparate-code -nostartfiles -nostdlib -m32 -Oz -gdwarf-4 hello3.c -Wl,--build-id=none  -fno-asynchronous-unwind-tables -fno-stack-clash-protection -fno-stack-protector -fcf-protection=none -no-pie -fno-pie -o "$OUT3"
cp "$OUT3" "${OUT3}b"
sstrip -z "${OUT3}b"
ls -l "${OUT3}b"

echo -e "\n*** mesCC"
OUT4=port-mes
time mescc hello3.c -o "$OUT4"
ls -l "$OUT4"

echo -e "\n*** tcc"
OUT5=port-tcc
time tcc -Wunsupported -Wwrite-strings -Wall -g hello3.c -o "$OUT5"
ls -l "$OUT5"


