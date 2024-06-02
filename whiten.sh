#!/bin/bash
set -ue

# TODO: actually round up, do not assume <4096
w2(){
	printf "\0\x10\0\0" | dd of="$OUT" bs=1 seek=$1 count=${2-1} conv=notrunc status=none
}

w(){
	dd if=/dev/zero of="$OUT" bs=1 seek=$1 count=${2-1} conv=notrunc status=none
}

FILE=$1
OUT=${2-${FILE}-white}
cp "$FILE" "$OUT"

w 40 2 # header1
w 46 2 # header2

w 64 4 # paddr
w2 68 4 # filesz
w2 72 4 # memsz
w 80 4 # align

w  $((64+32*0)) 4 # paddr
w2 $((68+32*0)) 4 # filesz
w2 $((72+32*0)) 4 # memsz
w  $((80+32*0)) 4 # align

w  $((64+32*1)) 4 # paddr2
w2 $((68+32*1)) 4 # filesz2
w2 $((72+32*1)) 4 # memsz2
w  $((80+32*1)) 4 # align2

if [ "${INTERP-}" -gt 0 ]; then
w  $((64+32*2)) 4 # paddr3
#w2 $((68+32*2)) 4 # filesz3
w  $((72+32*2)) 4 # memsz3
w  $((76+32*2)) 4 # flags3
w  $((80+32*2)) 4 # align3
fi

#diffo "$FILE" "$OUT" readelf -lh
