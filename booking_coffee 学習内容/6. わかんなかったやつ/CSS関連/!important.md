# 解説：`!important`

---

## 何をするのか

通常のCSSの優先順位を無視して、**そのスタイルを強制的に適用する**ための宣言。

```css
.musubi-circle {
  border-radius: 50% !important;
}
```

---

## CSSの優先順位とは

CSSは複数のスタイルが同じ要素に当たったとき、**どちらを優先するか**というルールがある。  
基本的には「より具体的なセレクタ」や「後に書いたスタイル」が勝つ。

```css
/* 後から書いた方が勝つ */
.seat-box   { border-radius: 1rem; }   ← 負ける
.musubi-circle { border-radius: 50%; } ← 勝つ（後から書いたため）
```

しかし、セレクタの構造や読み込み順によっては思い通りにならないことがある。

---

## `!important` で強制的に勝たせる

`!important` を付けると、優先順位の計算を一切無視して**必ずそのスタイルが適用される**。

```css
.seat-box      { border-radius: 1rem; }        ← 負ける
.musubi-circle { border-radius: 50% !important; } ← !important があるので必ず勝つ
```

---

## このアプリでの使用箇所

**ファイル：`store_floor_3.css`（喫茶むすびの間取り図）**

```css
/* テラス席専用の正円デザイン */
.musubi-circle {
  border-radius: 50% !important;
}
```

**なぜここで使うのか**

全座席には `store_floor_common.css` の `.seat-box` で `border-radius: 1rem`（角丸）が共通で当たっている。

喫茶むすびのテラス席だけは丸い形にしたかったが、`.musubi-circle` を追加するだけでは共通の `border-radius: 1rem` に負けてしまう可能性があった。  
そこで `!important` を使って強制的に `border-radius: 50%`（正円）を適用している。

| セレクタ | border-radius | 結果 |
|---|---|---|
| `.seat-box`（共通） | `1rem`（角丸） | `.musubi-circle` に負ける |
| `.musubi-circle` | `50% !important`（正円） | 強制適用される |

---

## 注意点

`!important` は便利だが、多用するとどのスタイルが効いているか追いにくくなる。  
「どうしても上書きできない」という場面での最終手段として使うのが一般的。
