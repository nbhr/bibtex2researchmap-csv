# bibtex2researchmap-csv

## 目的

researchmap.jpへの論文情報登録を省力化するためのrubyスクリプト．
具体的にはresearchmap.jpでimport可能なcsvファイルをbibファイルから生成する．

### お断り

このスクリプトは汎用性・再利用性を考えては作成されていません．bibtexエントリー種別の使い分けが違う，などの場合はスクリプトを直接書き換えてください．

## 使い方

第1引数に元となるbibファイルを指定して実行．
```
$ ruby bib2csv.rb sample.bib
```

下記のファイルが出力されるので，これらをresearchmap.jpでimportする．
* `paper_e.csv` : 「論文-英語」用
* `paper_j.csv` : 「論文-日本語」用
* `misc_e.csv` : 「学会発表等-英語」用
* `misc_j.csv` : 「学会発表等-日本語」用

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
|査読の有無         |※１                           |
|招待の有無         |invited ※２                   |
|記述言語           |language ※２                  |
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

* ※１：下記分類により自動決定
* ※２：下記の独自拡張フィールド

### BibTexエントリーとresearchmap.jp分類の対応関係

* `@article` → 「論文」，査読あり
* `@inproceedings` → 「Misc」，査読あり（国際会議論文を想定）
* `@techreport` → 「Misc」，査読なし（信学会や情処の研究会を想定）

### 日英の判定

* 著者がすべてASCII文字 → 英語

### BibTex拡張フィールド

* `reviewed` → 値が0なら「査読：無」，1なら「査読：有」とする（デフォルトは上記のとおりエントリー種別で自動決定）
* `invited` → 値が0なら「招待：無」，1なら「招待：有」とする（デフォルトは無し）
* `language` → 値がjapaneseまたはjaなら強制的に日本語論文，englishまたはenなら英語論文とする（デフォルトは著者名の文字コードで自動決定）

## ライセンス

BSD 3-Clause License


