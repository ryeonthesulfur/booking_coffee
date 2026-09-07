# 解説：`detail-inner--two-col`

---

## 現在のコードには存在しない

`detail-inner--two-col` は、現在のアプリのビューやCSSに存在しないクラス名。  
開発中にメモしていたが、最終的には使わなかったか削除されたもの。

---

## クラス名の読み方（BEM記法）

このクラス名は **BEM（Block Element Modifier）** という命名規則で書かれている。

```
detail-inner    --    two-col
    ↑                   ↑
 ブロック名          モディファイア
（基本の部品名）    （バリエーション・状態を表す）
```

| パーツ | 記号 | 役割 |
|---|---|---|
| Block | なし | 基本の部品。`detail-inner` = 詳細画面の内側エリア |
| Modifier | `--` | そのブロックの「バリエーション」。`two-col` = 2カラムレイアウト版 |

---

## `two-col` とは何か

`two-col` は `two columns`（2列）の略。横に2列並べるレイアウトを意味する。

CSSでは `display: flex` や `display: grid` を使って実現することが多い。

```css
/* 例：two-col モディファイアのCSSイメージ */
.detail-inner--two-col {
  display: grid;
  grid-template-columns: 1fr 1fr; /* 横に2列均等に並べる */
  gap: 1rem;
}
```

### `grid-template-columns: 1fr 1fr` の意味

`grid-template-columns` は、グリッドレイアウトの**列の数と幅**を定義するプロパティ。

`1fr 1fr` の `fr` は **fraction（分数・割合）** の略で、余白を均等に分け合う単位。

| 書き方 | 意味 |
|---|---|
| `1fr 1fr` | 2列で均等に幅を分ける（各50%） |
| `1fr 2fr` | 2列で左1：右2の割合に分ける |
| `1fr 1fr 1fr` | 3列均等 |

`1fr 1fr` と書くだけで、画面幅が変わっても自動で均等2列を保ってくれる。`px` や `%` で指定するより柔軟に対応できる。

---

## BEM の `--`（ダブルハイフン）まとめ

`--` はブロックの**バリエーション**を作るための記号。同じ部品を複数のパターンで使い回すときに使う。

```css
.detail-inner          /* 基本形 */
.detail-inner--two-col /* 2カラム版 */
.detail-inner--wide    /* 幅広版（例） */
```

基本の `.detail-inner` にスタイルを定義しておいて、`--two-col` では「2カラムにするための追加スタイルだけ」を上書きする、という使い方が一般的。
