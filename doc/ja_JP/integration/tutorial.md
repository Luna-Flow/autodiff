# エコシステム連携チュートリアル

## Gradient

スカラー関数が Luna Flow ベクトルを受け取る場合は `autodiff/linalg` を使います。

```moonbit
let x = @la.Vector::from_array([2.0, 3.0])
let gradient = @linalg.gradient(
  fn(v) { v[0] * v[0] + v[0] * v[1] },
  x,
)
```

`f(x, y) = x² + xy` の `(2, 3)` における gradient は `[7, 2]` です。

## Jacobian

`jacobian` はベクトル値関数に使います。

```moonbit
let x = @la.Vector::from_array([2.0, 3.0])
let jacobian = @linalg.jacobian(
  fn(v) { @la.Vector::from_array([v[0] + v[1], v[0] * v[1]]) },
  x,
)
```

返る行列は output-by-input です。

```text
[[1, 1],
 [3, 2]]
```

## 多項式の一点での導関数

`autodiff/poly` は `Dual[T]` 上で多項式を評価することで、一点での導関数を計算します。

```moonbit
let p = @dense.DensePolynomial::from_coefficients([1.0, 2.0, 1.0])
let (value, derivative) = @poly.value_and_derivative_at(p, 3.0)
```

`p(x) = x² + 2x + 1` の値は `16`、導関数値は `8` です。
