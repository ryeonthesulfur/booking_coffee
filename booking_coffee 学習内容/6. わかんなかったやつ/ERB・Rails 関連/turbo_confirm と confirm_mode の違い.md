# 解説：`turbo_confirm` と `confirm_mode` の違い

名前が似ているが、**まったく別の機能**。

---

## turbo_confirm

**Turboの組み込み機能**。ボタンを押したときにブラウザの確認ダイアログを表示する。

```erb
<%= button_to "この予約をキャンセルする", reservation_path(reservation), method: :delete,
      data: { turbo_confirm: "本当にキャンセルしますか？" },
      class: "cancel-btn" %>
```

`data: { turbo_confirm: "..." }` を付けるだけで、ボタンを押した瞬間にブラウザがこんなダイアログを出す。

```
┌─────────────────────────────┐
│  本当にキャンセルしますか？  │
│                             │
│    [キャンセル]  [OK]       │
└─────────────────────────────┘
```

「OK」を押したときだけリクエストが送られる。「キャンセル」を押すと何も起きない。

### このアプリでの使用箇所

`reservations/_reservation_actions.html.erb` の各ボタンに使っている。

| ボタン | ダイアログのメッセージ |
|---|---|
| 退店する | 「退店しますか？」 |
| チェックイン | 「チェックインしますか？」 |
| この予約をキャンセルする | 「本当にキャンセルしますか？」 |

---

## confirm_mode

**自分で作ったローカル変数**。間取り図パーシャルに「今は確認モードか？」を伝えるための合言葉。

```erb
<%# 確認画面・詳細画面 → confirm_mode: true を渡す %>
<%= render "stores/kuramae_floor", confirm_mode: true %>

<%# 間取り図ページ → confirm_mode: false を渡す %>
<%= render "stores/kuramae_floor", confirm_mode: false %>
```

パーシャル側ではこの値を使って表示内容を切り替える。

```erb
<%# 確認モードのときだけグレイアウト用のJSを読み込む %>
<% if confirm_mode %>
  ...
<% end %>

<%# 確認モードのときは座席選択ボタンを非表示にする %>
<% unless confirm_mode %>
  <div class="shop-subtitle">ご希望の座席をタップして予約に進んでください。</div>
<% end %>
```

### このアプリでの使用箇所

| ページ | 渡す値 | 効果 |
|---|---|---|
| 間取り図ページ（stores#show） | `confirm_mode: false` | 座席選択ボタンなどを表示する |
| 予約確認画面（reservations#confirm） | `confirm_mode: true` | 選択不可にして選んだ座席だけハイライト |
| 予約詳細画面（reservations#show） | `confirm_mode: true` | 同上 |

---

## まとめ

| | turbo_confirm | confirm_mode |
|---|---|---|
| 何者か | Turboの組み込み機能 | 自分で作ったローカル変数 |
| 何をするか | ボタン押下時に確認ダイアログを出す | パーシャルの表示内容を切り替える |
| どこに書くか | `data: { turbo_confirm: "..." }` | `render "...", confirm_mode: true/false` |
| 「confirm」の意味 | 「本当に実行しますか？」の確認 | 「今は確認画面モードですか？」の合言葉 |
