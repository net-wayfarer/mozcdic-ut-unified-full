#!/usr/bin/ruby
# -*- coding:utf-8 -*-

require 'bzip2/ffi'
require 'nkf'

# Wikipediaの記事は「タイトル（読み）」が冒頭に書かれていることが多い。
# これを手がかりに表記と読みのペアを取得する。
#
# 記事の例
#    <title>生物学</title>
#    <ns>0</ns>
#    <id>57</id>
#    <revision>
#      <id>74846611</id>
#      <parentid>74844066</parentid>
#      <timestamp>2019-11-01T10:51:10Z</timestamp>
#      <contributor>
#        <ip></ip>
#      </contributor>
#      <model>wikitext</model>
#      <format>text/x-wiki</format>
#      <text bytes="39498" xml:space="preserve">{{複数の問題
#}}
#'''生物学'''（せいぶつがく、{{Lang-en-short|biology}}）とは、


def getYomiHyouki
	# ==============================================================================
	# タイトルから表記を作る
	# ==============================================================================

	# タイトルと記事を取得
	# "    <title>田中瞳 (アナウンサー)</title>"
	$article = $article.split("    <title>")[1]

	if $article == nil
		return
	end

	title = $article.split("</title>")[0]
	$article = $article.split(' xml:space="preserve">')[1]

	if $article == nil
		return
	end

	# 全角英数を半角に変換してUTF-8で出力
	# 全角文字の検索はUTF-8に変換した後でないと失敗する
	# -m0 MIME の解読を一切しない
	# -Z1 全角空白を ASCII の空白に変換
	# -W 入力に UTF-8 を仮定する
	# -w UTF-8 を出力する(BOMなし)
	hyouki = NKF.nkf("-m0Z1 -W -w", title)

	# 「 (曖昧さ回避)」を除外
	# 法皇 (曖昧さ回避)
	if  hyouki.index(" (曖昧さ回避)") != nil
		return
	end

	# 「 (」の前を表記にする
	# 田中瞳 (アナウンサー)
	hyouki = hyouki.split(' (')[0]

	# 表記にスペースがある場合は除外。スペースを除去した記事を検索するので読みを取得できない
	if hyouki.index(" ") != nil ||
	# 表記に「、」がある場合は除外。記事の「、」で読みを切るので適切な読みを取得できない
	hyouki.index("、") != nil
		return
	end

	# 読みにならない文字を除外した表記2を作る
	hyouki2 = hyouki.tr('!?=・。', '')

	# 表記2がひらがなとカタカナだけの場合は読みを表記2から作る
	# さいたまスーパーアリーナ
	if hyouki2 == hyouki2.scan(/[ぁ-ゔァ-ヴー]/).join
		# 表記2が2文字以下の場合は読みも2文字以下になるので除外
		if hyouki2.length < 3
			return
		end

		yomi = NKF.nkf("--hiragana -w -W", hyouki2)
		yomi = yomi.tr("ゐゑ", "いえ")

		$dicfile.puts yomi + "	0	0	6000	" + hyouki
		return
	end

	# 表記が25文字を超える場合は候補ウィンドウが見づらいので除外
	if hyouki.length > 25 ||
	# 表記2が1文字の場合は除外
	hyouki2.length < 2 ||
	# 表記2が英数字のみの場合は除外
	hyouki2.length == hyouki2.bytesize ||
	# 数字を3個以上含む表記2は除外
	# 「国道120号」などキリがないし、残しても読みが数字になっている（こくどう120ごう）
	hyouki2.scan(/\d/).length > 2
		return
	end

	# ==============================================================================
	# 記事を必要な部分に絞る
	# ==============================================================================

	# テンプレートを除去
	if $article[0..1] == "{{"
		# 連続したテンプレートを1つにまとめる
		$article = $article.gsub("}}\n{{", "")
		# テンプレートを除去
		$article = $article.split("}}")[1..-1].join("}}")
	end

	lines = $article.split("\n")

	# 記事を最大200行にする
	if lines.length > 200
		lines = lines[0..200]
	end

	# ==============================================================================
	# 記事から読みを作る
	# ==============================================================================

	lines.length.times do |i|
		s = lines[i]

		# 全角英数を半角に変換してUTF-8で出力
		# 全角文字の検索はUTF-8に変換した後でないと失敗する
		s = NKF.nkf("-m0Z1 -W -w", s)

		# 「(」がない行を除外。「表記(読み」を調べるので
		if s.index("(") == nil
			next
		end

		# otheruseslist, Otheruseslist を除外
		# {{otheruseslist|[[ビートルズ]]の[[楽曲]]|[[英単語]]の意味|昨日
		if s.index("theruseslist") != nil
			next
		end

		# 「<ref 」から「</ref>」までを除去
		# '''皆藤 愛子'''<ref>一部のプロフィールが</ref>(かいとう あいこ、[[1984年]]
		# '''大倉 忠義'''（おおくら ただよし<ref name="oricon"></ref>、[[1985年]]
		s1 = s.split("&lt;ref")[0]
		s2 = s.split("&lt;/ref&gt;")[1]

		if s1 != nil && s2 != nil
			s = s1 + s2
		end

		# スペースと「'"「」『』」を取る
		# '''皆藤 愛子'''(かいとう あいこ、[[1984年]]
		s = s.tr(" '\"「」『』", "")

		# 「表記(読み」を検索
		yomi = s.split(hyouki + '(')[1]

		if yomi == nil
			next
		end

		yomi = yomi.split(')')[0]

		if yomi == nil
			next
		end

		# 読みを「[[」で切る
		# ないとうときひろ[[1963年]]
		yomi = yomi.split("[[")[0]

		if yomi == nil
			next
		end

		# 読みを「、」で切る
		# かいとうあいこ、[[1984年]]
		yomi = yomi.split("、")[0]

		if yomi == nil
			next
		end

		# 読みの不要な部分を除去
		yomi = yomi.tr('!?=・。', '')

		# 読みが2文字以下の場合は除外
		if yomi.length < 3 ||
		# 読みの文字数が表記の3倍を超える場合は除外
		yomi.length > hyouki.length * 3 ||
		# 読みが全てカタカナの場合は除外
		# ミュージシャン一覧(グループ)
		yomi == yomi.scan(/[ァ-ヴー]/).join ||
		# 読みが「ー」で始まる場合は除外
		yomi[0] == "ー"
			next
		end

		# 読みのカタカナをひらがなに変換
		yomi = NKF.nkf("--hiragana -w -W", yomi)
		yomi = yomi.tr("ゐゑ", "いえ")

		# 読みにひらがな以外のものがあれば除外
		if yomi != yomi.scan(/[ぁ-ゔー]/).join
			next
		end

		$dicfile.puts yomi + "	0	0	6000	" + hyouki
		return
	end
end

# ==============================================================================
# main
# ==============================================================================

jawiki = "jawiki-latest-pages-articles.xml.bz2"
mozcdic = "jawiki-ut.txt"

`wget -nc https://dumps.wikimedia.org/jawiki/latest/#{jawiki}`

reader = Bzip2::FFI::Reader.open(jawiki)
$dicfile = File.new(mozcdic, "w")

puts "Reading..."

while articles = reader.read(500000000)
	articles = articles.split("  </page>")

	puts "Writing..."

	articles.length.times do |i|
		$article = articles[i]
		getYomiHyouki
	end

	puts "Reading..."
end

reader.close
$dicfile.close

# 重複エントリを除去
file = File.new(mozcdic, "r")
		lines = file.read.split("\n")
file.close

lines = lines.uniq.sort

file = File.new(mozcdic, "w")
		file.puts lines
file.close
