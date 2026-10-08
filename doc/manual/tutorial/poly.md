# poly tutorial

This tutorial differentiates `luna-poly` polynomials at a point. You will
get values and slopes of dense and sparse polynomials, use a polynomial
inside a larger differentiated expression, and run Newton's method on a
polynomial. The mathematics is in the [poly design](../design/poly.md).

## Quick start

```bash
moon add Luna-Flow/autodiff@0.2.0
moon add Luna-Flow/luna-poly
```

```moonbit nocheck
import {
  "Luna-Flow/autodiff",
  "Luna-Flow/autodiff/poly",
  "Luna-Flow/luna-poly/immut/dense",
}
```

```moonbit
fn main {
  // p(x) = 1 + 2x + x^2, coefficients from degree 0 upwards
  let p = @dense.DensePolynomial::from_coefficients([1.0, 2.0, 1.0])
  let (value, slope) = @poly.dense_value_and_derivative_at(p, 3.0)
  println("p(3) = \{value}, p'(3) = \{slope}")
}
```

```text
p(3) = 16, p'(3) = 8
```

## Everyday tasks

### Tabulate a derivative

```moonbit
fn main {
  // p(x) = x^3 - 3x
  let p = @dense.DensePolynomial::from_coefficients([0.0, -3.0, 0.0, 1.0])
  for x in [-2.0, -1.0, 0.0, 1.0, 2.0] {
    println("p'(\{x}) = \{@poly.dense_derivative_at(p, x)}")
  }
}
```

```text
p'(-2) = 9
p'(-1) = 0
p'(0) = -3
p'(1) = 0
p'(2) = 9
```

The derivative $3x^2 - 3$ vanishes at the critical points $\pm 1$.

### Exact derivatives of integer polynomials

Only `Semiring` is required, so integer coefficients give exact results:

```moonbit
fn main {
  // p(x) = 7 + 5x^4
  let p : @dense.DensePolynomial[Int] = @dense.DensePolynomial::from_coefficients([
    7, 0, 0, 0, 5,
  ])
  let (value, slope) = @poly.dense_value_and_derivative_at(p, 3)
  println("p(3) = \{value}, p'(3) = \{slope}")
}
```

```text
p(3) = 412, p'(3) = 540
```

### Sparse polynomials with large gaps

For a polynomial with few terms of high degree, use the sparse
representation; each term costs $O(\log e)$:

```moonbit
fn main {
  // p(x) = x^100 + 2x
  let p = @sparse.SparsePolynomial::from_array([([100U], 1.0), ([1U], 2.0)])
  let (value, slope) = @poly.sparse_univariate_value_and_derivative_at(p, 1.0)
  println("p(1) = \{value}, p'(1) = \{slope}")
}
```

```text
p(1) = 3, p'(1) = 102
```

### A polynomial inside a larger expression

`eval_dual` takes a dual input, so the chain rule continues through it.
Here $\frac{d}{dx}\,p(\sin x)$ at $x = 0.5$:

```moonbit
fn main {
  let p = @dense.DensePolynomial::from_coefficients([0.0, 0.0, 1.0]) // s^2
  let d = @autodiff.diff(x => @poly.eval_dual(p, x.sin()), 0.5)
  println("d/dx sin(x)^2 = \{d}")
  println("sin(2x)       = \{@math.sin(1.0)}")
}
```

```text
d/dx sin(x)^2 = 0.8414709848078965
sin(2x)       = 0.8414709848078965
```

### Newton's method on a polynomial

```moonbit
fn main {
  // p(x) = x^2 - 2
  let p = @dense.DensePolynomial::from_coefficients([-2.0, 0.0, 1.0])
  let mut x = 1.0
  for _ in 0..<6 {
    let (v, d) = @poly.dense_value_and_derivative_at(p, x)
    x = x - v / d
  }
  println("sqrt(2) = \{x}")
}
```

```text
sqrt(2) = 1.414213562373095
```

## Going further

### Agreement with the formal derivative

`luna-poly` can also build the derivative polynomial. Both routes give the
same numbers; evaluation over dual numbers avoids the second polynomial:

```moonbit
fn main {
  let p = @dense.DensePolynomial::from_coefficients([5.0, -1.0, 0.0, 3.0])
  let formal = p.derivative().eval(2.0)
  let dual = @poly.dense_derivative_at(p, 2.0)
  println("formal \{formal}, dual \{dual}")
}
```

```text
formal 35, dual 35
```

### Multivariate polynomials

The sparse bridge is univariate. To differentiate a contextual polynomial
with respect to one variable, evaluate the others first with
`ContextPolynomial::eval_partial` from `luna-poly/immut/context`, convert
the remaining terms to a sparse polynomial in that variable, and call
`sparse_univariate_value_and_derivative_at`. The repository's integration
test `src/tests/linalg_poly_test.mbt` shows the complete conversion.

## Common pitfalls

- **Coefficient order.** `DensePolynomial::from_coefficients` takes $c_0,
  c_1, \dots$ from the constant term upwards.
- **A second variable aborts.** `sparse_univariate_*` evaluates with one
  value; a term in another variable stops the program.
- **Old names.** `derivative_at` and `sparse_derivative_at` are aliases of
  the `dense_` and `sparse_univariate_` functions, not multivariate
  versions.
- **Floating-point cancellation.** Near a multiple root, $p'(x)$ is a small
  difference of large terms; see the error bound in the
  [poly design](../design/poly.md#rounding-error-of-the-dense-evaluation).

## Next steps

- The [poly API](../api/poly.md) lists every function and its alias.
- The [poly design](../design/poly.md) derives Horner's rule on dual
  numbers and its error bound.
- [luna-poly](https://lunaflow.cn/en/luna-poly/) documents the polynomial
  types.
