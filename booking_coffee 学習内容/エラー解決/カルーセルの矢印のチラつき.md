# Turboとチラつきの問題と解決

---

## ① カレンダー（Flatpickr）がページ遷移後に開けない問題

### 原因

Rails 7以降はデフォルトで **Turbo** という仕組みが有効になっています。

通常のページ遷移では、ブラウザがページ全体を再読み込みするため `DOMContentLoaded` というイベントが毎回発火します。JavaScriptはこのイベントをきっかけに動き出します。

しかしTurboは、リンクをクリックしたときにページ全体をリロードせず、サーバーから取得したHTMLで `<body>` の中身だけを差し替えます。このため `DOMContentLoaded` が発火しません。

結果として、Flatpickrの初期化コードが動かず、カレンダーが機能しない状態になっていました。

```
【通常の遷移】
リンクをクリック → ページ全体をリロード → DOMContentLoaded 発火 → JS動作 ✅

【Turboの遷移】
リンクをクリック → <body>の中身だけ差し替え → DOMContentLoaded 発火しない → JS動作しない ❌
```

### 解決策

`DOMContentLoaded` の代わりに **`turbo:load`** イベントを使うように変更しました。

`turbo:load` はTurboが画面を切り替えるたびに発火するイベントです。これにより、通常の遷移でもTurboによる遷移でも、毎回Flatpickrが正しく初期化されるようになりました。

```javascript
// 変更前
document.addEventListener('DOMContentLoaded', function () {

// 変更後
document.addEventListener('turbo:load', function () {
```

---

## ② カルーセルの矢印ボタンがリロード時に一瞬チラつく問題

### 原因

カルーセルの矢印ボタンは、JavaScriptが動いた後に `disabled` 属性をセットし、CSSの `:disabled` セレクターで非表示にする設計でした。

しかしブラウザは、HTMLの読み込み → CSSの適用 → JSの実行 という順番で動きます。JSが動くまでの一瞬、まだ `disabled` がセットされていない状態のボタンが表示されてしまっていました。

```
① HTMLが読み込まれる → ボタンが表示される（disabled なし）
② CSSが適用される   → :disabled に該当なし（まだ disabled がない）
③ JSが動く          → disabled をセット
④ CSSが反応         → display: none で非表示

→ ①〜③の一瞬、ボタンが見えてしまう（チラつき）
```

### 解決策

HTMLのボタンタグに最初から `disabled` 属性を直接書いておくことで解決しました。

JSが動く前から `disabled` 状態になっているため、CSSの `:disabled` が即座に効き、チラつきが起きなくなります。JSは引き続き必要に応じてボタンを有効化・無効化します。

```html
<!-- 変更前 -->
<button class="seats-carousel__btn seats-carousel__btn--left" id="carousel-btn-left">

<!-- 変更後 -->
<button class="seats-carousel__btn seats-carousel__btn--left" id="carousel-btn-left" disabled>
```

---

## まとめ

| 問題 | 原因 | 解決策 |
|------|------|--------|
| カレンダーが開けない | TurboがDOMContentLoadedを発火しない | turbo:load イベントに変更 |
| 矢印ボタンのチラつき | JSが動く前はdisabledがセットされていない | HTMLに最初からdisabledを記述 |

どちらも「JSが動くタイミングのズレ」が根本的な原因でしたが、解決の方向性は異なります。
カレンダーはJSのイベント検知を変えることで解決し、ボタンはHTMLの初期状態を変えることで解決しました。
