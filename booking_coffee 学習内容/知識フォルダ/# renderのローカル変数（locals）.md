# renderのローカル変数（locals）

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

## 渡さなかった場合

パーシャルでローカル変数を使っているのに、呼び出す側で渡さなかった場合は `undefined local variable` エラーになる。

そのため、パーシャルを複数箇所から呼び出す場合は、変数が渡されない場合も考慮して以下のように書くことがある。

```erb
<% confirm_mode = local_assigns.fetch(:confirm_mode, false) %>
```

`local_assigns` はパーシャルに渡されたローカル変数の一覧。渡されなかった場合のデフォルト値を `false` にしている。







<% confirm_mode = local_assigns.fetch(:confirm_mode, false) %> というコードについてですね。

これは、Railsのパーシャル（ビューの部品）をより安全で柔軟に使うための、非常に優れたテクニックです。詳しく解説しますね。

結論：これは何？
一言で言うと、「もし親からお小遣い（confirm_mode）をもらえなくても、エラーで止まらずに、自分でお財布に0円（false）を入れておく」 という、パーシャルのための賢い**安全装置（セーフティネット）**です。

なぜこのコードが必要なのか？
あなたのプロジェクトでは、同じ「間取り図パーシャル」を2つの異なる場所から呼び出しています。

予約フォーム画面 (stores#show):

<%= render "stores/kuramae_floor" %>
この時、パーシャルに何もデータを渡していません。
予約確認画面 (reservations#confirm):

<%= render "stores/kuramae_floor", confirm_mode: true %>
この時、confirm_mode: true というデータを渡しています。
もし、パーシャルの中でいきなり unless confirm_mode のようなコードを書くと、1番のケース（何もデータが渡されていない時）に undefined local variable or method 'confirm_mode' というエラーが発生してしまいます。「confirm_modeなんていう変数は知らないよ！」と怒られてしまうわけです。

この問題を解決するのが、ご質問のコードです。

コードの分解ショー
<% confirm_mode = local_assigns.fetch(:confirm_mode, false) %>

この一行を、パーツごとに分解してみましょう。

local_assigns

これは、パーシャルに render を通じて渡された**すべてのローカル変数が入っている、特別なハッシュ（辞書）**です。
confirm_mode: true を渡せば、local_assigns の中身は { confirm_mode: true } のようになります。
何も渡さなければ、local_assigns は空っぽ {} です。
.fetch(:confirm_mode, false)

これは、ハッシュから安全に値を取り出すためのメソッドです。2つの引数を取ります。
第1引数 (:confirm_mode): 「local_assigns の中から :confirm_mode というキーを探して、その値を取り出してください」という指示です。
第2引数 (false): 「もし :confirm_mode というキーが見つからなかった場合は、代わりにこの false を使ってください」というデフォルト値の指定です。これが安全装置の役割を果たします。
confirm_mode = ...

.fetch の結果（true または false）を、confirm_mode という新しいローカル変数に代入しています。
実際の動き
この一行があることで、パーシャルは呼び出され方によって以下のように賢く動作します。

render "...", confirm_mode: true で呼び出された場合:

local_assigns は { confirm_mode: true } を持っています。
.fetch(:confirm_mode, false) は :confirm_mode を見つけ、その値である true を返します。
結果、confirm_mode 変数に true が代入されます。
render "..." (引数なし) で呼び出された場合:

local_assigns は空っぽです。
.fetch(:confirm_mode, false) は :confirm_mode を見つけられないので、デフォルト値の false を返します。
結果、confirm_mode 変数に false が代入されます。
まとめ
この一行のおかげで、パーシャルはその後のコードで confirm_mode という変数が必ず存在することを保証できます。

渡されていれば true が入る。
渡されていなければ false が入る。
これにより、呼び出し元が confirm_mode を渡すか渡さないかを気にすることなく、パーシャル側で安全に条件分岐のロジックを書くことができるのです。非常にDRY（Don't Repeat Yourself）で、堅牢なコードを書くための素晴らしいテクニックですね。
