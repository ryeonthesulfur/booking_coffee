# 解説: `local_assigns.fetch` - パーシャルの安全装置

`<% confirm_mode = local_assigns.fetch(:confirm_mode, false) %>` というコードについてですね。

これは、Railsのパーシャル（ビューの部品）をより安全で柔軟に使うための、非常に優れたテクニックです。詳しく解説します。

---

### 結論：これは何？

一言で言うと、「もし親からお小遣い（`confirm_mode`）をもらえなくても、エラーで止まらずに、自分でお財布に0円（`false`）を入れておく」 という、パーシャルのための賢い**安全装置（セーフティネット）**です。

---

### なぜこのコードが必要なのか？

あなたのプロジェクトでは、同じ「間取り図パーシャル」を2つの異なる場所から呼び出しています。

1.  **予約フォーム画面 (`stores#show`):**
    ```erb
    <%= render "stores/kuramae_floor" %>
    ```
    この時、パーシャルに何もデータを渡していません。

2.  **予約確認画面 (`reservations#confirm`):**
    ```erb
    <%= render "stores/kuramae_floor", confirm_mode: true %>
    ```
    この時、`confirm_mode: true` というデータを渡しています。

もし、パーシャルの中でいきなり `unless confirm_mode` のようなコードを書くと、1番のケース（何もデータが渡されていない時）に `undefined local variable or method 'confirm_mode'` というエラーが発生してしまいます。「`confirm_mode` なんていう変数は知らないよ！」と怒られてしまうわけです。

この問題を解決するのが、ご質問のコードです。

---

### コードの分解ショー

```erb
<% confirm_mode = local_assigns.fetch(:confirm_mode, false) %>
```

この一行を、パーツごとに分解してみましょう。

-   **`local_assigns`**
    -   これは、パーシャルに `render` を通じて渡された**すべてのローカル変数が入っている、特別なハッシュ（辞書）**です。
    -   `confirm_mode: true` を渡せば、`local_assigns` の中身は `{ confirm_mode: true }` のようになります。
    -   何も渡さなければ、`local_assigns` は空っぽ `{}` です。

-   **`.fetch(:confirm_mode, false)`**
    -   これは、ハッシュから安全に値を取り出すためのメソッドです。2つの引数を取ります。
    -   **第1引数 (`:confirm_mode`)**: 「`local_assigns` の中から `:confirm_mode` というキーを探して、その値を取り出してください」という指示です。
    -   **第2引数 (`false`)**: 「もし `:confirm_mode` というキーが見つからなかった場合は、代わりにこの `false` を使ってください」というデフォルト値の指定です。これが安全装置の役割を果たします。

-   **`confirm_mode = ...`**
    -   `.fetch` の結果（`true` または `false`）を、`confirm_mode` という新しいローカル変数に代入しています。

---

### 実際の動き

この一行があることで、パーシャルは呼び出され方によって以下のように賢く動作します。

-   **`render "...", confirm_mode: true` で呼び出された場合:**
    1.  `local_assigns` は `{ confirm_mode: true }` を持っています。
    2.  `.fetch(:confirm_mode, false)` は `:confirm_mode` を見つけ、その値である `true` を返します。
    3.  結果、`confirm_mode` 変数に `true` が代入されます。

-   **`render "..."` (引数なし) で呼び出された場合:**
    1.  `local_assigns` は空っぽです。
    2.  `.fetch(:confirm_mode, false)` は `:confirm_mode` を見つけられないので、デフォルト値の `false` を返します。
    3.  結果、`confirm_mode` 変数に `false` が代入されます。

---

### まとめ

この一行のおかげで、パーシャルはその後のコードで `confirm_mode` という変数が必ず存在することを保証できます。

-   渡されていれば `true` が入る。
-   渡されていなければ `false` が入る。

これにより、呼び出し元が `confirm_mode` を渡すか渡さないかを気にすることなく、パーシャル側で安全に条件分岐のロジックを書くことができるのです。非常にDRY（Don't Repeat Yourself）で、堅牢なコードを書くための素晴らしいテクニックですね。