# 解説：`font-family: inherit;`

---

## 何をするのか

**親要素から `font-family`（フォントの種類）を引き継ぐ**という指定。

`inherit` は「継承する」という意味の英単語で、CSSでは「親要素と同じ値を使う」という意味になる。

---

## なぜわざわざ書く必要があるのか

ブラウザには**デフォルトのスタイル**があり、`<select>` や `<button>` などのフォーム部品は、何も指定しないとブラウザが独自のフォントを適用してしまう。

そのため、ページ全体で設定しているフォントを指定しても、これらの部品だけ**フォントが変わってしまう**という問題が起きる。

```css
/* ❌ フォントが揃わない状態 */
body {
  font-family: 'Noto Sans JP', sans-serif;
}

/* select や button はブラウザのデフォルトフォントのまま → ページ全体と見た目がバラバラになる */
```

---

## `font-family: inherit` で解決する

```css
/* ✅ 親要素のフォントを引き継ぐ */
.num-people-input {
  font-family: inherit;  /* ← body に設定したフォントが適用される */
}

.reservation-submit-btn {
  font-family: inherit;  /* ← 同様 */
}
```

これを書くことで「body に設定したフォントをそのまま使ってください」と伝えられ、ページ全体のフォントが統一される。

---

## このアプリでの使用箇所

| ファイル | セレクタ | 要素 |
|---|---|---|
| `reservation_form.css` | `.num-people-input` | 人数選択の `<select>` |
| `reservation_form.css` | `.reservation-submit-btn` | 予約送信ボタン |
| `reservation_info.css` | （予約情報系） | フォーム部品 |
| `top_view.css` | （トップ画面系） | フォーム部品 |

---

## まとめ

`font-family: inherit` は「フォントをページ全体に揃えるためのおまじない」。  
`<select>` や `<button>` はブラウザのデフォルトで独自フォントになるため、明示的に書かないと見た目がバラバラになる。
