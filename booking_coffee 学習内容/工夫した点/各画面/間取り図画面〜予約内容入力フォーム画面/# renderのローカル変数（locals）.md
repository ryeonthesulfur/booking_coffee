# renderのローカル変数（locals）    「confirm.html.erb」    260906

## 何をするのか

`render` でパーシャルを呼び出すとき、そのパーシャルに変数を渡すことができる。  
渡した変数はそのパーシャルの中だけで使える。

---

## 書き方

### 呼び出す側（ビュー）

```erb
<%= render "stores/kuramae_floor", confirm_mode: true %>
```

`confirm_mode: true` がローカル変数。  
`confirm_mode` という名前で `true` という値を渡している。

---

### 受け取る側（パーシャル）

```erb
<% unless confirm_mode %>
  <div class="shop-subtitle">ご希望の座席をタップして予約に進んでください。</div>
<% end %>
```

パーシャルの中では `confirm_mode` をそのまま変数として使える。  
`true` が渡されているので `unless confirm_mode` の中身は表示されない。

---

## 「confirm_mode」とは何か？（命名の意図）

`confirm_mode` という名前は、**私が勝手に付けた名前**です。
これは、パーシャル（部品化されたビュー）に「今、あなたはどのモードで表示されていますか？」を教えるための**「合言葉」**だと考えてください。

### 比喩：同じ俳優が「通常モード」と「スパイモード」を演じ分ける

-   **パーシャル（間取り図）**: 俳優
-   **`confirm_mode`**: 監督からの指示書（合言葉）

1.  **予約フォーム画面 (`stores#show`) から呼び出す場合**
    -   監督（ビュー）は、俳優（パーシャル）に何も指示書を渡さずに舞台に上げます。
    -   俳優は「指示がないな。じゃあ通常モードで、セリフも全部言おう」と考え、「ご希望の座席を〜」というセリフを喋ります。
    ```erb
    <%= render "stores/kuramae_floor" %>
    ```

2.  **予約確認画面 (`reservations#confirm`) から呼び出す場合**
    -   監督（ビュー）は、俳優（パーシャル）に `confirm_mode: true` という「スパイモードで！」と書かれた指示書を渡します。
    -   俳優は指示書を見て「なるほど、今はスパイモードか。余計なセリフは喋らないようにしよう」と考え、「ご希望の座席を〜」というセリフを言わずに黙っています。
    ```erb
    <%= render "stores/kuramae_floor", confirm_mode: true %>
    ```

`confirm_mode` という名前は、「今は確認モードですか？」という意味で付けました。
`true` を渡すことで「はい、確認モードです」とパーシャルに伝え、
パーシャル側で `unless confirm_mode` (確認モードでなければ) という条件分岐を使って表示内容を切り替えているのです。

この名前は `is_confirm: true` や `for_confirmation: true` など、何でも構いません。重要なのは、**「呼び出す側と受け取る側で、同じ合言葉を使う」**ということです。

---

## なぜこれを使ったか

予約フォーム画面（stores#show）と予約確認画面（reservations#confirm）で同じ間取り図パーシャルを使いたかった。

ただし確認画面では「ご希望の座席をタップしてください」というサブタイトルや「予約を進める」ボタンは不要。

3店舗分のパーシャルを複製して確認画面専用を作るのは無駄が多いため、ローカル変数で表示を切り替える方法を採用した。

---

## インスタンス変数（@変数）との違い

| | インスタンス変数（@変数） | ローカル変数（render で渡す） |
|---|---|---|
| 定義場所 | コントローラー | renderの引数 |
| 使える範囲 | そのアクションに対応するビュー全体 | renderで指定したパーシャルの中だけ |
| 例 | `@store`, `@seat` | `confirm_mode` |

---

## 渡さなかった場合（本アプリには導入していない）

パーシャルでローカル変数を使っているのに、呼び出す側で渡さなかった場合は `undefined local variable` エラーになる。

そのため、パーシャルを複数箇所から呼び出す場合は、変数が渡されない場合も考慮して以下のように書くことがある。

```erb
<% confirm_mode = local_assigns.fetch(:confirm_mode, false) %>
```

`local_assigns` はパーシャルに渡されたローカル変数の一覧。渡されなかった場合のデフォルト値を `false` にしている。

---

### コードの分解

```erb
<% confirm_mode = local_assigns.fetch(:confirm_mode, false) %>
```

**`local_assigns`**

パーシャルに `render` を通じて渡された、すべてのローカル変数が入っている特別なハッシュ（辞書）。

- `confirm_mode: true` を渡せば → `{ confirm_mode: true }`
- 何も渡さなければ → `{}`（空）

**`.fetch(:confirm_mode, false)`**

ハッシュから安全に値を取り出すメソッド。

| 引数 | 役割 |
|---|---|
| 第1引数 `:confirm_mode` | このキーを探して値を取り出す |
| 第2引数 `false` | キーが見つからなかった場合のデフォルト値 |

**`confirm_mode = ...`**

`.fetch` の結果（`true` または `false`）を `confirm_mode` 変数に代入する。

---

### 実際の動き

| 呼び出し方 | `local_assigns` の中身 | `confirm_mode` の値 |
|---|---|---|
| `render "...", confirm_mode: true` | `{ confirm_mode: true }` | `true` |
| `render "..."` （引数なし） | `{}` | `false`（デフォルト値） |

---

### まとめ

この一行があると、パーシャルは呼び出され方に関係なく `confirm_mode` 変数が**必ず存在することを保証**できる。

- 渡されていれば → その値（`true`）が入る
- 渡されていなければ → デフォルトの `false` が入る

本アプリでは呼び出す側が必ず `confirm_mode: true` か `confirm_mode: false` を明示しているため、このコードは不要。




