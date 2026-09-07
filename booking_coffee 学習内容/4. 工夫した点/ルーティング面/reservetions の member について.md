# reservations の member について

---

## ルーティングコード

```ruby
resources :reservations, only: [ :index, :show, :destroy ] do
  member do
    patch :check_in
  end
end
```

---

## なぜ reservations のルーティングを２つも作っているのか？

予約入力フォームと、予約確認画面までは、保存前までなので店舗idと座席id をURLで橋渡しする必要があったため、  
stores からのルーティングネストに組み込む必要があったけれども、  
予約履歴、履歴の詳細、予約データの削除では、reservations に店舗や座席の予約データがあり、  
ログインしているユーザーの予約ということで足りるので、URLに含める必要がありません。  
そのため、ネストせずに独立させました。

---

## member を用いたチェックインについて

特定の予約済みのデータに対するアクションなので、member を使います。  
そして、enumの予約状況を「予約済」から「利用中」に更新するため、HTTPメソッドは「PATCH」を使います。
