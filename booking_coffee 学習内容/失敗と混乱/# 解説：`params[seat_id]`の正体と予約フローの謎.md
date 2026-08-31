# 解説：`params[:seat_id]`の正体と予約フローの謎

## 発端：AIの誤解と混乱

予約機能の実装において、「`create`や`confirm`アクションで座席を探す際に`Seat.find`と`Seat.find_by`のどちらを使うべきか？」という点でAIアシスタント（Claude）との間に大きな混乱が生じました。

AIは当初、「`reservations#new`に渡される`params[:seat_id]`が"A-1"のような文字列なので、その後の`create`アクションでも`find_by`を使う必要がある」と指摘しました。しかし、これは**完全な間違い**でした。

このドキュメントでは、なぜその指摘が間違いだったのか、そして実際の正しいデータの流れはどうなっているのかを、誰でも理解できるように解き明かします。

---

## 正しいデータの流れ：3ステップで理解する

結論から言うと、**「`new`アクションで一度だけ`find_by`を使い、以降のアクションでは`find`を使う」**という現在の実装は正しく、非常に効率的です。その仕組みを3つのステップで見ていきましょう。

### Step 1: `reservations#new` アクション（文字列 → オブジェクトへの変換）

1.  ユーザーが座席図で「A-1」をクリックすると、JavaScriptによって `/stores/21/seats/A-1/reservations/new` というURLにアクセスします。
2.  `ReservationsController`の`new`アクションが呼ばれます。
3.  `params[:seat_id]` には、URLから文字列の `"A-1"` が入っています。
4.  以下のコードで、`seat_number`が"A-1"の`Seat`オブジェクトを探し出し、`@seat`インスタンス変数に格納します。この`@seat`オブジェクトは、データベース上の**整数ID**（例: `id: 42`）を持っています。

    ```ruby
    # reservations_controller.rb (newアクション)
    @seat = Seat.find_by(seat_number: params[:seat_id], store_id: params[:store_id])
    ```

### Step 2: `new.html.erb` ビュー（URLの魔法）

1.  `new`アクションは、`new.html.erb`というビューを表示します。
2.  このビューの中にある予約フォームは、以下のように`url`オプションを持っています。

    ```erb
    <%# new.html.erb %>
    <%= form_with model: @reservation, url: confirm_store_seat_reservations_path(@store, @seat), ... %>
    ```

3.  ここが**最重要ポイント**です。RailsのURLヘルパー (`confirm_store_seat_reservations_path`) は、引数に`@seat`のような**オブジェクト**を渡されると、そのオブジェクトの**整数ID**（`42`）を使ってURLを自動的に生成します。
4.  その結果、ブラウザに表示されるフォームの送信先URLは、`/stores/21/seats/42/reservations/confirm` となります。"A-1"はここで整数IDに置き換わっています。

### Step 3: `confirm` / `create` アクション（整数IDの利用）

1.  ユーザーがフォームを送信すると、ブラウザはStep 2で生成されたURL（`/stores/21/seats/42/...`）にリクエストを送ります。
2.  `confirm`や`create`アクションが呼ばれます。
3.  `params[:seat_id]` には、URLから文字列の `"42"` が入っています。
4.  したがって、以下のコードは正しく動作します。`Seat.find("42")`は、IDが42の`Seat`オブジェクトを正しく見つけ出します。

    ```ruby
    # reservations_controller.rb (createアクション)
    @seat = Seat.find(params[:seat_id]) # params[:seat_id] は "42" なので問題ない
    ```

---

## 結論：なぜAIは間違えたのか？

AIは、Step 2の「**URLヘルパーがオブジェクトを整数IDに変換してURLを生成する**」というRailsの賢い挙動を見落としていました。`new`アクションのURLに"A-1"が含まれていたため、その後のリクエストでも"A-1"が引き継がれると早合点してしまったのです。

**正しい理解:**
「予約フローでデータが引き継がれる」というのは、`@seat`オブジェクトがリクエストをまたいで直接渡されるわけではありません。
**`new`アクションで取得した`@seat`オブジェクトを元に、ビューが整数IDを含んだURLを生成し、次のリクエストはそのURLを通じて整数IDを`params`として受け取る**、という流れが正解です。

---

## 補足：`reservation_params`の冗長なコードについて

会話の序盤で、`reservation_params`内の`.merge(seat_id: params[:seat_id])`が不要であるという話も出ました。これも上記の流れを理解すると明確になります。

`create`アクションでは、`params`とは別に、以下のように`seat`を明示的にセットしています。

```ruby
# createアクション
@reservation = Reservation.new(reservation_params)
@reservation.seat = @seat # ここで正しいseat_idがセットされる
```

`@reservation.seat = @seat` のようにオブジェクトを直接代入すると、Railsは自動的に`@reservation.seat_id`に`@seat`の整数IDをセットします。そのため、`reservation_params`の`merge`で`seat_id: "A-1"`のような不正確な値を渡したとしても、この行で正しく上書きされるため、結果的に`merge`は無意味（かつ冗長）だった、ということです。
