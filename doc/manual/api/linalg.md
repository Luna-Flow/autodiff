# linalg API

## Purpose

The `linalg` package computes gradients and Jacobians of functions on
immutable vectors from
[`Luna-Flow/linear-algebra`](https://lunaflow.cn/en/linear-algebra/). Each
driver evaluates the function on vectors of dual numbers, one input
coordinate at a time. The method is explained in the
[linalg design](../design/linalg.md).

Source: [`src/linalg/linalg.mbt`](../../../src/linalg/linalg.mbt).

## Importing

```moonbit nocheck
import {
  "Luna-Flow/autodiff/linalg",
  "Luna-Flow/linear-algebra/immut" @la,
}
```

The examples use `@linalg` for this package and `@la` for
`linear-algebra/immut`. `@linalg.Vector` and `@linalg.Matrix` are the same
types as `@la.Vector` and `@la.Matrix`.

## Function shapes and preconditions

The drivers take the function first and the point $x \in T^n$ second:

| Driver | `f` | Result |
| --- | --- | --- |
| `gradient` | `(Vector[Dual[T]]) -> Dual[T]` | $\nabla f(x) \in T^n$ |
| `value_and_gradient` | `(Vector[Dual[T]]) -> Dual[T]` | $(f(x), \nabla f(x))$ |
| `jacobian` | `(Vector[Dual[T]]) -> Vector[Dual[T]]` | $J_f(x) \in T^{m \times n}$ |
| `value_and_jacobian` | `(Vector[Dual[T]]) -> Vector[Dual[T]]` | $(f(x), J_f(x))$ |

All four require:

- `f` accepts a vector of length $n$ = `x.length()` and reads only indices
  below $n$;
- a vector-valued `f` returns the same length $m$ on every call;
- `f` treats every captured value as a constant (`Dual::constant`).

The drivers do not validate shapes. A violation aborts with an index error
or, if a later call returns a longer vector, silently ignores the extra
entries.

## Gradients

### `gradient`

Computes the gradient $\nabla f(x) = \big(\partial f/\partial x_1, \dots,
\partial f/\partial x_n\big)$ of a scalar function.

```mbti
pub fn[T : @luna-generic.One + @luna-generic.Zero] gradient((@immut.Vector[@dual.Dual[T]]) -> @dual.Dual[T], @immut.Vector[T]) -> @immut.Vector[T]
```

For each $i$ it calls `f` once with coordinate $i$ seeded as
`Dual::new(x[i], 1)` and every other coordinate as `Dual::constant(x[j])`,
and stores the tangent of the result as component $i$. Cost: $n$
evaluations of `f` on dual numbers. For $n = 0$ the result is empty and `f`
is not called.

### `value_and_gradient`

Returns $f(x)$ and $\nabla f(x)$.

```mbti
pub fn[T : @luna-generic.One + @luna-generic.Zero] value_and_gradient((@immut.Vector[@dual.Dual[T]]) -> @dual.Dual[T], @immut.Vector[T]) -> (T, @immut.Vector[T])
```

The value comes from one extra call with all tangents zero, so the cost is
$n + 1$ evaluations.

```moonbit
test "gradient of x0^2 + x0 x1" {
  let x = @la.Vector::from_array([2.0, 3.0])
  let f = (v : @la.Vector[@autodiff.Dual[Double]]) => v[0] * v[0] + v[0] * v[1]
  assert_eq(@linalg.gradient(f, x), @la.Vector::from_array([7.0, 2.0]))
  let (value, grad) = @linalg.value_and_gradient(f, x)
  assert_eq(value, 10.0)
  assert_eq(grad, @la.Vector::from_array([7.0, 2.0]))
}
```

## Jacobians

### `jacobian`

Computes the Jacobian matrix $J_f(x)$ of a vector-valued function, with one
row per output and one column per input:

$$
J_f(x)_{ij} = \frac{\partial f_i}{\partial x_j}(x), \qquad
0 \le i < m, \quad 0 \le j < n .
$$

```mbti
pub fn[T : @luna-generic.One + @luna-generic.Zero] jacobian((@immut.Vector[@dual.Dual[T]]) -> @immut.Vector[@dual.Dual[T]], @immut.Vector[T]) -> @immut.Matrix[T]
```

It first calls `f` with all tangents zero to learn $m$, then once per input
$j$ with coordinate $j$ seeded; the output tangents of call $j$ form
column $j$. Cost: $n + 1$ evaluations. The result has `row()` $= m$ and
`col()` $= n$.

### `value_and_jacobian`

Returns $f(x)$ and $J_f(x)$.

```mbti
pub fn[T : @luna-generic.One + @luna-generic.Zero] value_and_jacobian((@immut.Vector[@dual.Dual[T]]) -> @immut.Vector[@dual.Dual[T]], @immut.Vector[T]) -> (@immut.Vector[T], @immut.Matrix[T])
```

The value comes from its own call with zero tangents, and the Jacobian from
`jacobian`, so the cost is $n + 2$ evaluations.

```moonbit
test "jacobian of (x0 + x1, x0 x1, x0^2)" {
  let x = @la.Vector::from_array([2.0, 3.0])
  let f = (v : @la.Vector[@autodiff.Dual[Double]]) => {
    @la.Vector::from_array([v[0] + v[1], v[0] * v[1], v[0] * v[0]])
  }
  let (value, j) = @linalg.value_and_jacobian(f, x)
  assert_eq(value, @la.Vector::from_array([5.0, 6.0, 4.0]))
  assert_eq(j.row(), 3)
  assert_eq(j.col(), 2)
  assert_eq(j[1][0], 3.0) // d(x0 x1)/dx0 = x1
  assert_eq(j[2][1], 0.0) // d(x0^2)/dx1
}
```

## Re-exported types

### `Dual`

The dual-number type; see the [dual API](dual.md).

```mbti
pub using @dual {type Dual}
```

### `Vector`

The immutable vector of `linear-algebra`.

```mbti
pub using @immut {type Vector}
```

### `Matrix`

The immutable matrix of `linear-algebra`.

```mbti
pub using @immut {type Matrix}
```
