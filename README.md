# Mozc UT Dictionary

20200924

## Overview

Mozc UT Dictionary is an additional dictionary for Mozc. It will add over 1,000,000 entries to Mozc.
I used them for this dictionary.

File | License | Note
-- | -- | --
alt-cannadic | [GPL-2.0](https://ja.osdn.net/projects/alt-cannadic/wiki/FrontPage) | Disabled.
edict | [CC-BY-SA 3.0](http://www.edrdg.org/jmdict/edict.html) | Disabled.
jawiki-articles | [CC-BY-SA 3.0](https://ja.wikipedia.org/wiki/Wikipedia:ウィキペディアを二次利用する) | A dictionary generated from Japanese Wikipedia.
jinmei-ut | [Apache-2.0](http://linuxplayers.g1.xrea.com/mozc-ut.html) | Japanese names.
neologd | [Apache-2.0](https://github.com/neologd/mecab-ipadic-neologd) | 
nicoime | [unknown](http://tkido.com/blog/1019.html) | Disabled.
skk | [GPL-2.0-or-later](http://openlab.ring.gr.jp/skk/wiki/wiki.cgi?page=SKK%BC%AD%BD%F1) | Disabled.
zipcode | [public domain](http://www.post.japanpost.jp/zipcode/dl/readme.html) | 
jawiki-all-titles | [CC-BY-SA 3.0](https://ja.wikipedia.org/wiki/Wikipedia:ウィキペディアを二次利用する) | For cost adjustments.
mozc | [BSD-3-Clause](https://github.com/google/mozc) | For checking duplicates.
*.rb, *.sh | [Apache-2.0](http://linuxplayers.g1.xrea.com/mozc-ut.html) | Codes to generate dictionaries.

## Download

https://osdn.net/users/utuhiro/pf/utuhiro/files/

## Install

Download original Mozc.

```
wget -nc ftp.jp.debian.org/debian/pool/main/m/mozc/mozc_2.23.2815.102+dfsg.orig.tar.xz
tar xf mozc_2.23.2815.102+dfsg.orig.tar.xz
```

Add Mozc UT Dictionary to Mozc.

```
cat mozcdic-ut-20200924.1/mozcdic-*-20200924.1.txt >> mozc-2.23.2815.102+dfsg/src/data/dictionary_oss/dictionary00.txt
```

Build Mozc as usual.

## Install (Arch Linux)

Get "mozcdic-ut-20200924.1.PKGBUILD" from [OSDN](https://osdn.net/users/utuhiro/pf/utuhiro/files/) and run it.

```
makepkg -i -p mozcdic-ut-20200924.1.PKGBUILD
```

## Option: Rebuild Mozc UT Dictionary

Mozc UT Dictionary is so big. You can disable some dictionaries to reduce the size and simplify the license.

```
tar xf mozcdic-ut-20200924.1.tar.bz2
mv mozcdic-ut-20200924.1 mozcdic-ut-dev
cd mozcdic-ut-dev/src/
mousepad make-dictionaries.sh 
```

Comment out unnecessary dictionaries.
If you want to use only neologd and zipcode dictionaries, edit the lines like this.

```
#altcannadic="true"
#edict="true"
#ekimei="true"
#jawikiarticles="true"
#jinmeiut="true"
neologd="true"
#nicoime="true"
#skk="true"
```

Run `make-dictionaries.sh`. It generates new "mozcdic-ut-20200924.1".
NOTE: If you enable "jawikiarticles", `make-dictionaries.sh` downloads "jawiki-latest-pages-articles.xml.bz2" (over 3.0GB).

```
cd ../src/
gem install bzip2-ffi
sh make-dictionaries.sh
ls ../../mozcdic-ut-20200924.1/
```

## Mozc UT NEologd Dictionary

It includes only neologd and zipcode dictionaries, so the license is [Apache-2.0](https://github.com/neologd/mecab-ipadic-neologd).
mozcdic-ut-neologd-20200924.1.tar.bz2
https://osdn.net/users/utuhiro/pf/utuhiro/files/

## 更新の概要

2010-11-03: Mozc UT辞書をリリース。

2016-01-14: Mozc NEologd UT辞書をリリース。コストは mecab-ipadic-NEologd のものをベースにした。

2016-10-13: Mozc UT2辞書をリリース。Mozc UT辞書を入れたパーティションを壊してしまったので作り直した。

2016-10-20: Mozc UT2辞書のコストをウィキペディア日本語版全記事（jawiki-latest-pages-articles）でのヒット数から算出するようにした。例えば「生物学」のコストを得る場合、「生物学」を全文検索してヒット数が1ならコストは6000、ヒット数が2ならコストは6000-(100*2)、ヒット数が0ならコストは8000、のようにする（数字はダミー）。全記事の検索には長い時間と高い負荷がかかった。

2020-01-15: Mozc NEologd UT辞書を公式Mozcパッケージにマージした形で配布するのをやめた。公式Mozcにはパッチがいくつか必要になっているので、辞書も追加ファイルの1つにするほうが扱いやすいと判断した。

2020-02-06: Mozc NEologd UT辞書のコストを、ウィキペディア日本語版全見出し（jawiki-latest-all-titles）での前方一致検索で得たヒット数をベースにしたものに変更した。これで「三浦大知」が「三浦大地」より優先されるようになった。全見出しの前方一致検索は、全記事の検索と違って短時間で処理が終わる。

2020-06-11: 2代目Mozc UT辞書をリリース。Mozc UT2辞書とMozc NEologd UT辞書をまとめた形だが、辞書作成用のコードはほとんど書き直した。UT2辞書に相当する部分は全記事の検索をやめて、NEologd辞書と同じように全見出しの前方一致検索で得たコストをベースにした。辞書の組み合わせを変えて配布するときは、「mozcdic-utからの派生」という意味でファイル名を「mozcdic-ut-*」とした。

2020-06-22: jawiki-articles辞書を追加。全見出しを表記とし、対応する記事から読みを得て、辞書を作成した。コストは全見出しの前方一致検索で得たヒット数をベースにした。jawiki-articles辞書はユーザー自身でアップデートでき、新しい人名や用語への対応が容易。1人の努力に頼り切らない仕組みが必要だと考えた。

[HOME](http://linuxplayers.g1.xrea.com/index.html)

