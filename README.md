# bibtex2researchmap-csv

## 目的

researchmap.jpへの論文情報登録を省力化するためのrubyスクリプト．
具体的にはresearchmap.jpでimport可能なcsvファイルをbibファイルから生成する．

### お断り

このスクリプトは汎用性を考えて作成されたものではなく，指定された書式に応じて適当に改造しながら使うためのテンプレートです．
bibtexエントリー種別の使い分けが違う，WORDやWEB向けにHTMLで出力したい，などの場合はスクリプトを書き換えてください．

なお同梱の`bib2csv.csl`はciteproc-stylesの`ieee.csl`をもとにして，タブ区切り出力となるよう中途半端に改造したものです．オリジナルの作者については同ファイル内を確認してください．

## 依存ライブラリ

gemで以下をインストール．要するに[jekyll](https://jekyllrb.com/)が動く環境ならOK．
* [bibtex-ruby](https://github.com/inukshuk/bibtex-ruby)
* [citeproc-ruby](https://github.com/inukshuk/citeproc-ruby)
* [csl-ruby](https://github.com/inukshuk/csl-ruby)

## 使い方

第1引数に元となるbibファイルを指定して実行．
```
$ ruby bib2csv.rb sample.bib
```

下記のファイルが出力されるので，これらをresearchmap.jpでimportする．
* `paper_e.csv` : 「論文-英語」用
* `paper_j.csv` : 「論文-日本語」用
* `misc_e.csv` : 「Misc-英語」用
* `misc_j.csv` : 「Misc-日本語」用

## 仕様

暫定仕様．自分の都合に合わせて適宜改変する可能性が高い．

### BibTexフィールドとCSVフィールドの対応関係

| CSV               | BibTex                        |
|-------------------|-------------------------------|
|タイトル(日本語)   |title                          |
|タイトル(英語)     |title                          |
|著者(日本語)       |author                         |
|著者(英語)         |author                         |
|誌名(日本語)       |journal, booktitle, institution|
|誌名(英語)         |journal, booktitle, institution|
|巻                 |volume                         |
|号                 |number                         |
|開始ページ         |pages                          |
|終了ページ         |pages                          |
|出版年月           |year,month                     |
|査読の有無         |reviewed *1, *2                |
|招待の有無         |invited *2                     |
|記述言語           |language *1, *2                |
|掲載種別           |                               |
|ISSN               |                               |
|ID:DOI             |                               |
|ID:JGlobalID       |                               |
|ID:NAID(CiNiiのID) |                               |
|ID:PMID            |                               |
|Permalink          |                               |
|URL                |                               |
|概要(日本語)       |                               |
|概要(英語)         |                               |

1. 下記分類により自動決定
2. 下記の独自拡張フィールド

### BibTexエントリーとresearchmap.jp分類の対応関係

* `@article` → 「論文」，査読あり
* `@inproceedings` → 「Misc」，査読あり（国際会議論文を想定）
* `@techreport` → 「Misc」，査読なし（信学会や情処の研究会を想定）

### 日英の判定

* 著者がすべてASCII文字 → 英語

### BibTex拡張フィールド

* `reviewed` → 値が0なら「査読：無」，1なら「査読：有」とする（デフォルトはエントリー種別で自動決定）
* `invited` → 値が0なら「招待：無」，1なら「招待：有」とする（デフォルトは無し）
* `language` → 値がjapaneseまたはjaなら強制的に日本語論文，englishまたはenなら英語論文とする（デフォルトは著者名の文字コードで自動決定）

## おまけ

`bib2txt.rb`を使うと，bibからplain textで文献リストを生成できる．要するにBibTexそのもの…ではあるが，スクリプト的に何か追加処理をする際のテンプレートとして．`.bst`ファイルよりも`.csl`ファイルのほうが編集しやすい，という人向け．逆に`.bst`や`.csl`よりも直接スクリプトを書くほうが早いという人は`bib2csv.rb`を好きなように改造してください．

第１引数はbibファイル，第２引数はCSLファイルの名前．csl-stylesに同梱されているもの（`ieee`や`acm-siggraph`など）でも，カレントディレクトリに自分で用意したファイルでも可．独自の様式にしたい場合は，適当な既存CSLをもとに編集してカレントに置けばよい．

```
$ ruby bib2txt.rb sample.bib ieee
```


## ライセンス

BSD 3-Clause License


