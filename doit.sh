#!/bin/bash

dd if=id bs=64 count=1 of=head
#dd if=/dev/zero bs=4096 count=1 of=zero
#dd if=id bs=64 count=1 of=zero
cp head head2
cp head-patched2 head3
cat extra >> head2
cat extra >> head3
truncate -s $(( 4096 + 64 )) head3
dd if=id bs=64 skip=1 of=tail
cat head2 tail > id2
chmod +x id2

cat head3 patched2 > id3
chmod +x id3


