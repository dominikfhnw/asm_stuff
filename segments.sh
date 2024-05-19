#!/bin/bash
set -euo pipefail

FILE=${1-"/usr/bin/id"}
f=$(basename "$FILE")
mkdir -p "$f-segments"

declare -i i=0
loff=
llen=
while read -r name offset len perm align; do
	a2=${align#0x}
	a2=$(( 16#$a2 ))
	if [ -n "$loff" ]; then
		m=$(( loff + llen ))
		if [ $m -lt $offset ]; then
			gap=$(( offset - m ))
			#echo -ne "\t- gap: $gap ($m $offset)"
			echo -e "GAP\t- $m\t- $gap ($m $offset)"
		fi
	fi
	echo -e "$name\t- $offset\t- $len\t- $perm\t- $a2"
	dd if="$FILE" bs=1 skip=$offset count=$len of="$f-segments/$i-$name-$perm" 2>/dev/null
	(( ++i ))
	loff=$offset
	llen=$len

done < <(readelf  -Wl "$FILE" | sed -En '/^  Type/,/^$/{/^  [A-Z][A-Z]/p}' | mawk '{print $1 " " 0+$2 " " 0+$6 " " $7 $8 $9}' | sed -E 's/(.)(0x[0-9a-fA-F]+)$/\1 \2/')

