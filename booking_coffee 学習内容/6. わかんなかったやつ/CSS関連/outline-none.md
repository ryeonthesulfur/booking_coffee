# 解説：`outline: none;`

---

## outline とは何か

`outline` は、要素がフォーカス（クリックやタブキーで選択）されたときにブラウザが自動で表示する**外側の枠線**のこと。

`border` と似ているが、レイアウトには影響しない（要素のサイズが変わらない）という違いがある。

```
クリックしたとき → ブラウザが青や黒の枠線を自動で付ける ← これが outline
```

---

## `outline: none` で何が変わるか

ブラウザが自動で付けるこの枠線を**非表示にする**。

```css
/* ブラウザデフォルト → フォーカス時に青い枠線が出る */
input:focus { outline: 2px solid blue; }  ← ブラウザが勝手にやる

/* outline: none を書くと枠線が消える */
.num-people-input {
  outline: none;
}
```

---

## なぜ消すのか

ブラウザのデフォルトの outline は見た目がデザインと合わないことが多い。  
このアプリでは代わりに `border-color` と `box-shadow` でフォーカス時のスタイルを自分で定義しているため、デフォルトの outline は不要で消している。

```css
/* outline を消した上で、独自のフォーカススタイルを定義している */
.num-people-input {
  outline: none;               /* ブラウザデフォルトの枠線を消す */
  transition: border-color 0.2s;
}

.form-input:focus {
  border-color: #92400e;                          /* 代わりにborderの色を変える */
  box-shadow: 0 0 0 3px rgba(146, 64, 14, 0.1);  /* さらに外側にぼかし枠を付ける */
}
```

---

## このアプリでの使用箇所

| ファイル | セレクタ | 要素 |
|---|---|---|
| `reservation_form.css` | `.num-people-input` | 人数選択の `<select>` |
| `devise_style.css` | （ログイン・登録フォームの input） | テキスト入力欄 |

---

## まとめ

`outline: none` は「ブラウザが自動で付けるフォーカス枠線を消す」指定。  
消した上で、`border` や `box-shadow` を使って独自のフォーカス表現に置き換えるのがセットの使い方。
