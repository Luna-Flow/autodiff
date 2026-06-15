# Ecosystem Integration Tutorial

## Gradient

Use `autodiff/linalg` when a scalar function consumes a Luna Flow vector.

```moonbit
let x = @la.Vector::from_array([2.0, 3.0])
let gradient = @linalg.gradient(
  fn(v) { v[0] * v[0] + v[0] * v[1] },
  x,
)
```

For `f(x, y) = x² + xy`, the gradient at `(2, 3)` is `[7, 2]`.

## Jacobian

`jacobian` works for vector-valued functions.

```moonbit
let x = @la.Vector::from_array([2.0, 3.0])
let jacobian = @linalg.jacobian(
  fn(v) { @la.Vector::from_array([v[0] + v[1], v[0] * v[1]]) },
  x,
)
```

The returned matrix is output-by-input:

```text
[[1, 1],
 [3, 2]]
```

## Polynomial Derivative At A Point

`autodiff/poly` differentiates a polynomial at a point by evaluating it over
`Dual[T]`.

```moonbit
let p = @dense.DensePolynomial::from_coefficients([1.0, 2.0, 1.0])
let (value, derivative) = @poly.value_and_derivative_at(p, 3.0)
```

For `p(x) = x² + 2x + 1`, the value is `16` and the derivative is `8`.
