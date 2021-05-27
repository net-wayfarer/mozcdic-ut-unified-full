#!/bin/bash

UTDICDATE="20210524"
REVISION="1"

altcannadic="true"
edict="true"
jawikiarticles="true"
jinmeiut="true"
neologd="true"
nicoime="true"
skk="true"
sudachidict="true"


# ==============================================================================
# Make each dictionary
# ==============================================================================

rm -f mozcdic-ut.txt
rm -f ../mozcdic-ut-*.txt
rm ../*/*.zip
rm ../*/*.gz

cd ../mozc/
sh get-official-mozc.sh

if [[ $altcannadic = "true" ]]; then
cd ../alt-cannadic/
ruby modify-cannadic.rb
cat mozcdic-altcanna-jinmei.txt >> ../src/mozcdic-ut.txt
cat mozcdic-altcanna.txt >> ../src/mozcdic-ut.txt
fi

if [[ $edict = "true" ]]; then
cd ../edict/
ruby modify-edict2.rb
cat mozcdic-edict2.txt >> ../src/mozcdic-ut.txt
fi

cd ../jawiki-all-titles/
ruby count-jawiki-titles.rb

if [[ $jawikiarticles = "true" ]]; then
cd ../jawiki-articles/
ruby convert-jawiki-ut-to-mozc.rb
ruby ../src/filter-entries.rb mozcdic-jawiki.txt
cat mozcdic-jawiki.txt >> ../src/mozcdic-ut.txt
fi

if [[ $jinmeiut = "true" ]]; then
cd ../jinmei-ut/
ruby modify-jinmei-ut.rb
cat mozcdic-jinmei-ut.txt >> ../src/mozcdic-ut.txt
fi

if [[ $neologd = "true" ]]; then
cd ../neologd/
ruby convert-neologd-to-mozc.rb
ruby ../src/filter-entries.rb mozcdic-neologd.txt
cat mozcdic-neologd.txt >> ../src/mozcdic-ut.txt
fi

if [[ $nicoime = "true" ]]; then
cd ../nicoime/
ruby modify-nicoime.rb
cat mozcdic-nicoime.txt >> ../src/mozcdic-ut.txt
fi

if [[ $skk = "true" ]]; then
cd ../skk/
ruby modify-skkdic.rb
cat mozcdic-skkdic.txt >> ../src/mozcdic-ut.txt
fi

if [[ $sudachidict = "true" ]]; then
cd ../sudachidict/
ruby convert-sudachiduct-to-mozc.rb
ruby ../src/filter-entries.rb mozcdic-sudachidict-*.txt
cat mozcdic-sudachidict-*.txt >> ../src/mozcdic-ut.txt
fi

cd ../zipcode/
ruby fix-ken_all.rb
ruby generate-chimei.rb
cat mozcdic-chimei.txt >> ../src/mozcdic-ut.txt

cd ../src/


# ==============================================================================
# Extract new entries and apply jawiki costs
# ==============================================================================

ruby extract-new-entries.rb mozcdic-ut.txt
ruby apply-jawiki-costs.rb mozcdic-ut.txt.extracted

rm -f ../mozcdic*-ut-*.txt
mv mozcdic-ut.txt.extracted ../mozcdic-ut-$UTDICDATE.$REVISION.txt


# ==============================================================================
# Make a mozcdic-ut package
# ==============================================================================

cd ../../
rm -rf mozcdic-ut-$UTDICDATE.$REVISION
rsync -av mozcdic-ut-dev/* mozcdic-ut-$UTDICDATE.$REVISION --exclude=id.def \
--exclude=jawiki-latest* --exclude=jawiki-ut.txt --exclude=KEN_ALL.* --exclude=*.csv \
--exclude=*.xml --exclude=*.gz --exclude=*.bz2 --exclude=*.xz --exclude=*.zip
rm -f mozcdic-ut-$UTDICDATE.$REVISION/*/mozcdic*.txt*

