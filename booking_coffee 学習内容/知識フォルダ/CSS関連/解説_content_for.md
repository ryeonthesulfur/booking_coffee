# 解説：`content_for` とは

---

## 一言で言うと

**特定のページだけで使うHTML（CSSやJSの読み込みなど）を、レイアウトの指定した場所に差し込む仕組み。**

---

## 背景：レイアウトファイルの仕組み

Railsでは `app/views/layouts/application.html.erb` が全ページ共通の外枠になっている。

```erb
<!-- application.html.erb（共通レイアウト） -->
<html>
  <head>
    <%= yield :head %>  ← ここに差し込まれる
  </head>
  <body>
    <%= yield %>        ← 各ページのメインコンテンツ
  </body>
</html>
```

`yield :head` が「ここに差し込んでいいよ」という受け口。

---

## `content_for` の書き方

差し込みたいページ側でこう書く：

```erb
<% content_for :head do %>
  <!-- ここに書いたものが yield :head の場所に入る -->
  <link rel="stylesheet" href="flatpickr.css">
  <script src="flatpickr.js"></script>
<% end %>
```

`:head` の部分は名前（シンボル）で、`yield :head` と対応している。

---

## なぜ使うのか

全ページ共通の `<head>` にすべてのCSSやJSを読み込むと、使わないページでも読み込まれて無駄になる。

`content_for` を使えば「このページだけ必要なもの」をそのページだけで読み込める。

```
トップ画面（stores/index.html.erb）
　→ flatpickr が必要 → content_for :head で読み込む

予約一覧画面（reservations/index.html.erb）
　→ flatpickr は不要 → 読み込まない
```

---

## 今回の例

```erb
<% content_for :head do %>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
  <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
  <script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/ja.js"></script>
  <%= javascript_include_tag "seats_index" %>
<% end %>
```

トップ画面の検索バーで日時カレンダー（flatpickr）を使うために、このページだけで読み込んでいた。
検索バーを削除したため、この6行も不要になり削除した。
