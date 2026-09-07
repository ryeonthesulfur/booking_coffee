# 解説：enum定義でエラー？ - Railsバージョンアップと記法の変更

`stores_controller.rb` で予約済みの座席を絞り込む際に、以下のようなエラーが発生しました。

```
ArgumentError in StoresController#show
wrong number of arguments (given 0, expected 1..2)
```

原因は、`Reservation` モデルで定義した `enum` の `:using` という名前が、Railsの内部で使われている「予約語」と衝突してしまったことでした。

この一見不可解なエラーがなぜ起きるのか、そしてどう解決すればよいのかを詳しく見ていきましょう。

--
## エラーが発生した状況

まず、関連するコードを確認します。

**app/models/reservation.rb**
`status` カラムを管理するために `enum` を定義しました。

```ruby
class Reservation < ApplicationRecord
  # ...
  enum status: { reserved: 0, using: 1, checked_out: 2 }
  # ...
end
```

**app/controllers/stores_controller.rb**
この `enum` を使って、「予約済み」または「使用中」の座席を探そうとしました。

```ruby
# 問題のコード
@reserved_seat_numbers = @store.seats
  .joins(:reservations)
  .where(reservations: { status: [:reserved, :using] }) # ここが原因！
  .pluck(:seat_number)
```

コードに間違いはなさそうに見えますが、ここで `ArgumentError` が発生してしまいました。

## なぜエラーが起きたのか？ - 犯人はRails内部の「Arel」

結論から言うと、**:using がRails内部でSQLを組み立てるためのライブラリ「Arel」のメソッド名（予約語）と被ってしまったから**です。

流れはこうです。

1.  Railsは `.where(status: :using)` というコードを受け取ります。
2.  Railsは「これは `status` が `1` のものを探せばいいんだな」と解釈する**前**に、内部のSQLビルダーである **Arel** に処理を渡します。
3.  Arelは `:using` というシンボルを見て、「お、これはSQLの `JOIN ... USING` 構文を作るための自分のメソッド `using` が呼ばれたな！」と**勘違い**してしまいます。
4.  Arelの `using` メソッドは、テーブルを結合するための引数を必要とします。しかし、今回は引数が渡されていないため、「引数の数が違うよ！（`wrong number of arguments`）」というエラーを発生させたのです。

このように、私たちが書いた `:using` が、意図せずArelの機能を呼び出してしまったのがエラーの正体です。

## 解決策

この問題を回避するには、Arelが勘違いしない方法で条件を指定する必要があります。

### 解決策1：整数値で直接指定する（応急処置）

シンボルの代わりに、`enum` で定義した整数値を直接使います。

```ruby
# app/controllers/stores_controller.rb

.where(reservations: { status: [0, 1] }) # :reserved と :using の代わりに整数を指定
```

整数 `0` や `1` はArelの予約語ではないため、Arelは勘違いしません。Railsはこれを素直に値として解釈し、`WHERE "reservations"."status" IN (0, 1)` という正しいSQLを生成してくれます。

### 解決策2：enumのキー名を変更する（推奨される根本対策）

より良い方法は、衝突の原因となっている `enum` のキー名自体を変更することです。これにより、コードの可読性を損なわずに問題を解決できます。

**app/models/reservation.rb**

```ruby
# :using を :in_use に変更
enum status: { reserved: 0, in_use: 1, checked_out: 2 }
```

このように変更すれば、コントローラー側では新しいシンボルを使って安全にクエリを書くことができます。

```ruby
# app/controllers/stores_controller.rb

.where(reservations: { status: [:reserved, :in_use] }) # もうエラーは起きない
```

`:in_use` は予約語ではないため、Arelが勘違いすることはありません。将来的にコードを見返したときも、`[0, 1]` よりも `:in_use` の方が意味が分かりやすいというメリットがあります。

## まとめ

-   `enum` でキー名を定義する際は、`using`, `select`, `group`, `order` といった、SQLやArelで使われる**予約語を避ける**のが安全です。
-   もし予約語と衝突してしまった場合は、**整数値で指定する**か、より根本的な解決策として**キー名を変更する**ことを検討しましょう。