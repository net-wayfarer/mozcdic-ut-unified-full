#!/usr/bin/ruby
# -*- coding:utf-8 -*-

require 'zlib'


# ==============================================================================
# count_jawiki_titles
# ==============================================================================

def count_jawiki_titles
	file = File.open($filename)
	gz = Zlib::GzipReader.new(file) 
	titles = gz.read.split("\n")
	gz.close

	titles.length.times do |i|
		# "BEST_(三浦大知のアルバム)" を
		# "三浦大知のアルバム)" に変更。
		# 「三浦大知」を前方一致検索できるようにする
		titles[i] = titles[i].split("_(")[-1]

		# 全角3文字未満の表記はヒットしすぎるのでカウントしない
		if titles[i].bytesize < 9 ||
		# 英数字のみの表記はカウントしない
		titles[i].length == titles[i].bytesize
			titles[i] = nil
		end
	end

	titles = titles.compact.sort

	dicfile = File.new($dicname, "w")

	titles.length.times do |i|
		s = titles[i]
		c = 1

		# 10文字以上の表記はヒット数を調べない。人名のコスト調整が主目的なので。
		# 「明石家さんまのユーロNO.1」のヒット数が
		# 「明石家さんまのユーロNo.1!」より大きくなると逆に不適切
		if titles[i].length > 9 ||
		# 次の表記がnilの場合は書き出して終了
		titles[i + c] == nil
			dicfile.puts "jawikititles	0	0	" + c.to_s + "	" + s
			next
		end

		# 前方一致する限りカウントし続ける
		while titles[i + c].index(s) == 0
			c = c + 1
		end

		dicfile.puts "jawikititles	0	0	" + c.to_s + "	" + s
	end

	dicfile.close
end


# ==============================================================================
# main
# ==============================================================================

`rm -f jawiki-latest-all-titles-in-ns0`
`wget -N https://dumps.wikimedia.org/jawiki/latest/jawiki-latest-all-titles-in-ns0.gz`
$filename = "jawiki-latest-all-titles-in-ns0.gz"
$dicname = "jawiki-latest-all-titles-in-ns0.counts"

count_jawiki_titles

`rm -f jawiki-latest-all-titles-in-ns0`

