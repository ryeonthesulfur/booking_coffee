# Turbo遷移後にflatpickr（カレンダー）が開けないバグ

---

## 症状

- 間取り図ページ（`stores/show`）にリンク経由で遷移すると、カレンダーが開けない
- ページを直接リロード（Cmd+R）すると正常に開ける
- コンソールにエラーは出ない

---

## 原因

### Turbo Drive の仕組みとCDN読み込みのタイミング問題

Railsでは `<%= link_to %>` によるページ遷移は **Turbo Drive** が処理する。
Turbo Drive は通常のフルリロードではなく、**差分更新**でページを切り替える。

具体的には：
1. 新しいページの HTML を取得する
2. `<head>` の差分を検出し、新しいスクリプト・スタイルを追加する
3. `<body>` を置き換える
4. `turbo:load` イベントを発火する

### 何が問題だったか

flatpickr は `content_for :head` を使って `stores/show.html.erb` に書かれていた。

```erb
<%# stores/show.html.erb %>
<% content_for :head do %>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
  <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
  <script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/ja.js"></script>
  <%= javascript_include_tag "seats_index" %>
<% end %>
```

Turbo 経由で遷移してくると、上記のCDNスクリプトが `<head>` に追加されるが、**外部CDNのスクリプトは非同期で読み込まれる**。

つまり：

```
Turboが<head>にflatpickrのscriptタグを追加
        ↓
flatpickrがまだ読み込み中...（非同期）
        ↓
turbo:load が発火
        ↓
seats_index.js の初期化処理が走る → flatpickr() を呼ぼうとする
        ↓
flatpickrがまだ未定義 → 初期化されないまま終わる
```

フルリロードの場合はすべてのスクリプトが読み込み完了してからページが表示されるため問題なく動く。

---

## 解決策

flatpickr を `application.html.erb` の `<head>` に移動して、**全ページ共通で読み込む**ようにした。

```erb
<%# application.html.erb %>
<head>
  ...
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
  <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
  <script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/ja.js"></script>

  <%= yield :head %>
  ...
</head>
```

こうすることで、最初のページ読み込み時に flatpickr が確実にロードされる。
Turbo 経由の遷移後も flatpickr はすでにメモリ上に存在しているため、`turbo:load` 発火時に問題なく初期化できる。

### `seats_index.js` は移動しない理由

`javascript_include_tag "seats_index"` は間取り図ページだけで使うページ固有のコード。全ページで読み込む必要はないので `content_for :head` に残す。

```erb
<%# stores/show.html.erb %>
<% content_for :head do %>
  <%= javascript_include_tag "seats_index" %>
<% end %>
```

---

## まとめ

| | フルリロード | Turbo遷移 |
|---|---|---|
| CDNスクリプトの読み込み | 完了してから表示 | 非同期（遅れる場合がある） |
| flatpickrが application.html.erb にある場合 | ✅ 動く | ✅ 動く（初回ロード済み） |
| flatpickrが content_for :head にある場合 | ✅ 動く | ❌ 動かない場合がある |

**ライブラリ（外部CDN）は `application.html.erb` で共通読み込みにする。ページ固有のJSは `content_for :head` で個別読み込みにする。**
