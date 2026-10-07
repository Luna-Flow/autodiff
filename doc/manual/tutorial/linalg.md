# linalg tutorial

This tutorial computes the gradient and the Jacobian of functions over Luna Flow
immutable vectors with `autodiff/linalg`.

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

## Next steps

The [linalg API](../api/linalg.md) lists every helper and its expected
function shape. The [linalg design](../design/linalg.md) explains why the
helpers use n-pass forward-mode seeding.
