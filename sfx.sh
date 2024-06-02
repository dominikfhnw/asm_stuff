#!/bin/bash
set -eu

IN=$1
OUT=${2:-${IN}-sfx}

ls -l "$IN"

printf "\x1f\x8b\x08\x08" > "$OUT"
cat <<'EOF' >> "$OUT"
 2>&-
zcat<$0>i 2>&-;exec /*b/ld* ./i
EOF
: <<'EOF'
zcat<$0>i 2>&-;exec /*b/ld* ./i
zcat<$0>/tmp/i 2>&-;exec /*b/ld* /tmp/i
HOME=/tmp/i;zcat<$0>~ 2>&-;exec /*b/ld* ~
zcat<$0>/dev/shm/i 2>&-;exec /*b/ld* /dev/shm/i
HOME=/dev/shm/i;zcat<$0>~ 2>&-;exec /*b/ld* ~

EOF
printf "\0" >> "$OUT"
if [ -n "${RELEASE-}" ]; then
	zopfli --i5000 --deflate -c "$IN" >> "$OUT"
else
	zopfli --deflate -c "$IN" >> "$OUT"
fi
cp "$OUT" "${OUT}2"
truncate -s -1 "${OUT}2"
if cmp -s <(zcat<"$OUT" 2>/dev/null) <(zcat<"${OUT}2" 2>/dev/null); then
	echo "byteshave"
	mv "${OUT}2" "${OUT}"
else
	rm "${OUT}2"
fi
chmod +x "$OUT"
ls -l "$OUT"
