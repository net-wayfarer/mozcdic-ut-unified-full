#!/usr/bin/ruby
# -*- coding:utf-8 -*-

require 'nkf'


# ==============================================================================
# convert_neologd_to_mozc
# ==============================================================================

def convert_neologd_to_mozc
	file = File.new("../mozc/id.def", "r")
		id = file.read.split("\n")
	file.close

	id = id.grep(/\ 名詞,固有名詞,一般,\*,\*,\*,\*/)
	id = id[0].split(" ")[0]

	# mecab-user-dict-seedを読み込む
	file = File.new($filename, "r")
		lines = file.read.split("\n")
	file.close

	l2 = []
	p = 0

	# neologdのエントリをmozcの形式に変換
	lines.length.times do |i|
		# 表層形,左文脈ID,右文脈ID,コスト,品詞1,品詞2,品詞3,品詞4,品詞5,品詞6,\
		# 原形,読み,発音
		# 電車でGO! FINAL,1288,1288,4143,名詞,固有名詞,一般,*,*,*,\
		# 電車でGO! FINAL,デンシャデゴーファイナル,デンシャデゴーファイナル
		s = lines[i].split(",")
		yomi = s[-2]
		hyouki = s[0]

		# 名詞以外は除外
		if s[4] != "名詞" ||
		# 地域名を除外。地域名は郵便番号辞書から生成する
		s[6] == "地域" ||
		# 下の名前を除外
		s[7] == "名" ||
		# 読みが2文字以下のものを除外
		yomi.length < 3 ||
		# 1文字の表記を除外
		hyouki.length < 2 ||
		# 表記が20文字を超える場合は除外
		hyouki.length > 20 ||
		# 英数字のみの表記を除外
		hyouki.length == hyouki.bytesize ||
		# 数字を2個以上含む表記を除外
		# 「712円」「第1231話」などキリがないので
		hyouki.scan(/\d/).length > 1 ||
		# 表記と原形が一致しないエントリを除外。無駄な候補が増えるので
		hyouki != s[-3] ||
		# 頻出表現をもじった表記を除外（一花カナウ いつかかなう）
		hyouki == "一花カナウ"
			next
		end

		# 表記の全角カンマを半角に変換
		hyouki = hyouki.gsub("，", ", ")
		if hyouki[-1] == " "
			hyouki = hyouki[0..-2]
		end

		hyoukitmp = hyouki.tr("・=", "")

		# 読みの文字数より表記の文字数が多いものを除外
		# （例）ミョウジョウ 明星食品株式会社
		if yomi.length < hyoukitmp.length ||
		# 読みの文字数が表記の文字数の4倍以上のものを除外
		# 多少の不具合が出るかもしれないが割り切る
		# （例）アカシショウガッコウアカイシショウガッコウ 明石小学校
		yomi.length >= hyoukitmp.length * 4
			next
		end

		# 組織のうち会社と法人を除外。数が多すぎるので
		# 茨城トヨペット （株）,1292,1292,-1811,名詞,固有名詞,組織,*,*,*,\
		# 茨城トヨペット,イバラキトヨペットカブシキガイシャ,イバラキトヨペットカブシキガイシャ
		if s[6] == "組織" && yomi.index("ガイシャ") != nil
			next
		elsif s[6] == "組織" && yomi.index("カイシャ") != nil
			next
		elsif s[6] == "組織" && hyouki.index("法人") != nil
			next
		elsif s[6] == "組織" && hyouki.index("ホールディングス") != nil
			next
		elsif s[6] == "組織" && hyouki.index("事務所") != nil
			next
		end

		# [読み,表記,id,コスト] の順に並べる
		# 計算時間を減らすためidは1つにする
		l2[p] = [yomi, hyouki, id, s[3].to_i]
		p = p + 1
	end

	lines = l2.sort
	l2 = []

	dicfile = File.new($dicname, "w")

	lines.length.times do |i|
		s1 = lines[i]
		s2 = lines[i - 1]

		# [読み..表記]が重複するエントリを除外
		if s1[0..1] == s2[0..1]
			next
		end

		# 読みのカタカナをひらがなに変換
		# 「tr('ァ-ヴ', 'ぁ-ゔ')」よりnkfのほうが速い
		yomi = NKF.nkf("--hiragana -w -W", s1[0])
		yomi = yomi.tr('ゐゑ', 'いえ')

		# コストがマイナスのものは桁を減らす
		if s1[3] < 0
			s1[3] = s1[3] / 10
		end

		# コストを6000前後に収める
		s1[3] = 6000 + (s1[3] / 10)

		# [読み,id,id,コスト,表記] の順に並べる
		t = [yomi, s1[2], s1[2], s1[3].to_s, s1[1]]
		dicfile.puts t.join("	")
	end

	dicfile.close
end


# ==============================================================================
# main
# ==============================================================================

require 'open-uri'
url = "https://github.com/neologd/mecab-ipadic-neologd/tree/master/seed"
neologdver = URI.open(url).read.split("mecab-user-dict-seed.")[1]
neologdver = neologdver.split(".csv.xz")[0]

`rm -f mecab-user-dict-seed.#{neologdver}.csv`
`wget -nc https://github.com/neologd/mecab-ipadic-neologd/raw/master/seed/mecab-user-dict-seed.#{neologdver}.csv.xz`
`7z x -aos mecab-user-dict-seed.#{neologdver}.csv.xz`
$filename = "mecab-user-dict-seed.#{neologdver}.csv"
$dicname = "mozcdic-neologd.txt"

convert_neologd_to_mozc

