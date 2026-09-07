# 解説：URLパラメーターから `start_time` を取得

---

## コード

```javascript
const urlParams = new URLSearchParams(window.location.search);
const startTimeParam = urlParams.get('start_time');
```

---

## 1行ずつ読む

### `window.location.search`

現在のページのURLのうち、`?` 以降のクエリ文字列を取り出す。

```
URL:  /stores/1?start_time=2026-09-06+15%3A00%E3%80%9C
                ↑ここ
window.location.search → "?start_time=2026-09-06+15%3A00%E3%80%9C"
```

### `new URLSearchParams(...)`

クエリ文字列をパースして、キーと値のペアとして扱えるオブジェクトを作る。

```javascript
const urlParams = new URLSearchParams("?start_time=2026-09-06+15%3A00%E3%80%9C");
// → URLSearchParams オブジェクト（辞書のようなもの）が作られる
```

### `.get('start_time')`

そのオブジェクトから `start_time` キーの値を取り出す。エンコードされた文字列は自動でデコードされる。

```javascript
urlParams.get('start_time')
// → "2026-09-06 15:00〜"
```

URLにパラメーターがない場合は `null` が返る。

---

## 全体の動き

```
URL: /stores/1?start_time=2026-09-06+15%3A00%E3%80%9C

↓ window.location.search
"?start_time=2026-09-06+15%3A00%E3%80%9C"

↓ new URLSearchParams(...)
{ start_time: "2026-09-06 15:00〜" } のようなオブジェクト

↓ .get('start_time')
"2026-09-06 15:00〜"  ← startTimeParam に入る
```

---

## このアプリでの使用箇所

**ファイル：`seats_index.js`**

間取り図ページと予約フォームページの両方で使っている。

| ページ | URLにパラメーターが入るタイミング | 取得した値の使い道 |
|---|---|---|
| 間取り図（stores#show） | 日時選択後に `onClose` がリロード時に付ける | flatpickr の初期値を復元する |
| 予約フォーム（reservations#new） | `toReservation_form.js` が遷移時に付ける | 間取り図で選んだ日時を自動入力する |

```javascript
const urlParams = new URLSearchParams(window.location.search);
const startTimeParam = urlParams.get('start_time');
// → "2026-09-06 15:00〜" または null（パラメーターがない場合）

if (startTimeParam) {
  const parsed = new Date(startTimeParam.replace('〜', ''));
  defaultDateVal = parsed > new Date() ? parsed : getNextHalfHour();
} else {
  defaultDateVal = getNextHalfHour();
}
```

`start_time` が取れた場合はそれを flatpickr の初期値に使い、取れなかった場合は次の30分スロットを初期値にする。

---

## まとめ

| コード | 役割 |
|---|---|
| `window.location.search` | URLの `?` 以降を文字列で取り出す |
| `new URLSearchParams(...)` | クエリ文字列をキー・値のオブジェクトに変換する |
| `.get('start_time')` | `start_time` キーの値を取り出す（なければ `null`） |
