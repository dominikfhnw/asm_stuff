#!/bin/bash
set -eu

IN=$1
OUT=${2:-${IN}-sfx}
: ${BYTESHAVE=1}

ls -l "$IN"

printf "\x1f\x8b\x08\x08" > "$OUT"
cat <<'EOF' >> "$OUT"
zcat<$0>i 2>&-;exec /*b/ld* ./i
 2>&-
EOF
: <<'EOF'
zcat<$0>i 2>&-;chmod +x i;exec ./i
zcat<$0>i;/*b/ld* ./i
zcat<$0>i 2>&-;exec /*b/ld* ./i
cp $0 i;zcat<$0>i 2>&-;exec ./i
zcat<$0>i 2>&-;chmod +x i;exec ./i

x86_64: /*4/l*   -> /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
i386:   /*b/ld*  -> /lib/ld-linux.so.2 
x32:    /*x*/ld* -> /libx32/ld-linux-x32.so.2

zcat<$0>/tmp/i 2>&-;exec /*b/ld* /tmp/i
HOME=/tmp/i;zcat<$0>~ 2>&-;exec /*b/ld* ~
a=/tmp/i;zcat<$0>$a 2>&-;exec /*b/ld* $a

zcat<$0>/dev/shm/i 2>&-;exec /*b/ld* /dev/shm/i
HOME=/dev/shm/i;zcat<$0>~ 2>&-;exec /*b/ld* ~

for i in $(awk '{if($3=="tmpfs"&&$4!~"noexec"){print$2}}' /proc/$$/mounts);do test -w "$i" && echo "$i is writable";done

EOF
printf "\0" >> "$OUT"
if [ -n "${RELEASE-}" ]; then
	zopfli --i5000 --deflate -c "$IN" >> "$OUT"
else
	zopfli --deflate -c "$IN" >> "$OUT"
fi

if [ -n "${BYTESHAVE-}" ]; then
	cp "$OUT" "${OUT}2"
	truncate -s -1 "${OUT}2"
	if cmp -s <(zcat<"$OUT" 2>/dev/null) <(zcat<"${OUT}2" 2>/dev/null); then
		echo "byteshave"
		mv "${OUT}2" "${OUT}"
	else
		rm "${OUT}2"
	fi
fi

chmod +x "$OUT"
ls -l "$OUT"
