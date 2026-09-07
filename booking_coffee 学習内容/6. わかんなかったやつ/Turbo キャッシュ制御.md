# 解説：Turbo キャッシュ制御

---

## コード（`layouts/application.html.erb`）

```html
<meta name="turbo-cache-control" content="no-cache">
```

全ページ共通のレイアウトファイルに書いてあるので、アプリ全体に適用される。

---

## なぜこれが必要になったか（問題の経緯）

### Turboのキャッシュとは

Turboはページ遷移を速くするために、一度開いたページのHTMLを**ブラウザ内に一時保存（キャッシュ）する**。

別のページに移動して戻ってきたとき、サーバーに問い合わせず保存しておいたHTMLをそのまま表示する。その直後に `turbo:load` が発火して、通常の初期化処理が走る。

### flatpickr と組み合わさって起きた問題

flatpickrは初期化時に、ユーザーに見せる用の表示入力欄（`altInput`）をHTMLに追加する。

```
初回アクセス → flatpickrが altInput を1つ追加 → 正常
    ↓
別ページへ移動 → 戻ってくる
    ↓
Turboが古いHTMLを表示（altInputが1つある状態）
    ↓
turbo:load が発火 → seats_index.js がまたflatpickrを初期化
    ↓
altInput がもう1つ追加される → 日時欄が2つに！
    ↓
繰り返すたびに altInput が増えていく
```

戻るたびに日時の入力欄が増殖してしまうバグが起きていた。

---

## `turbo-cache-control: no-cache` で解決

```html
<meta name="turbo-cache-control" content="no-cache">
```

Turboに「**このページはキャッシュしないでください**」と伝えるメタタグ。

これを書くと、戻ってきたときに必ずサーバーから新しいHTMLを取得するようになる。

```
別ページへ移動 → 戻ってくる
    ↓
Turboがキャッシュを使わずサーバーから新しいHTMLを取得
    ↓
古い altInput は残っていない（新しいHTMLなので）
    ↓
turbo:load → flatpickrを初期化 → altInput が1つだけ追加される → 正常
```

---

## まとめ

| | キャッシュあり（デフォルト） | `no-cache` |
|---|---|---|
| 戻ったときのHTML | Turboが保存した古いHTML | サーバーから取得した新しいHTML |
| altInputの状態 | 古いものが残ったまま | きれいな状態から始まる |
| 結果 | 戻るたびに日時欄が増殖 | 常に正常な1つだけ |

Turboのキャッシュ機能とflatpickrの初期化が干渉してバグが起きたため、キャッシュを無効化して対処した。
