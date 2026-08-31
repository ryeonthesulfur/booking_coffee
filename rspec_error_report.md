# RSpec 導入時のエラーまとめ

## reservation.rb のミス

### 1. message のタイポ
```ruby
# 誤
format: { with: /.../, messege: "は10〜11桁の半角数字で入力してください" }

# 正
format: { with: /.../, message: "は10〜11桁の半角数字で入力してください" }
```

### 2. 正規表現が11〜12桁になっていた
```ruby
# 誤（最初の \d が余分で、合計11〜12桁にマッチしていた）
/\A\d[0-9]{10,11}\z/

# 正
/\A[0-9]{10,11}\z/
```

### 3. no_overlapping_reservation で start_time が nil の場合にクラッシュ
`start_time` が空のとき `start_time - 3.hours` を計算しようとして `NoMethodError` になっていた。
空の場合は `presence: true` のバリデーションが別途チェックするので、重複チェックはスキップでよい。

```ruby
def no_overlapping_reservation
  return if start_time.blank?
  # ...
end
```

---

## reservation_spec.rb のミス

### 1. before で @reservation を create していた
`create` にすると毎テスト前に DB に予約が保存され、`no_overlapping_reservation` に引っかかって全テストが落ちる。
`@reservation` は `build`（DB に保存しない）にする必要があった。

```ruby
# 誤
@reservation = FactoryBot.create(:reservation, user: @user, seat: @seat)

# 正
@reservation = FactoryBot.build(:reservation, user: @user, seat: @seat)
```

### 2. エラーメッセージの文字列がずれていた
Rails はエラーメッセージの先頭にカラム名を自動でつける。

```ruby
# 誤
expect(@reservation.errors.full_messages).to include("は10〜11桁の半角数字で入力してください")

# 正
expect(@reservation.errors.full_messages).to include("Phone number は10〜11桁の半角数字で入力してください")
```

### 3. カラム名の表示が違った
```ruby
# 誤
include("Number of people can't be blank")

# 正
include("Num people can't be blank")
```

---

## factories のミス

### 1. stores.rb に association :seats を書いていた
`has_many` 側には `association` は不要。`belongs_to` 側だけに書く。

```ruby
# 誤
factory :store do
  association :seats
  ...
end

# 正
factory :store do
  name { "テストカフェ" }
  ...
end
```

### 2. seats.rb に association :reservations を書いていた
`seat` は `store` に `belongs_to` しているので `association :store` が正しい。

```ruby
# 誤
factory :seat do
  association :reservations
  ...
end

# 正
factory :seat do
  association :store
  ...
end
```
