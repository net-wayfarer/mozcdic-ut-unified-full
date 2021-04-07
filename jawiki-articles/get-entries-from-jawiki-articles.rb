#!/usr/bin/ruby
# -*- coding:utf-8 -*-

require 'parallel'
require 'bzip2/ffi'
require 'nkf'

# Wikipediaの記事は「タイトル（読み）」が冒頭に書かれていることが多い。
# これを手がかりに表記と読みのペアを取得する。
#
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
	title = $article.split("</title>")[0]
	title = title.split("<title>")[1]

	$article = $article.split(' xml:space="preserve">')[1]

	if $article == nil
		return
	end

	# 全角英数を半角に変換してUTF-8で出力
	# UTF-8に変換しないと全角文字の検索時にCompatibilityErrorが出る
	# -m0 MIME の解読を一切しない
	# -Z1 全角空白を ASCII の空白に変換
	# -W 入力に UTF-8 を仮定する
	# -w UTF-8 を出力する(BOMなし)
	hyouki = NKF.nkf("-m0Z1 -W -w", title)

	# 「 (」の前を表記にする
	# 田中瞳 (アナウンサー)
	hyouki = hyouki.split(' (')[0]

	# 表記が英数字のみの場合はスキップ
	if hyouki.length == hyouki.bytesize ||
	# 表記が26文字以上の場合はスキップ。候補ウィンドウが大きくなりすぎる
	hyouki[25] != nil ||
	# 内部用のページをスキップ
	hyouki.index("(曖昧さ回避)") != nil ||
	hyouki.index("Wikipedia:") != nil ||
	hyouki.index("ファイル:") != nil ||
	hyouki.index("Portal:") != nil ||
	hyouki.index("Help:") != nil ||
	hyouki.index("Template:") != nil ||
	hyouki.index("Category:") != nil ||
	hyouki.index("プロジェクト:") != nil ||
	# 表記にスペースがある場合はスキップ
	# あとで記事のスペースを削除するので、残してもマッチしない
	# '''皆藤 愛子'''<ref>一部のプロフィールが</ref>(かいとう あいこ、[[1984年]]
	hyouki.index(" ") != nil ||
	# 表記に「、」がある場合はスキップ
	# 記事の「、」で読みを切るので、残してもマッチしない
	hyouki.index("、") != nil
		return
	end

	# 読みにならない文字を削除したhyouki_stripを作る
	hyouki_strip = hyouki.tr('!?=:・。', '')

	# hyouki_stripが1文字の場合はスキップ
	if hyouki_strip[1] == nil ||
	# hyouki_stripが英数字のみの場合はスキップ
	hyouki_strip.length == hyouki_strip.bytesize ||
	# hyouki_stripが数字を3個以上含む場合はスキップ
	# 国道120号, 3月26日
	hyouki_strip.scan(/\d/)[2] != nil
		return
	end

	# hyouki_stripがひらがなとカタカナだけの場合は、読みをhyouki_stripから作る
	# さいたまスーパーアリーナ
	if hyouki_strip == hyouki_strip.scan(/[ぁ-ゔァ-ヴー]/).join
		# hyouki_stripが2文字以下の場合は読みも2文字以下になるのでスキップ
		if hyouki_strip[2] == nil
			return
		end

		yomi = NKF.nkf("--hiragana -w -W", hyouki_strip)
		yomi = yomi.tr("ゐゑ", "いえ")

		# 他のプロセスによる書き込みをロック
		$dicfile.flock(File::LOCK_EX)
		$dicfile.puts yomi + "	0	0	6000	" + hyouki
		$dicfile.flock(File::LOCK_UN)
		return
	end

	# ==============================================================================
	# 記事を必要な部分に絞る
	# ==============================================================================

	lines = $article

	# 冒頭のテンプレート「{{ }}」を削除
	# 正規表現で削除すると、本文中に「}}」がある場合に最長一致で本文が消える
	if lines[0..1] == "{{"
		# 冒頭の連続したテンプレートを1つにまとめる
		lines = lines.gsub("}}\n{{", "")
		# 冒頭のテンプレートを削除
		lines = lines.split("}}")[1..-1].join("}}")
	end

	lines = lines.split("\n")

	# 記事を最大200行にする
	if lines[200] != nil
		lines = lines[0..199]
	end

	# ==============================================================================
	# 記事から読みを作る
	# ==============================================================================

	lines.length.times do |i|
		s = lines[i]

		# 全角英数を半角に変換してUTF-8で出力
		# UTF-8に変換しないと全角文字の検索時にCompatibilityErrorが出る
		s = NKF.nkf("-m0Z1 -W -w", s)

		# 「<ref 」から「</ref>」までを削除
		# 正規表現で削除すると、「</ref>」が2個以上ある場合に最長一致で読みが消える
		# '''皆藤 愛子'''<ref>一部のプロフィールが</ref>(かいとう あいこ、[[1984年]]
		# '''大倉 忠義'''（おおくら ただよし<ref name="oricon"></ref>、[[1985年]]
		s1 = s.split("&lt;ref")[0]
		s2 = s.split("&lt;/ref&gt;")[1]

		if s1 != nil && s2 != nil
			s = s1 + s2
		end

		# スペースと「'"「」『』」を削除
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

		# 読みの不要な部分を削除
		yomi = yomi.tr('!?=・。', '')

		# 読みが2文字以下の場合はスキップ
		if yomi[2] == nil ||
		# 読みの文字数が表記の3倍を超える場合はスキップ
		yomi.length > hyouki.length * 3 ||
		# 読みが全てカタカナの場合はスキップ
		# ミュージシャン一覧(グループ)
		yomi == yomi.scan(/[ァ-ヴー]/).join ||
		# 読みが「ー」で始まる場合はスキップ
		yomi[0] == "ー"
			next
		end

		# 読みのカタカナをひらがなに変換
		yomi = NKF.nkf("--hiragana -w -W", yomi)
		yomi = yomi.tr("ゐゑ", "いえ")

		# 読みにひらがな以外のものがある場合はスキップ
		if yomi != yomi.scan(/[ぁ-ゔー]/).join
			next
		end

		# 表記の記号を変換
		hyouki = hyouki.gsub('&amp;', '&')
		hyouki = hyouki.gsub('&quot;', '"')

		$dicfile.flock(File::LOCK_EX)
		$dicfile.puts yomi + "	0	0	6000	" + hyouki
		$dicfile.flock(File::LOCK_UN)
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
article_part = ""

puts "Reading..."

while articles = reader.read(500000000)
	articles = articles.split("  </page>")
	articles[0] = article_part + articles[0]

	# 途中で切れた記事をキープ
	article_part = articles[-1]

	puts "Writing..."

	Parallel.map(articles, in_processes: 3) do |s|
		$article = s
		getYomiHyouki
	end

	puts "Reading..."
end

reader.close
$dicfile.close

# 重複エントリを削除
file = File.new(mozcdic, "r")
		lines = file.read.split("\n")
file.close

lines = lines.uniq.sort

file = File.new(mozcdic, "w")
		file.puts lines
file.close
