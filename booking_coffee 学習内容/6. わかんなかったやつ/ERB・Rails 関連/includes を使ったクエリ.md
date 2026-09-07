# 解説：`includes` を使ったクエリ

---

## 何をするのか

関連するテーブルのデータを**あらかじめまとめて取得する**メソッド。

```ruby
@reservation = current_user.reservations.includes(seat: :store).find(params[:id])
```

---

## なぜ必要なのか（N+1問題）

`includes` を使わないと、**N+1問題**という無駄なSQLが大量発行される状態になる。

### N+1問題とは

例として予約一覧（10件）を表示する場合を考える。

```ruby
# includes なし
@reservations = current_user.reservations  # ← SQL 1回（予約10件取得）

# ビューで各予約の座席名を表示しようとすると…
@reservations.each do |r|
  r.seat.seat_number   # ← 予約1件ごとにSQLが1回 → 10回発行される
  r.seat.store.name    # ← さらに店舗もSQLが1回ずつ → 10回発行される
end
```

合計 **1 + 10 + 10 = 21回** のSQLが発行される。件数が増えるほど遅くなる。

### includes で解決する

```ruby
# includes あり
@reservations = current_user.reservations.includes(seat: :store)
# ← SQL 3回でまとめて取得（予約・座席・店舗）

@reservations.each do |r|
  r.seat.seat_number  # ← すでに取得済みなのでSQLは発行されない
  r.seat.store.name   # ← 同様
end
```

最初に必要なデータを全部まとめて取得しておくので、ループ中に追加のSQLが発行されない。

---

## `includes(seat: :store)` の読み方

```ruby
includes(seat: :store)
```

| 部分 | 意味 |
|---|---|
| `seat` | `Reservation` に関連する `Seat` を一緒に取得する |
| `: :store` | さらにその `Seat` に関連する `Store` も一緒に取得する |

ネストして書くことで「予約 → 座席 → 店舗」という2段階の関連を一度に取得できる。

---

## このアプリでの使用箇所

| ファイル | コード | 取得する関連 |
|---|---|---|
| `reservations_controller.rb` `#index` | `current_user.reservations.includes(seat: :store)` | 予約一覧 + 座席 + 店舗 |
| `reservations_controller.rb` `#show` | `current_user.reservations.includes(seat: :store).find(params[:id])` | 特定の予約 + 座席 + 店舗 |
| `stores_controller.rb` `#index` | `Store.includes(:seats).all` | 全店舗 + 座席 |

`show` アクションでは取得後に以下のように関連データを使っている。

```ruby
def show
  @reservation = current_user.reservations.includes(seat: :store).find(params[:id])
  @store = @reservation.seat.store  # ← includes済みなので追加SQLなし
  @seat  = @reservation.seat        # ← 同様
end
```

---

## まとめ

`includes` は「後で使う関連データをあらかじめまとめて取得しておく」メソッド。  
使わないとループのたびにSQLが発行されて遅くなる（N+1問題）。関連データをビューで使うことがわかっている場合は積極的に使う。
