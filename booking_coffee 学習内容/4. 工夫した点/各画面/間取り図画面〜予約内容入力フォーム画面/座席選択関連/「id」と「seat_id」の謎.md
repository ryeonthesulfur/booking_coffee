# 解説：`:id`と`:seat_id`の謎 - Railsのネスト規約を解き明かす

「なぜ同じ座席IDなのに、URLによって`params[:id]`になったり`params[:seat_id]`になったりするの？」

これは、Railsのルーティングが持つ、賢くも少し紛らわしい**自動命名ルール**が原因です。結論から言うと、あなたの「単純にURIパターンの命名規則に従って表記を変えただけ」という理解は100%正しいです。

ここでは、そのルールを「主役は誰だ？」という視点で解説します。

---

## Railsのルール：URLの「一番深い階層（主役）」が `:id` を名乗る

Railsのネストされたルーティングでは、常に**一番右端にいるリソースがそのURLの「主役」**と見なされます。そして、主役だけが `params[:id]` という特別な名前を使うことを許されます。

主役以外の、途中の階層にいるリソース（脇役）たちは、主役と名前が被らないように `params[:リソース名_id]` という名前に自動的に変更されます。

---

## 具体例で見る「主役」の交代劇

### ケース1：店舗詳細ページ (`stores#show`)

-   **URLパターン**: `/stores/:id`
-   **URLの階層**: `stores`

このURLでは、一番右端にいる `stores` が**主役**です。

-   主役 (`stores`) のID → `params[:id]`

そのため、`StoresController` では、`params[:id]` を使って店舗を取得します。

```ruby
# stores_controller.rb
def show
  # 主役なので params[:id] を使う
  @store = Store.find(params[:id])
end
```

### ケース2：予約フォームページ (`reservations#new`)

-   **URLパターン**: `/stores/:store_id/seats/:seat_id/reservations/new`
-   **URLの階層**: `stores` → `seats` → `reservations`

このURLでは、一番右端にいる `reservations` が**主役**に躍り出ます。

-   主役 (`reservations`) のID → `params[:id]` （※ `new` アクションはまだ保存前なので実際には存在しない）
-   脇役 (`seats`) のID → `params[:seat_id]`
-   脇役 (`stores`) のID → `params[:store_id]`

`seats` は主役の座を `reservations` に譲ったため、名前を `:seat_id` に変更させられたのです。

そのため、`ReservationsController` では、`params[:seat_id]` を使って座席の識別子を取得する必要があります。
ただし `:seat_id` の中身は DB の id ではなく「A-1」のような座席番号の文字列なので、`find` ではなく `find_by` で検索します。

```ruby
# reservations_controller.rb
def new
  # seats は脇役なので params[:seat_id] を使う
  # :seat_id の中身は座席番号（文字列）なので find_by で検索する
  @seat = Seat.find_by(seat_number: params[:seat_id], store_id: params[:store_id])
  @store = Store.find(params[:store_id])
end
```

## まとめ

URLに入っている実際の値（例: "A-1"）も、それが指し示す座席も、全く同じものです。

変わっているのは、**URLの文脈（どのリソースが主役か）に応じて、Railsが自動的に付け替える `params` のキー名（ラベル）だけ**です。これは、複数のIDが混在する複雑なURLでも、開発者が混乱しないようにするためのRailsの親切な設計思想なのです。