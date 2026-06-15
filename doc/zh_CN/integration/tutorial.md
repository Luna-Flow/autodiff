# 生态集成教程

## Gradient

当标量函数接收 Luna Flow 向量时，可以使用 `autodiff/linalg`。

```moonbit
let x = @la.Vector::from_array([2.0, 3.0])
let gradient = @linalg.gradient(
  fn(v) { v[0] * v[0] + v[0] * v[1] },
  x,
)
```

对于 `f(x, y) = x² + xy`，在 `(2, 3)` 处的 gradient 是 `[7, 2]`。

## Jacobian

`jacobian` 用于向量值函数。

```moonbit
let x = @la.Vector::from_array([2.0, 3.0])
let jacobian = @linalg.jacobian(
  fn(v) { @la.Vector::from_array([v[0] + v[1], v[0] * v[1]]) },
  x,
)
```

返回矩阵采用输出乘输入方向：

```text
[[1, 1],
 [3, 2]]
```

## 多项式定点导数

`autodiff/poly` 通过在 `Dual[T]` 上求值来计算多项式在某一点的导数。

```moonbit
let p = @dense.DensePolynomial::from_coefficients([1.0, 2.0, 1.0])
let (value, derivative) = @poly.value_and_derivative_at(p, 3.0)
```

对于 `p(x) = x² + 2x + 1`，函数值是 `16`，导数是 `8`。
