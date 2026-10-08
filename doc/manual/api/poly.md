# poly API

## Purpose

The `poly` package differentiates polynomials from
[`Luna-Flow/luna-poly`](https://lunaflow.cn/en/luna-poly/) at a point by
evaluating them over `Dual[T]`. It covers dense univariate polynomials and
sparse polynomials in one variable. The method is explained in the
[poly design](../design/poly.md).

Source: [`src/poly/poly.mbt`](../../../src/poly/poly.mbt).

## Importing

```moonbit nocheck
import {
  "Luna-Flow/autodiff/poly",
  "Luna-Flow/luna-poly/immut/dense",
  "Luna-Flow/luna-poly/immut/sparse",
}
```

The examples use `@poly` for this package and `@dense` and `@sparse` for
the `luna-poly` packages. `@poly.DensePolynomial` and
`@poly.SparsePolynomial` are the same types as `@dense.DensePolynomial` and
`@sparse.SparsePolynomial`.

Every function needs `T : Eq + Semiring`: `Semiring` for the arithmetic and
`Eq` because `luna-poly` normalizes coefficients when it builds the lifted
polynomial. No `NatHomomorphism` or division is required, so integer
polynomials work too.

## Dense polynomials

### `eval_dual`

Evaluates a dense polynomial at a dual input.

```mbti
pub fn[T : Eq + @luna-generic.Semiring] eval_dual(@dense.DensePolynomial[T], @dual.Dual[T]) -> @dual.Dual[T]
```

For $x = a + b\varepsilon$ the result is $p(a) + p'(a)\,b\,\varepsilon$. The
coefficients are lifted with `Dual::constant` and the lifted polynomial is
evaluated with `DensePolynomial::eval` (Horner's rule). Cost: $O(\deg p)$
dual operations and one array of lifted coefficients. Use it to place a
polynomial inside a larger differentiated computation, for example
`eval_dual(p, x.sin())`.

### `dense_value_and_derivative_at`

Returns $(p(x), p'(x))$.

```mbti
pub fn[T : Eq + @luna-generic.Semiring] dense_value_and_derivative_at(@dense.DensePolynomial[T], T) -> (T, T)
```

It is `eval_dual(p, Dual::variable(x))` split into its components.

### `dense_derivative_at`

Returns $p'(x)$.

```mbti
pub fn[T : Eq + @luna-generic.Semiring] dense_derivative_at(@dense.DensePolynomial[T], T) -> T
```

```moonbit
test "dense polynomial derivative" {
  // p(x) = 1 + 2x + x^3
  let p = @dense.DensePolynomial::from_coefficients([1.0, 2.0, 0.0, 1.0])
  assert_eq(@poly.dense_value_and_derivative_at(p, 3.0), (34.0, 29.0))
  assert_eq(@poly.dense_derivative_at(p, 3.0), 29.0)
  let y = @poly.eval_dual(p, @autodiff.Dual::new(3.0, 4.0))
  assert_eq(y, @autodiff.Dual::new(34.0, 116.0)) // p'(3) * 4
}
```

## Sparse polynomials in one variable

These functions treat a `SparsePolynomial` as a polynomial in its first
variable: they evaluate it with the single assignment `[x]`.

> [!IMPORTANT]
> A sparse polynomial that uses a second variable (a term with a non-zero
> exponent at index $1$ or higher) makes `SparsePolynomial::eval` abort with
> "Missing value for multivariate polynomial variable". These are not
> partial derivatives of multivariate polynomials.

### `sparse_univariate_eval_dual`

Evaluates a sparse polynomial in one variable at a dual input.

```mbti
pub fn[T : Eq + @luna-generic.Semiring] sparse_univariate_eval_dual(@sparse.SparsePolynomial[T], @dual.Dual[T]) -> @dual.Dual[T]
```

The result is $p(a) + p'(a)\,b\,\varepsilon$. Coefficients are lifted with
`Dual::constant`, and each term $c\,x^e$ is evaluated by binary powering, so
the cost is $O(\sum_{\text{terms}} \log e)$ dual operations and missing
degrees cost nothing.

### `sparse_univariate_value_and_derivative_at`

Returns $(p(x), p'(x))$ for a sparse polynomial in one variable.

```mbti
pub fn[T : Eq + @luna-generic.Semiring] sparse_univariate_value_and_derivative_at(@sparse.SparsePolynomial[T], T) -> (T, T)
```

### `sparse_univariate_derivative_at`

Returns $p'(x)$ for a sparse polynomial in one variable.

```mbti
pub fn[T : Eq + @luna-generic.Semiring] sparse_univariate_derivative_at(@sparse.SparsePolynomial[T], T) -> T
```

```moonbit
test "sparse polynomial derivative" {
  // p(x) = 4 - x + 2x^3
  let p = @sparse.SparsePolynomial::from_array([
    ([3U], 2.0),
    ([1U], -1.0),
    ([0U], 4.0),
  ])
  assert_eq(@poly.sparse_univariate_value_and_derivative_at(p, 2.0), (18.0, 23.0))
  assert_eq(@poly.sparse_univariate_derivative_at(p, 2.0), 23.0)
}
```

## Compatibility names

Earlier releases used shorter names. They remain available, are not
deprecated, and call the functions above.

| Name | Same as |
| --- | --- |
| `value_and_derivative_at` | `dense_value_and_derivative_at` |
| `derivative_at` | `dense_derivative_at` |
| `eval_sparse_dual` | `sparse_univariate_eval_dual` |
| `sparse_value_and_derivative_at` | `sparse_univariate_value_and_derivative_at` |
| `sparse_derivative_at` | `sparse_univariate_derivative_at` |

### `value_and_derivative_at`

```mbti
pub fn[T : Eq + @luna-generic.Semiring] value_and_derivative_at(@dense.DensePolynomial[T], T) -> (T, T)
```

### `derivative_at`

```mbti
pub fn[T : Eq + @luna-generic.Semiring] derivative_at(@dense.DensePolynomial[T], T) -> T
```

### `eval_sparse_dual`

```mbti
pub fn[T : Eq + @luna-generic.Semiring] eval_sparse_dual(@sparse.SparsePolynomial[T], @dual.Dual[T]) -> @dual.Dual[T]
```

### `sparse_value_and_derivative_at`

```mbti
pub fn[T : Eq + @luna-generic.Semiring] sparse_value_and_derivative_at(@sparse.SparsePolynomial[T], T) -> (T, T)
```

### `sparse_derivative_at`

```mbti
pub fn[T : Eq + @luna-generic.Semiring] sparse_derivative_at(@sparse.SparsePolynomial[T], T) -> T
```

Prefer the longer names in new code: they say which representation and
which kind of derivative is meant.

## Re-exported types

### `DensePolynomial`

```mbti
pub using @dense {type DensePolynomial}
```

### `SparsePolynomial`

```mbti
pub using @sparse {type SparsePolynomial}
```

### `Dual`

```mbti
pub using @dual {type Dual}
```
