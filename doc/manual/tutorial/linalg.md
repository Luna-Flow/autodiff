# linalg tutorial

This tutorial computes gradients, Jacobians and Jacobian-vector products of
functions on `linear-algebra` vectors. You will write functions over
`Vector[Dual[Double]]`, pass them to the `linalg` drivers, and use the
results in a small optimization loop. Why the drivers work this way is in
the [linalg design](../design/linalg.md).

## Quick start

```bash
moon add Luna-Flow/autodiff@0.2.0
moon add Luna-Flow/linear-algebra
```

```moonbit nocheck
import {
  "Luna-Flow/autodiff",
  "Luna-Flow/autodiff/linalg",
  "Luna-Flow/linear-algebra/immut" @la,
}
```

```moonbit
fn main {
  let x = @la.Vector::from_array([2.0, 3.0])
  let g = @linalg.gradient(v => v[0] * v[0] + v[0] * v[1], x)
  println(g)
}
```

```text
|7, 2|
```

For $f(x_0, x_1) = x_0^2 + x_0 x_1$ the gradient is $(2x_0 + x_1,\ x_0) =
(7, 2)$.

## Everyday tasks

### Gradient of a named function

Give the function an explicit type when it is not a closure written in
place. Constants enter through `Dual::constant`:

```moonbit
fn rosenbrock(v : @la.Vector[@autodiff.Dual[Double]]) -> @autodiff.Dual[Double] {
  let one = @autodiff.Dual::constant(1.0)
  let hundred = @autodiff.Dual::constant(100.0)
  let a = one - v[0]
  let b = v[1] - v[0] * v[0]
  a * a + hundred * b * b
}

fn main {
  let (value, grad) = @linalg.value_and_gradient(
    rosenbrock,
    @la.Vector::from_array([-1.0, 2.0]),
  )
  println("f    = \{value}")
  println("grad = \{grad}")
}
```

```text
f    = 104
grad = |396, 200|
```

### Jacobian of a vector function

`jacobian` returns an $m \times n$ matrix whose row $i$ is the gradient of
output $i$. Here, the map from polar to Cartesian coordinates:

```moonbit
fn polar(v : @la.Vector[@autodiff.Dual[Double]]) -> @la.Vector[@autodiff.Dual[Double]] {
  let r = v[0]
  let theta = v[1]
  @la.Vector::from_array([r * theta.cos(), r * theta.sin()])
}

fn main {
  let x = @la.Vector::from_array([2.0, 0.0])
  let j = @linalg.jacobian(polar, x)
  println(j)
  println("det = \{j[0][0] * j[1][1] - j[0][1] * j[1][0]}")
}
```

```text
|1, 0|
|0, 2|
det = 2
```

The determinant of this Jacobian is $r = 2$, the familiar area factor of
polar coordinates.

### Compute a Jacobian-vector product

To get $J_f(x)\,v$ for one direction $v$, seed every input with its
direction component and evaluate `f` once:

```moonbit
fn polar(v : @la.Vector[@autodiff.Dual[Double]]) -> @la.Vector[@autodiff.Dual[Double]] {
  @la.Vector::from_array([v[0] * v[1].cos(), v[0] * v[1].sin()])
}

fn main {
  let x = @la.Vector::from_array([2.0, 0.0])
  let dir = @la.Vector::from_array([1.0, 0.5])
  let seeded = @la.Vector::makei(x.length(), i => @autodiff.Dual::new(x[i], dir[i]))
  let jv = polar(seeded).map(y => y.tangent())
  println(jv)
}
```

```text
|1, 1|
```

This costs one evaluation, instead of the $n + 1$ that `jacobian` needs.

### Gradient descent

`value_and_gradient` gives what a descent step needs:

```moonbit
fn bowl(v : @la.Vector[@autodiff.Dual[Double]]) -> @autodiff.Dual[Double] {
  let two = @autodiff.Dual::constant(2.0)
  let a = v[0] - @autodiff.Dual::constant(1.0)
  let b = v[1] + @autodiff.Dual::constant(0.5)
  a * a + two * b * b
}

fn main {
  let mut x = @la.Vector::from_array([3.0, 3.0])
  for _ in 0..<50 {
    let (_, g) = @linalg.value_and_gradient(bowl, x)
    x = @la.Vector::makei(x.length(), i => x[i] - 0.2 * g[i])
  }
  let (value, _) = @linalg.value_and_gradient(bowl, x)
  println("minimum near (\{x[0]}, \{x[1]}), f = \{value}")
}
```

```text
minimum near (1.0000000000161655, -0.5), f = 2.6132382259185474e-22
```

## Going further

### Vector arithmetic on dual vectors

`Vector[Dual[Double]]` supports the vector operations that only need ring
structure, so you can write $f(x) = \tfrac12 x^{\mathsf T} x + a^{\mathsf T}x$
with vector operations and a fold:

```moonbit
fn energy(v : @la.Vector[@autodiff.Dual[Double]]) -> @autodiff.Dual[Double] {
  let a = @la.Vector::from_array([1.0, -2.0, 0.5]).map(@autodiff.Dual::constant)
  let half = @autodiff.Dual::constant(0.5)
  let sq = (v * v).iter().fold(init=@autodiff.Dual::constant(0.0), (s, t) => s + t)
  let lin = (a * v).iter().fold(init=@autodiff.Dual::constant(0.0), (s, t) => s + t)
  half * sq + lin
}

fn main {
  let g = @linalg.gradient(energy, @la.Vector::from_array([1.0, 1.0, 1.0]))
  println(g)
}
```

```text
|2, -1, 1.5|
```

The gradient is $x + a$. `v * v` is the elementwise product of
`linear-algebra` vectors.

### Generic functions

A function written against the traits can be differentiated and also run on
plain numbers. Give it a vector of `T`:

```moonbit
fn[T : @autodiff.Ring] product(v : @la.Vector[T]) -> T {
  v.iter().fold(init=@autodiff.One::one(), (s, t) => s * t)
}

fn main {
  let x = @la.Vector::from_array([2.0, 3.0, 4.0])
  println("product = \{product(x)}")
  println("gradient = \{@linalg.gradient(product, x)}")
}
```

```text
product = 24
gradient = |12, 8, 6|
```

## Common pitfalls

- **Keep the output length fixed.** `jacobian` learns $m$ from the first
  call; a different length later aborts or loses entries.
- **Read only the indices you are given.** The drivers pass vectors of
  length `x.length()` and do not check accesses.
- **Many inputs.** Each input costs one evaluation of `f`. For hundreds of
  inputs and a cheap reverse-mode alternative elsewhere, forward mode is the
  slow choice.
- **Captured vectors are constants.** Map them with `Dual::constant` before
  combining them with the input.

## Next steps

- The [linalg API](../api/linalg.md) lists the drivers, their shapes and
  costs.
- The [linalg design](../design/linalg.md) derives the column-by-column
  method and compares it with reverse mode.
- The [dual tutorial](dual.md) shows the seeding the drivers perform.
- [linear-algebra](https://lunaflow.cn/en/linear-algebra/) documents the
  vector and matrix types.
