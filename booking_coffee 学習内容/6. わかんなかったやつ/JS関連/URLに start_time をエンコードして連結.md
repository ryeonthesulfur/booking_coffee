# 解説：URLに `start_time` をエンコードして連結

---

## コード（`toReservation_form.js`）

```javascript
window.location.href = startTime ? `${url}?start_time=${encodeURIComponent(startTime)}` : url;
```

---

## 1つずつ分解する

### 三項演算子の構造

```javascript
startTime ? `${url}?start_time=${encodeURIComponent(startTime)}` : url
// ↑条件      ↑ startTimeがある場合                               ↑ ない場合
```

| 条件 | 結果 |
|---|---|
| `startTime` に値がある | `start_time` パラメーターを付けたURLに遷移 |
| `startTime` が空・null | パラメーターなしのURLにそのまま遷移 |

---

### `encodeURIComponent(startTime)` とは

URLに使えない文字を**エンコード（変換）する**関数。

flatpickrが出力する日時の文字列には、URLに直接書けない文字が含まれている。

| 元の文字 | エンコード後 |
|---|---|
| スペース（` `） | `+` または `%20` |
| コロン（`:`） | `%3A` |
| 全角波ダッシュ（`〜`） | `%E3%80%9C` |

```javascript
encodeURIComponent("2026-09-06 15:00〜")
// → "2026-09-06+15%3A00%E3%80%9C"
```

エンコードしないままURLに含めると、ブラウザやサーバーが正しく解釈できない。

---

### テンプレートリテラルで組み立て

```javascript
`${url}?start_time=${encodeURIComponent(startTime)}`
```

バッククォートで囲んだ文字列の中に `${}` で変数を埋め込んでいる。

```
url = "/stores/1/seats/5/reservations/new"
startTime = "2026-09-06 15:00〜"

→ "/stores/1/seats/5/reservations/new?start_time=2026-09-06+15%3A00%E3%80%9C"
```

---

### `window.location.href = ...`

このURLに**画面遷移する**。代入するだけで遷移が起きる。

---

## 全体の動き

```
「予約する」ボタンをクリック
    ↓
startTime = "2026-09-06 15:00〜"（date-input の値）
    ↓
encodeURIComponent で URL に使える文字列に変換
    ↓
url + "?start_time=2026-09-06+15%3A00%E3%80%9C" を組み立て
    ↓
window.location.href に代入 → 予約フォームページへ遷移
```

---

## まとめ

| コード | 役割 |
|---|---|
| `encodeURIComponent(startTime)` | 日時文字列をURLに使える形式に変換する |
| テンプレートリテラル | URLと変換した日時を1つの文字列に組み立てる |
| `window.location.href = ...` | 組み立てたURLに画面遷移する |
| 三項演算子 | 日時が選ばれていない場合はパラメーターなしで遷移する |
