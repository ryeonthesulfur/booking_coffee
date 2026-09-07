# 解説：`width: fit-content;`

---

## 何をするのか

要素の幅を、**中のコンテンツ（テキストや画像）の大きさにぴったり合わせる**指定。

---

## なぜこれが必要なのか

ブロック要素（`div` や `h2` など）はデフォルトで **`width: 100%`**、つまり親要素の横幅いっぱいに広がる。

```
【デフォルト（width: 100%）】
|←──────── 親要素の横幅いっぱい ────────→|
| 予約詳細                               |  ← 背景色がここまで広がってしまう
```

```
【width: fit-content】
|← テキスト分だけ →|
| 予約詳細 |                               ← 背景色がテキストにぴったり
```

---

## このアプリでの使用箇所

**ファイル：`reservation_info.css`（予約詳細画面）**

```css
.detail-page-heading {
  width: fit-content;       /* ← テキストの幅にぴったり合わせる */
  font-size: 1.5rem;
  font-weight: 700;
  background-color: #fff4e2d2;
  padding: 1rem 2rem;
  border-radius: 2rem;
  color: #1c1917;
  margin: 0 0 2rem;
  font-family: 'Noto Serif JP', serif;
}
```

**なぜここで使うのか**

予約詳細画面の見出し（`.detail-page-heading`）に背景色・角丸・パディングを付けて、**ラベルのような見た目**にしたかった。

`width: 100%` のままだと背景色が画面いっぱいに広がってしまうため、`fit-content` でテキスト分だけに絞っている。

---

## まとめ

| 指定 | 幅の挙動 |
|---|---|
| デフォルト（`width: 100%`） | 親要素の横幅いっぱいに広がる |
| `width: fit-content` | 中のコンテンツの幅にぴったり合わせる |

背景色や枠線を「テキストにぴったり付けたい」ときに使う。
