# 解説：`defaultDate` の三項演算子

---

## 該当コード（`seats_index.js`）

```javascript
let defaultDateVal;

if (startTimeParam) {
  const parsed = new Date(startTimeParam.replace('〜', ''));
  defaultDateVal = parsed > new Date() ? parsed : getNextHalfHour();
} else {
  defaultDateVal = getNextHalfHour();
}
```

```javascript
flatpickr(dateInput, {
  defaultDate: defaultDateVal,  // ← ここに入る
  ...
});
```

---

## `defaultDate` とは

flatpickr のオプションで、**カレンダーを開いたときに最初から入力されている日時**を指定するもの。

---

## コードの流れ

### ① URLに `start_time` パラメーターがあるか確認する

```javascript
if (startTimeParam) {
  // URLに日時がある場合
} else {
  // URLに日時がない場合
}
```

### ② ある場合：文字列を Date オブジェクトに変換する

```javascript
const parsed = new Date(startTimeParam.replace('〜', ''));
// "2026-09-06 15:00〜" → "2026-09-06 15:00" → Dateオブジェクト
```

`replace('〜', '')` で末尾の `〜` を除いてからDateオブジェクトに変換する。

### ③ 三項演算子：その日時が「未来かどうか」を判定する

```javascript
defaultDateVal = parsed > new Date() ? parsed : getNextHalfHour();
//               ↑条件              ↑真のとき  ↑偽のとき
```

| 条件 | 結果 |
|---|---|
| `parsed > new Date()`（URLの日時が未来） | URLの日時をそのまま使う |
| `parsed <= new Date()`（URLの日時が過去） | `getNextHalfHour()`（次の30分スロット）を使う |

**なぜ「未来かどうか」を判定するのか**

URLに古い日時が残っていた場合（例：昨日の日時でリロードしたなど）、そのまま初期値にすると過去の日時がセットされてしまう。それを防ぐためにこの判定を入れている。

### ④ ない場合：次の30分スロットを使う

```javascript
defaultDateVal = getNextHalfHour();
// 例：現在14:10 → 14:30、現在14:45 → 15:00
```

---

## まとめ

```
URLに start_time あり
  └ 未来の日時 → その日時を初期値にする
  └ 過去の日時 → 次の30分スロットを初期値にする
URLに start_time なし
  └ 次の30分スロットを初期値にする
```

どのケースでも「過去の日時が初期値になることはない」という安全設計になっている。
