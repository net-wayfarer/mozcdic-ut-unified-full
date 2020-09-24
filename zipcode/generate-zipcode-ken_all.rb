#!/usr/bin/ruby
# -*- coding:utf-8 -*-


# ==============================================================================
# generate_zipcode_dic
# ==============================================================================

def generate_zipcode_dic
	dicfile = File.new($filename, "r")
		lines = dicfile.read.split("\n")
	dicfile.close

	dicfile = File.new($dicname, "w")

	lines.length.times do |i|
		# 並びの例
		# 401101,"064  ","0640941","ホッカイドウ","サッポロシチュウオウク","アサヒガオカ",
		# "北海道","札幌市中央区","旭ケ丘",0,0,1,0,0,0

		s = lines[i].gsub('"', '').split(",")
		zipcode = s[2][0..2] + "-" + s[2][3..-1]
		juusho = s[6..8].join

		dicfile.puts zipcode + "	0	0	7000	" + juusho + "	ZIP_CODE"
	end

	dicfile.close
end


# ==============================================================================
# main
# ==============================================================================

$filename = "KEN_ALL.CSV.fixed"
$dicname = "mozcdic-zipcode-ken_all.txt"
generate_zipcode_dic

