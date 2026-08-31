# 解説：なぜコントローラーが空でもルーティングを消せないのか？

`SeatsController` の役割を `ReservationsController` に移したことで、「`routes.rb` の `resources :seats` も不要では？」という疑問が浮かびました。

これは非常に的確な疑問ですが、結論から言うと**「消してはいけない（消すと、もっと大変なことになる）」**が正解です。

このドキュメントでは、その理由と、Railsのルーティングが持つ「URL構造を定義する」という重要な役割について、誰でも理解できるように解説します。

---

## 問題の核心：`resources :seats` は何のためにあるのか？

`SeatsController` が不要になった今、`resources :seats` はコントローラーを呼び出すためではなく、**URLに `:seat_id` を埋め込むための「型枠」** として機能しています。

現在のルーティング構造を、建物のフロアに例えてみましょう。

```
GET /stores/:store_id/seats/:seat_id/reservations/new

【建物のフロア構造】
  ├─ reservations/new  （3階：予約フォームの部屋）
  ├─ seats/:seat_id      （2階：座席フロア）
  └─ stores/:store_id    （1階：店舗フロア）
```

この構造のおかげで、3階の「予約フォームの部屋」に行くときには、必ず1階の「店舗フロア」と2階の「座席フロア」を通ることになります。

Railsは、この通り道にある `:store_id` と `:seat_id` を自動的に拾い集め、`params` というカバンに入れてコントローラーに渡してくれます。だからこそ、`ReservationsController` は `params[:seat_id]` を使って「どの座席の予約か」を簡単に知ることができるのです。

---

## もし `resources :seats` を消したらどうなるか？

もし `resources :seats` をルーティングから削除すると、建物の2階が丸ごとなくなってしまいます。

```
GET /stores/:store_id/reservations/new

【崩壊後のフロア構造】
  ├─ reservations/new  （2階：予約フォームの部屋）
  └─ stores/:store_id    （1階：店舗フロア）
```

URLから `:seat_id` を入れる場所がなくなり、`ReservationsController` は `params[:seat_id]` を受け取れなくなります。その結果、**「どの座席の予約フォームなのか」が全く分からなくなってしまう**のです。

---

## よくある誤解：「ルーティング」と「アソシエーション」は別物

「ルーティングを消すと、データベースの関連付けも壊れるの？」という疑問も浮かびますが、この2つは完全に独立しています。

-   **アソシエーション (`belongs_to` など)**: モデル間の「家族関係」を定義するもの。
-   **ルーティング (`routes.rb`)**: アプリケーションへの「住所の書き方」を定義するもの。

住所の書き方（ルーティング）を変えても、家族関係（アソシエーション）は壊れません。しかし、手紙（データ）を正しい相手に届けるための「届け方」を、すべて手動で考え直さなければならなくなります。

---

## 最高の解決策：`only: []` で「型枠」だけを残す

今回のケースで最もスマートな解決策は、`routes.rb` を以下のように変更することです。

```ruby
# routes.rb

resources :stores, only: [:index, :show] do
  resources :seats, only: [] do # ← only: [:show] から only: [] へ変更
    resources :reservations, only: [:new, :create] do
      collection do
        post 'confirm'
        get 'complete'
      end
    end
  end
end
```

`only: []` は、**「`seats` 自体のページ（show, indexなど）は一切作らないでください。でも、ネストのためのURL構造（型枠）だけは残しておいてください」**という、まさに今回の状況にピッタリの指示です。

これにより、不要なルートを生成することなく、既存のURL構造とコントローラーのロジックを一切変更せずに、問題をクリーンに解決できます。

## まとめ

`resources` のネストは、単にコントローラーを呼び出すだけでなく、**親子関係をURLに反映させ、パラメータを自動で渡すための重要な設計**です。コントローラーが不要になっても、この「URLの型枠」としての役割のために、ルーティング定義を残しておくことは、Rails開発ではよくあるプラクティスなのです。