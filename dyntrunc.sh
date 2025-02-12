set -eu
IN=$1
OUT=$2
working=0
trap '' SEGV
trap '' TRAP

for i in $(seq 0 50); do
	#echo -n "$i "
	cp "$IN" "$OUT"
	truncate -s "-$i" "$OUT"
	if /lib/ld* ./"$OUT" >/dev/null 2>&1; then
		working=$i
	else
		ret=$?
		if [ "$ret" = 133 ]; then
			working=$i
		fi
		#echo "ret $ret"
	fi
done
set -x
echo "END $working"
cp "$IN" "$OUT"
truncate -s "-$working" "$OUT"
