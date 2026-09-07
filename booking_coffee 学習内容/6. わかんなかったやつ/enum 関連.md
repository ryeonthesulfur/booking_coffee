# 解説：enum 関連

---

## enum とは

モデルの数値カラムに**名前を付けて管理する**Railsの機能。

DBには数値（0, 1, 2）で保存されるが、コード上では名前（`reserved`, `using`, `checked_out`）で扱える。

---

## このアプリでの定義（`reservation.rb`）

```ruby
enum :status, { reserved: 0, using: 1, checked_out: 2 }
```

| 名前 | DB上の値 | 意味 |
|---|---|---|
| `reserved` | `0` | 予約済（チェックイン前） |
| `using` | `1` | 利用中（チェックイン後） |
| `checked_out` | `2` | 退店済 |

---

## enum が自動で作るメソッド

enum を定義すると、Railsが以下のメソッドを**自動で生成する**。

### スコープメソッド（クラスメソッド）

状態ごとのレコードを絞り込むメソッド。

```ruby
Reservation.reserved    # status が "reserved"（0）の予約を全件取得
Reservation.using       # status が "using"（1）の予約を全件取得
Reservation.checked_out # status が "checked_out"（2）の予約を全件取得
```

### 状態確認メソッド（インスタンスメソッド）

```ruby
reservation.reserved?    # → true / false
reservation.using?       # → true / false
reservation.checked_out? # → true / false
```

### 状態変更メソッド（インスタンスメソッド）

```ruby
reservation.reserved!    # status を "reserved" に更新してDBに保存
reservation.using!       # status を "using" に更新してDBに保存
```

---

## 自動キャンセルJobでの使い方

`cancel_no_show_reservations_job.rb` の中で `Reservation.reserved` が使われている。

```ruby
def perform
  Reservation.reserved.where(start_time: ..15.minutes.ago).each do |reservation|
    ReservationMailer.reservation_cancelled(reservation).deliver_now
    reservation.destroy
  end
end
```

### 読み方

```ruby
Reservation.reserved
# → status が "reserved"（予約済・チェックイン前）の予約だけに絞り込む
#   enumが自動生成したスコープメソ���ド

.where(start_time: ..15.minutes.ago)
# → start_time が「15分以上前」の予約に絞り込む
#   （..15.minutes.ago は「15分前以前」という範囲）
```

合わせると：**「予約済のまま、開始時刻から15分以上経過した予約」**を全件取得している。

これがノーショー（来店しなかった人）の予約に相当するので、ループでキャンセルメール送信 → 予約削除している。

---

## まとめ

- `enum` はDBの数値カラムに名前を付けて扱いやすくする機能
- 定義するだけで `.reserved`・`reserved?`・`reserved!` などのメソッドが自動生成される
- `Reservation.reserved` はその自動生成されたスコープメソッドで、自動キャンセルJobの絞り込み条件として使っている
