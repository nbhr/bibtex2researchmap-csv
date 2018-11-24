# bibtex2researchmap-csv

## 目的

[researchmap.jp](https://researchmap.jp/)への論文情報登録を省力化するためのrubyスクリプトです．
具体的にはresearchmap.jpでimport可能なcsvファイルをbibファイルから生成します．

つまりもともとBibTeXで文献リストを管理し，各種報告書・申請書の文献一覧を指定された書式に応じて自動生成していたような人が，researchmap.jpにも論文情報を簡単に登録することを目的としています．

### お断り

このスクリプトは汎用性を考えて作成されたものではなく，指定された書式に応じて適当に改造しながら使うためのテンプレートです．
bibtexエントリー種別の使い分けが違う，WORDやWEB向けにHTMLで出力したい等々，その時々の事情に合わせてスクリプトをどんどん書き換えてください．

なお同梱の`bib2csv.csl`はciteproc-stylesの`ieee.csl`をもとにして，タブ区切り出力となるように中途半端に改造したものです．オリジナルの作者については同ファイル内を確認してください．`CiteProc::Processor`をもっと上手に使えれば不要になると思いますが，やっつけ仕事なので不細工な実装となっています．

## 依存ライブラリ

gemで以下をインストール．要するに[jekyll](https://jekyllrb.com/)と[jekyll-scholar](https://github.com/inukshuk/jekyll-scholar)が動く環境ならOK．
* [bibtex-ruby](https://github.com/inukshuk/bibtex-ruby)
* [citeproc-ruby](https://github.com/inukshuk/citeproc-ruby)
* [csl-ruby](https://github.com/inukshuk/csl-ruby)

## 使い方

第1引数に元となるbibファイルを指定して実行．
```
$ ruby bib2csv.rb sample.bib
```

下記のファイルが出力されるので，これらをresearchmap.jpでimportする．文字コードはUTF-8なので，必要ならnkfか何かで変換する．
* `paper_e.csv` : 「論文-英語」用
* `paper_j.csv` : 「論文-日本語」用
* `misc_e.csv` : 「Misc-英語」用
* `misc_j.csv` : 「Misc-日本語」用

### 注意

* 用意するbibファイルは，`@string`を使って論文誌名などに表記のゆれが無いようにするほうがよい．
  * 同梱の`sample.bib`参照
* bibtex-rubyのlatexフィルタを通すので，標準的なlatex命令はbibtexエントリに入っていても問題ない…はず．しかしどの程度まで対応できるかは不明．
  * 例えば同梱の`sample.bib`での「`In Proc.~of`」において`~`（改行不可の空白）はスペース１文字に変換される．
* 機能の変更・追加が必要な場合はスクリプトを直接改造する．
  * なにか動作が切り替わるような実行時引数などは何も用意されていない．
  * 出力ファイル名もハードコーディングされている．
  * 必要があれば独自BibTexフィールドを追加し，それに対応するコードを書く．
* 出力の文字コードをSJISにしたい場合はソースコードを書き換えるか，nkfなどを使う．ただしSJISで表せない文字（アクセント記号など）が著者名などに含まれる場合には文字化けに注意．

## 仕様

暫定仕様．自分の都合に合わせて適宜改変する可能性が高い．

### BibTexフィールドとCSVフィールドの対応関係

| CSV               | BibTex                                 |
|-------------------|----------------------------------------|
|タイトル(日本語)   |title                                   |
|タイトル(英語)     |title                                   |
|著者(日本語)       |author                                  |
|著者(英語)         |author                                  |
|誌名(日本語)       |journal, booktitle, institution         |
|誌名(英語)         |journal, booktitle, institution         |
|巻                 |volume                                  |
|号                 |number                                  |
|開始ページ         |pages                                   |
|終了ページ         |pages                                   |
|出版年月           |year,month                              |
|査読の有無         |reviewed *1, *2                         |
|招待の有無         |invited *2                              |
|記述言語           |language *1, *2                         |
|掲載種別           |                                        |
|ISSN               |                                        |
|ID:DOI             |doi or https://doi.org/... in url or pdf|
|ID:JGlobalID       |                                        |
|ID:NAID(CiNiiのID) |                                        |
|ID:PMID            |                                        |
|Permalink          |                                        |
|URL                |                                        |
|概要(日本語)       |                                        |
|概要(英語)         |                                        |

1. 下記分類により自動決定
2. 下記の独自拡張フィールド

### BibTexエントリーとresearchmap.jp分類の対応関係

* `@article` → 「論文」，査読あり
* `@inproceedings` → 「Misc」，査読あり（国際会議論文を想定）
* `@techreport` → 「Misc」，査読なし（信学会や情処の研究会を想定）

### 日英の判定

* 著者と誌名いずれかに日本語（`/(?:\p{Hiragana}|\p{Katakana}|[一-龠々])/`）を含むか否か

### BibTex拡張フィールド

* `reviewed` → 値が0なら「査読：無」，1なら「査読：有」とする（デフォルトはエントリー種別で自動決定）
* `invited` → 値が0なら「招待：無」，1なら「招待：有」とする（デフォルトは無し）
* `language` → 値がjapaneseまたはjaなら強制的に日本語論文，englishまたはenなら英語論文とする（デフォルトは著者名の文字コードで自動決定）

## おまけ

`bib2txt.rb`を使うと，bibからplain textで文献リストを生成できます．要するにBibTexそのもの…ですが，スクリプト的に何か追加処理をする際のテンプレートとして．`.bst`ファイルよりも`.csl`ファイルのほうが編集しやすい，という人向け．逆に`.bst`や`.csl`よりも直接スクリプトを書くほうが早いという人は`bib2csv.rb`を好きなように改造してください．

第１引数はbibファイル，第２引数はCSLファイルの名前．csl-stylesに同梱されているもの（`ieee`や`acm-siggraph`など）でも，カレントディレクトリに自分で用意したファイルでも可．独自の様式にしたい場合は，適当な既存CSLをもとに編集してカレントに置けばOK．

```
$ ruby bib2txt.rb sample.bib ieee
```

## ライセンス

BSD 3-Clause License


