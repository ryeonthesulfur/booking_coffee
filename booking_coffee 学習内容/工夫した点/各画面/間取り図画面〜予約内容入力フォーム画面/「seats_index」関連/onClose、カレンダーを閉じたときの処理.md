# onClose、カレンダーを閉じたときの処理

---

## 該当コード

```javascript
onClose: function (selectedDates, dateStr, instance) {
  if (selectedDates.length === 0) return;
  // 間取り図のページでのみ、URLを更新してリロードする
  if (document.querySelector('.floor-map-container')) {
    const url = new URL(window.location.href);
    url.searchParams.set('start_time', dateStr);
    window.location.href = url.toString();
  }
}
```

---

## なぜこれが必要なのか

間取り図画面では、ユーザーが予約日時を選択したら、その日時に合わせて**グレイアウトされる座席を更新**する必要があります。

グレイアウトの計算はサーバー側（Rails のコントローラー）で行っているため、
日時が変わるたびにサーバーに問い合わせる必要があります。

そのために**ページ全体をリロード**し、選んだ日時を URL に乗せてサーバーに渡しています。

カレンダーを「閉じた瞬間」をリロードのタイミングにしているのは、
選択中は何度もクリックが発生するため、選び終わったタイミング（= 閉じたとき）でリロードするのが自然だからです。

---

## 一行ずつの解説

### `onClose: function (selectedDates, dateStr, instance) {`

`onClose` は flatpickr の**イベントハンドラ**です。
ユーザーがカレンダーを閉じた瞬間に、この `function` の中身が自動で実行されます。

引数は `onChange` と同じく flatpickr が自動で渡してくれます：

| 引数 | 中身 |
|---|---|
| `selectedDates` | 選択された日時の配列（Date オブジェクト） |
| `dateStr` | 選択された日時の文字列（`dateFormat` の形式）例：`"2026-07-29 14:30〜"` |
| `instance` | flatpickr 自身のオブジェクト |

---

### `if (selectedDates.length === 0) return;`

何も選ばれていない状態でカレンダーを閉じた場合は、以降の処理をスキップして終了します。

`onChange` と同じガードです。何も選ばれていないのにリロードされると困るため。

---

### `if (document.querySelector('.floor-map-container')) {`

`.floor-map-container` というクラスを持つ要素がページ内に存在するかどうかをチェックしています。

このクラスは**間取り図画面にしか存在しません。**

`seats_index.js` は間取り図画面と予約フォーム画面の両方で読み込まれています。
予約フォーム画面でカレンダーを閉じたときにもリロードしてしまうと、フォームの入力内容が消えてしまいます。
そのため、間取り図画面のときだけリロードするようにこの条件分岐を設けています。

---

### `const url = new URL(window.location.href);`

現在のページの URL を `URL` オブジェクトに変換しています。

`window.location.href` は現在の URL を文字列で持っています。
文字列のままでは URL の一部（クエリパラメータなど）を編集しにくいため、
`new URL(...)` で扱いやすいオブジェクトに変換しています。

---

### `url.searchParams.set('start_time', dateStr);`

URL のクエリパラメータ `start_time` に、ユーザーが選んだ日時の文字列（`dateStr`）をセットしています。

例：
```
変更前: https://example.com/stores/1/seats
変更後: https://example.com/stores/1/seats?start_time=2026-07-29+14%3A30%7E
```

`searchParams.set(キー名, 値)` は URL のクエリパラメータを追加・上書きするメソッドです。
すでに `start_time` があれば上書き、なければ追加します。

---

### `window.location.href = url.toString();`

`url.toString()` で URL オブジェクトを文字列に戻し、それを `window.location.href` に代入しています。

ここで「なぜ文字列に戻すのか」について補足します。

`const url = new URL(...)` の時点で `url` は **URL オブジェクト**です。
`dateStr` という文字列を `searchParams.set(...)` で入れていますが、`url` 自体はオブジェクトのままです。

```javascript
const url = new URL(window.location.href);  // URLオブジェクト
url.searchParams.set('start_time', dateStr); // オブジェクトのまま編集している

window.location.href = url.toString();  // ← ここで文字列に変換して代入
```

`window.location.href` には**文字列しか代入できない**ため、最後に `.toString()` でオブジェクトを文字列に変換する必要があります。

`window.location.href` に URL を代入すると、**ブラウザがそのURLに遷移（リロード）します。**

これにより、選んだ日時を `start_time` パラメータとして URL に乗せた状態でページが再読み込みされ、
Rails のコントローラーがその日時を受け取ってグレイアウト計算を行います。

---

## まとめ：処理の流れ

```
ユーザーがカレンダーで日時を選ぶ
      ↓
カレンダーを閉じる（onClose 発火）
      ↓
間取り図画面かどうか確認
      ↓
現在の URL に ?start_time=選んだ日時 を付け加える
      ↓
そのURLでページをリロード
      ↓
Rails のコントローラーが start_time を受け取り、グレイアウト計算をして画面を返す
```
