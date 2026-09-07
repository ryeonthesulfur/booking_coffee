# onChange、カレンダー内の日付選択  260818

---

## 該当コード

```javascript
onChange: function (selectedDates, dateStr, instance) {
  if (selectedDates.length === 0) return;
  const selected = selectedDates[0];
  // 選んだ日付が今日かどうか判定
  const isToday = selected.toDateString() === new Date().toDateString();
  // 今日なら現在時刻以降のみ、明日以降なら00:00から選択可能にする
  instance.set('minTime', isToday ? getNextHalfHourString() : '00:00');
},
```

---

## なぜこれが必要なのか

flatpickr の初期設定（`minTime`）は、カレンダーを最初に開いたときに一度だけ決まります。

例えば今日（7/29）の14:30以降しか選べないように設定したとします。
ところが、ユーザーが翌日（7/30）を選んでから、また今日（7/29）に戻した場合、
**`minTime` の設定は自動で更新されません。**

その結果、今日の14:30より前の時刻（例：12:00）が選べてしまい、
過去の時刻で予約が進んでしまうバグが発生します。

これを防ぐために `onChange` を使い、**日付を選ぶたびに `minTime` を再計算・更新する**ようにしています。

---

## 一行ずつの解説

### `onChange: function (selectedDates, dateStr, instance) {`

`onChange` は flatpickr の**イベントハンドラ**です。
ユーザーがカレンダー上で日付や時刻を選択するたびに、この `function` の中身が自動で実行されます。

引数は flatpickr が自動で渡してくれます：

| 引数 | 中身 |
|---|---|
| `selectedDates` | 選択された日時の配列（Date オブジェクト）[Tue Jul 29 2026 14:30:00 GMT+0900]| 
| `dateStr` | 選択された日時の文字列（`dateFormat` の形式） |
| `instance` | flatpickr 自身のオブジェクト（設定を後から変更するために使う） |

---

### `if (selectedDates.length === 0) return;`

選択された日時が0件（= 何も選ばれていない）なら、以降の処理をスキップして終了します。

カレンダーを開いただけで何も選んでいない状態に備えたガードです。
`length === 0` のまま次の処理に進むと `selectedDates[0]` が `undefined` になりエラーになるため、ここで止めています。

---

### `const selected = selectedDates[0];`

`selectedDates` は配列なので、`[0]` で先頭の要素（= ユーザーが選んだ日時）を取り出しています。

flatpickr はデフォルトで1件しか選択できないため、`[0]` で必ず選択された日時が取れます。

---

### `const isToday = selected.toDateString() === new Date().toDateString();`

ユーザーが選んだ日付が「今日かどうか」を判定しています。

- `selected.toDateString()` → 選んだ日付を `"Tue Jul 29 2026"` のような文字列に変換
- `new Date().toDateString()` → 今日の日付を同じ形式で取得
- 両者が一致すれば `isToday = true`（今日）、一致しなければ `false`（明日以降）

**なぜ `toDateString()` を使うのか？**
Date オブジェクト同士を `===` で比較すると、時刻まで含めて比較されるため必ず `false` になります。
`toDateString()` で「日付部分だけの文字列」に変換することで、時刻を無視した日付の比較ができます。

---

### `instance.set('minTime', isToday ? getNextHalfHourString() : '00:00');`

選んだ日付に応じて、時刻の選択可能範囲（`minTime`）をリアルタイムで更新しています。

- **今日の場合** → `getNextHalfHourString()` で現在時刻の次の30分を最小値にする
  - 例：今が14:10 → `minTime` は `"14:30"` になる
- **明日以降の場合** → `'00:00'` で深夜0時から選べるようにする

`instance.set(...)` は flatpickr の設定を後から書き換えるメソッドです。
これにより、日付を切り替えるたびに `minTime` が正しく更新されます。

---

## まとめ：このコードが解決している問題

| 状況 | onChange なし | onChange あり |
|---|---|---|
| 最初から今日を選んでいる | 正常（14:30以降） | 正常（14:30以降） |
| 翌日を選んでから今日に戻す | **バグ**（過去の時刻も選べる） | 正常（14:30以降に更新される） |
| 最初から翌日を選ぶ | 正常（00:00から） | 正常（00:00から） |

カレンダーを操作するたびに今日かどうかを再判定し、`minTime` を動的に更新することで、
どんな操作順序でも過去の時刻が選べないようにしています。
