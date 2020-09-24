#!/usr/bin/ruby
# -*- coding:utf-8 -*-


# ==============================================================================
# generate_zipcode_dic
# ==============================================================================

def generate_zipcode_dic
	dicfile = File.new($filename, "r")
		lines = dicfile.read.encode("UTF-8", "SJIS")
		lines = lines.split("\n")
	dicfile.close

	dicfile = File.new($dicname, "w")

	lines.length.times do |i|
		# 並びの例
		# 01101,"(カブ) ニホンケイザイシンブンシヤ サツポロシシヤ",
		# "株式会社　日本経済新聞社　札幌支社","北海道","札幌市中央区","北一条西",
		# "６丁目１−２アーバンネット札幌ビル２Ｆ","0608621","060  ","札幌中央",0,0,0

		s = lines[i].gsub('"', '')
		s = s.split(',')
		s[2] = s[2].tr('０-９ａ-ｚＡ-Ｚ（）　−','0-9a-zA-Z() \-')
		s[2] = s[2].gsub('(株)', '株式会社')
		s[2] = s[2].gsub('(社)', '社団法人')
		s[2] = s[2].gsub('(財)', '財団法人')
		s[2] = s[2].gsub(/^株式会社 /, '株式会社')
		s[2] = s[2].gsub(' 株式会社', '株式会社')
		s[2] = s[2].gsub('法人 ', '法人')
		s[2] = s[2].gsub('法人社団 ', '法人社団')
		s[6] = s[6].tr('０-９ａ-ｚＡ-Ｚ（）　−','0-9a-zA-Z() \-')
		s[6] = s[6].sub(/(\S*郵便局私書箱\S*)/, "")

		zipcode = s[7][0..2] + "-" + s[7][3..-1]
		juusho = s[3..6].join + " " + s[2]

		dicfile.puts zipcode + "	0	0	7000	" + juusho + "	ZIP_CODE"
	end

	dicfile.close
end


# ==============================================================================
# main
# ==============================================================================

`rm -f JIGYOSYO.CSV`
`wget -N http://www.post.japanpost.jp/zipcode/dl/jigyosyo/zip/jigyosyo.zip`
`unzip jigyosyo.zip`
$filename = "JIGYOSYO.CSV"
$dicname = "mozcdic-zipcode-jigyosyo.txt"

generate_zipcode_dic

`rm -f JIGYOSYO.CSV`

