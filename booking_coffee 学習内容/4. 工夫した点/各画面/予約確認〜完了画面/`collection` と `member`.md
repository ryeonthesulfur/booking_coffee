# 解説：ルーティングの `collection` と `member`

Railsルーティングにおける `collection` と `member` の違いについて、それぞれの概念、使い分け、そしてあなたのプロジェクトにおける具体的な実装例を交えて解説します。

この2つの概念を理解する鍵は、**「アクションの対象が、特定のIDを持つ単一のレコードか、それともレコードの集合全体か」**です。

---

### 結論：一言で言うと？

-   `member` : **特定の1人**に対するアクション（IDが**必要**）
-   `collection`: **クラス全体**に対するアクション（IDが**不要**）

---

### `member` とは？ - 「特定の1人」へのアクション （完了画面に使う）

`member`ルートは、**特定のIDを持つリソース**に対して何かを行いたい場合に使います。URLに必ず `:id` が含まれるのが特徴です。

**考え方:**
学校のクラスで、先生が「**出席番号3番の鈴木くん**、ちょっと来て」と、特定の生徒を指名するイメージです。

**典型的な例:**
-   あるブログ記事を「公開」する: `/articles/123/publish`
-   ある商品を「カートに追加」する: `/products/45/add_to_cart`

**`routes.rb` での書き方:**
```ruby
resources :articles do
  member do
    post 'publish'
  end
end
```
これにより、`/articles/:id/publish` というURLが生成されます。`publish` アクションは、どの記事を公開するのか特定するために `:id` を必要とします。

---

### `collection` とは？ - 「クラス全体」へのアクション

`collection`ルートは、**リソースの集合全体**に対して何かを行いたい場合に使います。URLに `:id` が含まれません。

**考え方:**
先生が「**クラス全員**、教科書の5ページを開いて」と、クラス全体に指示を出すイメージです。特定の誰かを指名してはいません。

**典型的な例:**
-   ブログ記事を「検索」する: `/articles/search`
-   ユーザー一覧を「インポート」する: `/users/import`

**`routes.rb` での書き方:**
```ruby
resources :articles do
  collection do
    get 'search'
  end
end
```
これにより、`/articles/search` というURLが生成されます。`search` アクションは、特定の記事ではなく、記事全体から探すため `:id` を必要としません。

---

### あなたのプロジェクトでの実例：`reservations` の `confirm`

`confirm` アクションが `collection` で定義されているのは、**完璧に正しい設計**です。

`confirm` は、ユーザーが予約フォームに入力し、「確認画面へ」ボタンを押したときに呼び出されます。この時点では、まだ予約情報はデータベースに保存されておらず、**予約のID (`reservation.id`) がまだ存在しない**ためです。

したがって、「予約というリソースの集合に対して、これから一つ作りますよ」という文脈なので、IDを必要としない `collection` を使うのが正解です。このルーティングは `POST /stores/:store_id/seats/:seat_id/reservations/confirm` というURLを生成します。

もしこれを `member` で定義してしまうと、URLは `.../reservations/:id/confirm` となり、「**既存の**予約を確認する」という意味合いになってしまい、今回の目的とは合わなくなります。

---

### まとめ表

|                       | `member`                               | `collection` |
| :--- | :--- | :--- |
| **対象**              | 特定のIDを持つ**単一**のリソース      |            リソースの**集合全体** |
| **URLに `:id` は？**      | **必要** (`/resources/:id/...`) |          **不要** (`/resources/...`) |
| **考え方**                 | 「特定の1人」を指名する           |          「クラス全体」に指示する |
| **典型的なアクション**        | `publish`, `archive`, `like` |            `search`, `import`, `confirm` (新規作成時) |

---




### なぜ `collection` を使うのか？ (カスタムルートとの違い)

`collection do ... end` と書くことは、**「このアクションは `reservations` に属しますよ」とRailsに伝えるための書き方**です。

基本的な用途は以下のようなものです。

```ruby
collection do
  get  "search"  # 全件の中から検索
  post "import"  # 全件に対して一括インポート
end
```

これらは「特定のidを持つ1件」ではなく「リソース全体に対する操作」なので `collection` を使います。

#### 今回の `confirm` での応用

`confirm` はこの `collection` に `post` メソッドを組み合わせた使い方です。

保存前のデータを確認画面に表示したいとき、GETで渡すとURLに予約内容が全部クエリパラメータとして露出してしまいます。そこで `collection` + `POST` を使うことで、**リクエストボディに全体のデータを乗せたまま**、カスタムの確認画面専用のURLとして `reservations` グループの中に生やすことができます。

```ruby
collection do
  post "confirm"  # POST /stores/:store_id/seats/:seat_id/reservations/confirm
end
```

「まだidがない保存前のデータを、URLを汚さずに次の画面に渡したい」という場面では、このように `collection` + `POST` の組み合わせが有効です。

#### `collection` vs `カスタムルート`

同じURLを生成する2つの方法を比較すると、そのメリットは明確です。

**方法A: `resources` と `collection` を使う（推奨）**
```ruby
resources :reservations, only: [ :create ] do
  collection do
    post "confirm"
  end
end
```

**方法B: 完全にカスタムで書く**
```ruby
post '/reservations/confirm', to: 'reservations#confirm', as: 'confirm_reservation'
```

方法Aが優れている理由は3つあります。

1.  **可読性と整理**: `confirm` が `reservations` に関連するアクションであることが一目瞭然です。`resources` ブロックで関連ルートがグループ化されるため、コードの意図が明確になります。

2.  **DRY (Don't Repeat Yourself) の原則**: もしルートが `/stores/:store_id/seats/:seat_id/reservations` のようにネストしている場合、方法Aなら共通のパスをRailsが自動で組み立ててくれます。方法Bでは毎回長いパス全体を書く必要があり、メンテナンス性が低下します。

3.  **自動生成されるパスヘルパー**: これが最大のメリットです。
    -   **方法A**: `confirm_store_seat_reservations_path(@store, @seat)` のような、**非常に直感的でリッチなパスヘルパー**を自動で生成します。
    -   **方法B**: `confirm_reservation_path(store_id: @store.id, seat_id: @seat.id)` のように引数をハッシュで渡す必要があり、少し不便です。

#### まとめ

`resources` ブロックと `collection` を使ってルートを書くことは、単にURLを定義する以上の行為です。

それは、**「アプリケーションのデータ構造をURLに反映させ、Railsの規約（Convention）に乗っかることで、より可読性が高く、DRYで、メンテナンスしやすいコードを書く」**という、Railsの美しい設計思想そのものを体現する書き方なのです。

完全にカスタムで書くのは、`resources` の規約から外れた本当に特殊なルートを定義したい場合に限定すべきです。今回の `confirm` のようにリソースに密接に関連するアクションは、`collection` を使うのがベストプラクティスと言えます。


# 流れ

① 予約フォーム → 確認画面

「確認画面へ」ボタンを押す

→ collection + POST で reservations#confirm へ

→ 入力内容はリクエストボディに乗っている（URLに露出しない）

→ 確認画面を表示

② 確認画面 → DB保存

「予約を確定する」ボタンを押す

→ hidden_field に入っていた予約内容が POST で reservations#create へ

→ create アクションがDBに保存

→ この時点で @reservation.id が確定する

③ DB保存 → 完了画面


redirect_to complete_store_seat_reservation_path(@store, @seat, @reservation)
→ member + GET で reservations#complete へ

→ 確定した id を使って特定の予約データにアクセス

→ 完了画面を表示

まとめると「POSTでデータを運ぶ → 保存してidが確定 → idを使って完了画面へ」という流れです。

