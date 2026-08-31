# 解説：flatpickrのバグ修正詳解 - なぜ過去の時刻が選べてしまったのか？

今回、`seats_index.js`で発生していたflatpickr（カレンダー）のバグは、大きく分けて2つの問題が絡み合って発生していました。

1.  **URLに残っていた過去の時刻を、そのまま表示してしまう問題**
2.  **カレンダーを開いたまま日付を切り替えると、過去の時刻を選べてしまう問題**

これらのバグが「なぜ起きていたのか」、そして「どのように解決したのか」を、一つずつ丁寧に解き明かしていきます。

---

## 問題1：URLの「過去の時刻」を信じすぎていた

### どんなバグだったか？

ページをリロードした際、URLに `?start_time=2026-06-09 09:00` のような過去の時刻が残っていると、カレンダーがその過去の時刻を初期値として表示してしまい、そのまま予約画面に進めてしまう状態でした。

### 何が原因だったか？

原因は、変更前のこの一行にありました。

**変更前のコード (`seats_index.js`)**
```javascript
// URLにstart_timeがあればそれを使う、なければ次の30分スロットを初期値にする
const defaultDateVal = startTimeParam ? startTimeParam.replace('〜', '') : getNextHalfHour();
```

このコードは、URLから取得した`startTimeParam`（時刻の文字列）を、**それが未来か過去かを一切チェックせず、無条件に信用して**カレンダーの初期値 (`defaultDateVal`) に設定していました。

例えるなら、身分証の有効期限を確認しない警備員のようなものです。期限切れの身分証（過去の時刻）を見せられても、そのまま中に入れてしまっていました。

### どう解決したか？

「警備員に有効期限のチェックをさせる」という修正を加えました。

**変更後のコード (`seats_index.js`)**
```javascript
let defaultDateVal;
if (startTimeParam) {
  // ① URLの時刻を、JavaScriptが扱える「Dateオブジェクト」に変換
  const parsed = new Date(startTimeParam.replace('〜', ''));

  // ②「URLの時刻」と「現在時刻」を比較する
  //    もしURLの時刻が未来ならそのまま使い、過去なら「次の30分」に差し替える
  defaultDateVal = parsed > new Date() ? parsed : getNextHalfHour();
} else {
  // URLに時刻がなければ、最初から「次の30分」を使う
  defaultDateVal = getNextHalfHour();
}
```

**ポイント解説:**
1.  まず、URLから取得したただの文字列を、`new Date()`を使って比較可能な「日付オブジェクト」に変換します。
2.  `parsed > new Date()` という比較式で、「URLの日時は、現在時刻よりも未来ですか？」とチェックします。
3.  この条件が`true`（未来）なら`parsed`（URLの日時）を、`false`（過去）なら`getNextHalfHour()`（次の有効な時刻）を`defaultDateVal`に設定します。

これにより、たとえURLに過去の時刻が残っていても、カレンダーは必ず未来の有効な時刻で表示されるようになりました。

---

## 問題2：仕事が遅い「onClose」に全部任せていた

### どんなバグだったか？

カレンダーを開いたまま、日付を「今日」から「翌日」に切り替え、また「今日」に戻すと、その一瞬だけ「16:30より前の時刻」が選択できてしまう、という問題でした。

### 何が原因だったか？

原因は、**「ルールの更新」**と**「最終決定のアクション」**という全く性質の違う2つの仕事を、`onClose`という一つのイベントにまとめて押し付けていたことでした。

**変更前のコード (`seats_index.js`)**
```javascript
onClose: function (selectedDates, dateStr, instance) {
  // 仕事①：ルールの更新（minTimeを今日/明日で切り替える）
  const isToday = selected.toDateString() === new Date().toDateString();
  instance.set('minTime', isToday ? getNextHalfHourString() : '00:00');

  // 仕事②：最終決定のアクション（ページをリロードする）
  if (document.querySelector('.floor-map-container')) {
    // ...リロード処理...
  }
}
```

`onClose`は、その名の通り**「カレンダーが閉じられた後」**にしか動きません。
そのため、カレンダーを開いたまま日付を「今日→翌日」と切り替えても、`minTime`のルールは古いまま更新されず、その隙に過去の時刻が選べてしまう、という loophole（抜け穴）が生まれていました。

### どう解決したか？

仕事の性質に合わせて、**「常に監視する仕事」**と**「最後に一度だけやる仕事」**を、それぞれ専門の担当者に分けることにしました。

**変更後のコード (`seats_index.js`)**
```javascript
// 担当者①：onChange（常に監視する人）
// 日付や時刻が変更されるたびに、即座に動く！
onChange: function (selectedDates, dateStr, instance) {
  if (selectedDates.length === 0) return;
  const selected = selectedDates[0];
  // 「今日が選ばれたか？」を常に監視し、即座にminTimeルールを更新する
  const isToday = selected.toDateString() === new Date().toDateString();
  instance.set('minTime', isToday ? getNextHalfHourString() : '00:00');
},

// 担当者②：onClose（最後に一度だけやる人）
// カレンダーが閉じられた時に、一度だけ動く
onClose: function (selectedDates, dateStr, instance) {
  // 最終決定のアクション（ページリロード）だけを担当する
  if (document.querySelector('.floor-map-container')) {
    // ...リロード処理...
  }
}
```

**ポイント解説:**
-   **`onChange`**: ユーザーが日付や時刻をクリックする**たびに**動きます。この担当者に「`minTime`ルールの更新」を任せることで、日付を切り替えた瞬間にルールが即座に適用され、不正な時刻を選択する隙がなくなりました。
-   **`onClose`**: 従来通り「ページのリロード」という最終アクションだけを担当します。

このように役割分担を明確にしたことで、カレンダーを開いている最中のあらゆる操作に対して、常に正しいルールが適用されるようになりました。