# 解説：`link_to` と `button_to` の違い 260906

---

## 一言で言うと

**`link_to`** → 画面を「見る」操作（GET）
**`button_to`** → データを「変える」操作（POST / PATCH / DELETE）

---

## HTTPメソッドの違い

| | デフォルトのHTTPメソッド | 用途 |
|---|---|---|
| `link_to` | GET | 画面を表示するだけ |
| `button_to` | POST（指定で変更可） | データを変更する操作 |

---

## 具体例

```erb
<%# 画面遷移 → link_to（GET） %>
<%= link_to "詳細を見る", reservation_path(@reservation) %>
<%= link_to "間取り図", reservation_path(r) %>
<%= link_to "← 予約一覧に戻る", reservations_path %>

<%# データ更新 → button_to（PATCH） %>
<%= button_to "チェックイン", check_in_reservation_path(reservation), method: :patch %>

<%# データ削除 → button_to（DELETE） %>
<%= button_to "予約をキャンセルする", reservation_path(@reservation), method: :delete %>
<%= button_to "退店する", reservation_path(reservation), method: :delete %>
```

---

## なぜ `link_to` でデータ変更をしてはいけないのか

`link_to` はデフォルトでGETしか送れない。

GETはブラウザの「ページを表示する」リクエストなので、データを変更する操作（更新・削除）には向いていない。

`link_to` に `method: :delete` などを指定することは技術的には可能だが、
Rails 7 以降の **Turbo との相性問題**が出やすいため使わない。

データを変更する操作には必ず `button_to` を使うのが Rails の慣習。

---

## ルーティングとの対応

パスが同じでもHTTPメソッドが違えば、ルーティングが別のアクションに振り分ける：

```
/reservations/16        GET    → reservations#show（詳細表示）
/reservations/16        DELETE → reservations#destroy（削除）
/reservations/16/check_in  PATCH  → reservations#check_in（チェックイン）
```

`link_to` は GET しか送れないので、上の例では「詳細表示」にしか使えない。
「削除」や「チェックイン」には `button_to` + `method:` の指定が必要。

---

## まとめ

```
見るだけ  → link_to
変える    → button_to + method: :patch / :delete
```
