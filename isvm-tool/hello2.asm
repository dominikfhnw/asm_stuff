%if 0

OUT=print
set -e
nasm -I asmlib/ -f bin -o $OUT $0 "$@" 2>&1 | grep -vF ': ... from macro '
ls -l $OUT
chmod +x $OUT

OFF=$(  readelf -lW $OUT 2>/dev/null | awk '$2=="0x000000"{print $3}')
START=$(readelf -hW $OUT 2>/dev/null | awk '$1=="Entry"{print $4}')
objdump -Mintel -b binary -m i386 -D $OUT --adjust-vma=$OFF --start-address=$START

set +e
./$OUT
echo ret $?
exit
%endif


%define MSG `hello, world\n`
%strlen LEN MSG
%define REG_OPT 1
;%define ELF_OFFSET 2

%include "stdlib.mac"
ELF

BASE 0x05439000
rinit
rset	eax, 4
rset	ebx, 1

set	edx, LEN

ELF_PHDR 1

printstr MSG
exitafterputs
