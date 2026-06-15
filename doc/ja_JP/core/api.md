# Core API

この文書は v0.1 の双対数ベース前進モード自動微分 API を説明します。

## 双対数

```moonbit
pub struct Dual[T] {
  value : T
  tangent : T
}
```

`value` は primal なスカラー値、`tangent` は一階微分成分です。

## コンストラクタ

- `Dual::new(value, tangent)` は双対数を直接構築します。
- `Dual::constant(x)` は `Dual(x, zero)` を構築します。
- `Dual::variable(x)` は `Dual(x, one)` を構築します。

`constant` は `Luna-Flow/luna-generic` の `Zero` を使い、`variable` は `One` を使います。

## アクセサ

- `Dual::value(self)` は値を返します。
- `Dual::tangent(self)` は tangent を返します。

## 代数

実装済みの演算:

- 加算: `(x, dx) + (y, dy) = (x + y, dx + dy)`
- 減算: `(x, dx) - (y, dy) = (x - y, dx - dy)`
- 符号反転: `-(x, dx) = (-x, -dx)`
- 乗算: `(x, dx) * (y, dy) = (x * y, x * dy + y * dx)`

`Dual[T]` は基底型が必要な制約を満たす場合に Luna Flow の環レベル構造を実装します。`Field`、`MulGroup`、`Inverse`、全順序は実装しません。

## Checked Arithmetic

checked division は `DivChecked` を使い、失敗を `ArithmeticError` として返します。

checked square root は `SqrtChecked` と `DivChecked` を使います。

## 初等関数

現在リフトされる初等関数:

- `sqrt`
- `exp`
- `ln`、`log2`、`log10`
- `sin`、`cos`、`tan`

checked trait を使わない場合、定義域と分岐の挙動は基底スカラーに従います。

## 前進モードヘルパー

- `value_and_diff(f, x)` は `(value, derivative)` を返します。
- `diff(f, x)` は導関数値のみを返します。
