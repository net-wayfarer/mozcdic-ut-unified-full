#!/bin/bash

MOZCVER="2.23.2815.102"

rm -rf mozc-$MOZCVER+dfsg/
wget -N ftp.jp.debian.org/debian/pool/main/m/mozc/mozc_$MOZCVER+dfsg.orig.tar.xz
tar xf mozc_$MOZCVER+dfsg.orig.tar.xz
cp mozc-$MOZCVER+dfsg/src/data/dictionary_oss/id.def .
cat mozc-$MOZCVER+dfsg/src/data/dictionary_oss/dictionary*.txt > mozcdic.txt
rm -rf mozc-$MOZCVER+dfsg/

