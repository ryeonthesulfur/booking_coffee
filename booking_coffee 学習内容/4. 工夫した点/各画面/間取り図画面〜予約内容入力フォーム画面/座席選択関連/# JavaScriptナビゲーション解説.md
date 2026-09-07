# JavaScriptナビゲーション解説: `window.location.href` とは？

こんにちは！
以前のやり取りでのあなたの理解は、まさにその通りで完璧です！

> てことは実質HTMLの予約フォームへのボタンはid を格納した上でのイベント発火の役割ってことね？
> そうです。ボタンを押す → store_idとseat_numberを読んでURLを作る → そのURLに飛ぶ。という流れです。

このドキュメントでは、その流れの核心部分である `window.location.href` が何をしているのかを、改めて公式な解説としてまとめました。

---

## 1. `window.location.href` の分解ショー

`window.location.href = \`/stores/${storeId}/seats/${seatNumber}\`;`

この一行は、JavaScriptを使ってブラウザに「ページを移動しろ！」と命令するための、最も標準的な書き方です。一つずつ分解してみましょう。

-   **`window`**
    -   ブラウザの「ウィンドウ全体」を指す、JavaScriptの親玉のようなオブジェクトです。今あなたが見ているWebページも、この `window` の中に存在します。

-   **`location`**
    -   `window` が持っている機能の一つで、「現在地の情報」を管理しています。具体的には、ブラウザのアドレスバーに表示されているURLの情報です。

-   **`href`**
    -   `location` が持っている情報の一つで、「URLそのもの（Hypertext Reference）」を指します。
    -   この `href` には2つの使い方があります。
        1.  **読み取り:** `const currentUrl = window.location.href;` のように使うと、現在のページのURLを取得できます。
        2.  **書き込み:** `window.location.href = "新しいURL";` のように、**新しいURLを代入する**と、ブラウザはそのURLに**ページを移動（ナビゲート）**します。

-   **`= \`/stores/...\``**
    -   これが「書き込み」の部分です。
    -   バッククォート（ `` ` `` ）で囲まれた文字列は「テンプレートリテラル」と呼ばれ、`${...}` の形で文字列の中に変数を埋め込むことができます。
    -   `storeId` と `seatNumber` の値を使って `/stores/1/seats/A-1/reservations/new` のようなURL文字列を動的に生成し、それを `window.location.href` に代入しています。

**結論として、この一行は「JavaScriptで組み立てたURLに、ブラウザをジャンプさせる」という処理を行っています。**

---

## 2. `<a>` タグとの比較

あなたの「これがaタグのhref 属性の役割してんの？」という質問は、的を射ています。

-   **HTMLの `<a>` タグ:**
    ```html
    <a href="/stores/1/seats/A-1/reservations/new">予約する</a>
    ```
    -   ユーザーが**クリックする**ことで、`href` に指定されたURLへのページ移動が起こります。
    -   URLはHTMLに直接書かれており、静的です。

-   **JavaScriptの `window.location.href`:**
    ```javascript
    window.location.href = "/stores/1/seats/A-1/reservations/new";
    ```
    -   このコードが**実行される**ことで、指定されたURLへのページ移動が起こります。
    -   URLをJavaScript内で動的に組み立てられるため、ユーザーの選択に応じて行き先を変える、といった柔軟な処理が可能です。

`toReservation_form.js` のコードは、まさにこのJavaScriptの利点を活かしています。
`<button>` という「ただのボタン」にクリックイベントを仕込み、ユーザーが選択したラジオボタンの `value` を読み取ってから、動的に行き先のURLを決定しているのです。

---

## 3. Railsとの連携フロー

このJavaScriptが実行された後、裏側では以下の流れが起こります。

1.  **ブラウザ:** `window.location.href` に代入されたURL（例: `/stores/1/seats/A-1/reservations/new`）に対して、**GETリクエスト**をサーバーに送信します。

2.  **Rails (Router):** 受け取ったリクエストのURLを見て、`config/routes.rb` の定義と照合します。
    -   `GET /stores/:store_id/seats/:seat_id/reservations/new` というパターンに一致することを確認します。
    -   このパターンは `reservations#new` アクションに紐付けられているため、処理を `ReservationsController` に渡します。

3.  **Rails (Controller):** `reservations_controller.rb` の `new` アクションが実行されます。
    -   URLから `params[:store_id]` (値: `"1"`) と `params[:seat_id]` (値: `"A-1"`) を受け取ります。
    -   `params[:seat_id]` は DB の id ではなく座席番号の文字列なので `find_by` で検索します。
    ```ruby
    @seat = Seat.find_by(seat_number: params[:seat_id], store_id: params[:store_id])
    @store = Store.find(params[:store_id])
    ```

4.  **Rails (View):** コントローラーから渡されたインスタンス変数を使って、`app/views/reservations/new.html.erb` のHTMLを生成します。

5.  **ブラウザ:** サーバーから送られてきたHTMLを受け取り、画面に表示します。これで、ユーザーは予約フォームのページを見ることができます。