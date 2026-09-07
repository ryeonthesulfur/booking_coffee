# 解説：`asset_path`

---

## 何をするのか

`app/assets/` フォルダに置いた画像などのファイルへの**正しいURLを生成する**Railsのヘルパーメソッド。

```erb
<%= asset_path("wallPaper_2.jpg") %>
```

これを書くと、Railsが `app/assets/images/wallPaper_2.jpg` のURLを自動で解決して出力してくれる。

---

## なぜ直接パスを書かずに使うのか

`/assets/wallPaper_2.jpg` のように直接書いてしまうと、本番環境で問題が起きる。

Railsは本番環境で**アセットフィンガープリント**という仕組みを使い、ファイル名にハッシュ値を付加する。

```
開発環境：/assets/wallPaper_2.jpg
本番環境：/assets/wallPaper_2-a1b2c3d4e5f6....jpg  ← ハッシュが付く
```

直接パスを書くと本番環境でファイルが見つからなくなる。`asset_path` を使えばRailsが環境に合わせた正しいURLを自動で生成してくれる。

---

## このアプリでの使用箇所

背景画像をHTMLの `style` 属性にインラインで書く際に使っている。CSSファイルからではなくビューから直接背景画像を指定するためにこの書き方が必要になった。

| ファイル | 使用箇所 |
|---|---|
| `reservations/index.html.erb` | 予約履歴一覧の背景画像 |
| `reservations/show.html.erb` | 予約詳細の背景画像 |
| `reservations/confirm.html.erb` | 予約確認画面の背景画像 |

```erb
<%# 予約履歴一覧（reservations/index.html.erb） %>
<main class="reservation-list-main"
  style="background-image: url('<%= asset_path("wallPaper_2.jpg") %>');
         background-size: cover;
         background-position: center;
         background-attachment: fixed;
         box-shadow: inset 0 0 0 1000px rgba(81, 81, 81, 0.5);">
```

---

## `asset_path` と `image_tag` の違い

| メソッド | 用途 | 出力 |
|---|---|---|
| `asset_path("〇〇.jpg")` | URLの文字列だけ取り出したいとき | `/assets/〇〇-abc123.jpg` |
| `image_tag("〇〇.jpg")` | `<img>` タグごと生成したいとき | `<img src="/assets/〇〇-abc123.jpg">` |

`style` 属性の `url()` の中にはURLの文字列だけ入れる必要があるため、タグごと出力する `image_tag` は使えない。

### なぜ背景画像に `<img>` タグを使わないのか

`<img>` タグで背景っぽく見せることは不可能ではないが、`position: absolute` で絶対配置して `z-index` で重なり順を調整する…といった追加のCSSが必要になり複雑になる。

`background-image` なら「この要素の背景に画像を敷く」という意図が1行で書けるので、背景画像には素直に `background-image` を使うのが一般的。

---

## まとめ

`asset_path` は「`app/assets/` にある画像ファイルへの正しいURLを、本番環境でも壊れずに生成する」ためのRailsヘルパー。インラインスタイルで背景画像を指定するときに使う。
