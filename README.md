# phula-temperament-analysis

[調和純正律で遊ぼう ～第14回 調和純正律の分析（２）〜五度圏と各音程の協和度](https://shanti-phula.net/ja/social/blog/?p=269281)の協和度表を出すためのプログラムです。

- `examples/print-temperaments.rb`
    - 各音律の周波数比等を出力する例。
- `examples/generate-interval-tables.rb`
    - 記事で使用した音程の協和度表HTMLファイルを出力する例。
- `lib/temperament.rb`, `spec/temperament_spec.rb`
    - 各音律の定義とそのテスト。
- `lib/temperament/hpi_template.rb`
    - このファイルの指示に従って hpi.rb を作ると、調和純正律が出力に追加される。

