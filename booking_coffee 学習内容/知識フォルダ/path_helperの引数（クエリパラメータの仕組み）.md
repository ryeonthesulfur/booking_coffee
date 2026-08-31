# path_helperの位置引数とキーワード引数（クエリパラメータの仕組み）

---

## そもそもクエリパラメータとは

URLの **`?` 以降に付く `key=value` の形式のデータ**のこと。

```
https://example.com/search?keyword=coffee&page=2
                          ^---ここから先がクエリパラメータ---^
```

- `?` の後ろから始まる
- `key=value` の組を `&` で複数つなげられる
- ページ本体（パス部分）とは別に、追加の情報をURLに乗せて渡すための仕組み

今回の例で言うと、こうなる。

```
/stores/27/seats/A-1/reservations/new?start_time=2026%2F05%2F17...&num_people=2
└──────────── パス ────────────┘　　　　└──────────── クエリパラメータ ────────────┘
```

サーバー側ではRailsが自動でこれを分解し、`params[:start_time]`、`params[:num_people]` として読み取れるようにしてくれる。「URLを使って次の画面にデータを渡す」という仕組みの実体は、このクエリパラメータである。

---

## きっかけ

`confirm.html.erb` の「予約内容を修正する」リンクで、`new` 画面に戻ったときに入力済みの予約日時・人数・電話番号・備考を引き継ぎたかった。

最初に書いたのはこちら（エラーになるパターン）。

```erb
<%= link_to "予約内容を修正する", new_store_seat_reservation_path(
  @store, @seat.seat_number,
  @reservation.start_time.strftime("%Y/%m/%d %H:%M〜"),
  @reservation.num_people,
  @reservation.phone_number,
  @reservation.notes
), class: "btn-edit" %>
```

これはエラーになる。理由を理解するには、Railsのpath_helperが「引数をどう解釈しているか」を知る必要がある。

---

## ルーティングの定義を確認する

```ruby
resources :stores do
  resources :seats, only: [] do
    resources :reservations, only: [ :new, :create ] do
      ...
    end
  end
end
```

このネストにより、`new_store_seat_reservation_path` が組み立てるURLの形はこうなる。

```
/stores/:store_id/seats/:seat_id/reservations/new
```

`:store_id` と `:seat_id` という**2つの穴（プレースホルダー）**しか無い。

---

## 位置引数（順番で渡す）は、この「穴」を埋めるためだけのもの

```ruby
new_store_seat_reservation_path(@store, @seat.seat_number)
```

これは「1番目の穴（store_id）に `@store.id` を、2番目の穴（seat_id）に `@seat.seat_number` を入れてね」という意味。Railsは `@store` のようなオブジェクトを渡されると、自動的に `.id`（もしくはモデルが `to_param` を定義していればその値）を取り出して文字列化する。

結果はこうなる。

```
/stores/27/seats/A-1/reservations/new
```

**穴は2つしかないのに、3個目・4個目の位置引数を渡すと、Railsは「これも穴に入れる値のはずだ」と解釈しようとして、対応する穴が無いためエラーになる。**

実際に試すと `ActionController::UrlGenerationError` のようなエラーになる。

---

## キーワード引数（名前付き）は、穴を埋めた後の「おまけ」として`?`以降に付く

```ruby
new_store_seat_reservation_path(
  @store, @seat.seat_number,
  start_time: "2026/05/17 14:30〜",
  num_people: 2
)
```

ここでのポイントは、`start_time:` や `num_people:` のように**名前を付けている**こと。Railsは「名前が付いている引数は、ルートの穴を埋める対象ではない。クエリパラメータとして末尾に付け足す対象だ」と判断する。

結果はこうなる。

```
/stores/27/seats/A-1/reservations/new?start_time=2026%2F05%2F17+14%3A30%E3%80%9C&num_people=2
```

（`%2F` は `/`、`%3A` は `:`、`+` は半角スペース、`%E3%80%9C` は `〜` がURLエンコードされたもの）

---

## なぜ名前の有無でこんなに動きが変わるのか

Rubyのメソッド呼び出しの仕組みとして、

```ruby
some_method(a, b, c)        # すべて位置引数。「順番」だけで意味が決まる
some_method(a, b, key: c)   # a, b は位置引数。key: c はキーワード引数（ハッシュとして1つにまとめて最後の引数になる）
```

という違いがある。Railsのpath_helperは内部で「渡された引数のうち、位置引数の部分はルートの動的セグメント（`:store_id` や `:seat_id`）に順番に当てはめる。キーワード引数の部分は、ルートのセグメントに使われなかった残りなので、クエリパラメータとして `?key=value` の形に変換する」という処理をしている。

つまり、**名前を付けるかどうかで「ルートの一部」として使われるか「クエリパラメータ」として使われるかが決まる。**

---

## 受け取る側はどう読むか

クエリパラメータとして付けた値は、コントローラー側では `params[:start_time]`、`params[:num_people]` として読める。

```ruby
def new
  @seat = Seat.find_by(seat_number: params[:seat_id], store_id: params[:store_id])
  @store = Store.find(params[:store_id])
  @reservation = Reservation.new(start_time: params[:start_time])
end
```

また、`seats_index.js` のようにJavaScript側で直接URLを読みたい場合は `URLSearchParams` を使う。

```js
const urlParams = new URLSearchParams(window.location.search);
const startTimeParam = urlParams.get('start_time');
```

これは実際にこのアプリの間取り図画面でも使われている仕組みで、「予約フォーム画面に遷移するとき、間取り図で選んだ日時をURLの `?start_time=` に乗せて渡し、フォーム画面のJSがそれを読み取って初期値にする」という処理と全く同じ原理になっている。

---

## まとめ

| 渡し方 | 書き方 | 意味 |
|---|---|---|
| 位置引数 | `path(@store, @seat)` | ルートの動的セグメント（`:store_id`、`:seat_id`）を順番に埋める |
| キーワード引数 | `path(@store, @seat, start_time: "...")` | ルートの穴を埋めた後の残りを `?start_time=...` というクエリパラメータに変換する |

位置引数の数は、ルーティングで定義されている動的セグメントの数と必ず一致させる必要がある。それ以上の値を渡したいなら、必ず名前（キーワード）を付ける。
