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
printf "\0" >> "$OUT"
#zopfli --i1000 --deflate -c "$IN" >> "$OUT"
zopfli --deflate -c "$IN" >> "$OUT"
#truncate -s -1 "$OUT"
chmod +x "$OUT"
ls -l "$OUT"
