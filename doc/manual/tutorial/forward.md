# forward tutorial

This tutorial differentiates functions of one variable with `diff` and
`value_and_diff`, the shortest way to get derivatives from this repository.
You will differentiate closures, named generic functions, functions that
call checked operations, and finally compute second derivatives. The
background is in the [forward design](../design/forward.md).

| I want to | Use |
| --- | --- |
| get the derivative at a point | `@autodiff.diff(f, x)` |
| get value and derivative in one pass | `@autodiff.value_and_diff(f, x)` |
| differentiate a named function | make it generic in `T` and pass it to `diff` |
| get a second derivative | `diff(x => diff(f, x), x0)` with a generic `f` |
| differentiate through a checked step | carry the `Result` out of the closure |

## Quick start

```bash
moon add Luna-Flow/autodiff@0.3.0
```

```moonbit nocheck
import {
  "Luna-Flow/autodiff",
}
```

```moonbit
fn main {
  let d = @autodiff.diff(x => x * x + x.sin(), 2.0)
  println("d/dx (x^2 + sin x) at 2 = \{d}")
}
```

```text
d/dx (x^2 + sin x) at 2 = 3.5838531634528574
```

The closure receives a `Dual[Double]`, so `*` and `sin` are the dual
operations, and `diff` returns $2 \cdot 2 + \cos 2$.

## Everyday tasks

### Get the value and the derivative together

`value_and_diff` returns both from one evaluation:

```moonbit
fn main {
  let (value, slope) = @autodiff.value_and_diff(x => x.exp() / (x * x), 2.0)
  println("f(2)  = \{value}")
  println("f'(2) = \{slope}")
}
```

```text
f(2)  = 1.8472640247326626
f'(2) = 0
```

$f(x) = e^x / x^2$ has $f'(x) = e^x (x - 2)/x^3$, which vanishes at $x = 2$.

### Use constants inside the function

Captured numbers must enter as constants:

```moonbit
fn main {
  let k = 3.0
  let d = @autodiff.diff(
    x => @autodiff.Dual::constant(k) * x * x - x.cos(),
    1.0,
  )
  println("d/dx (3x^2 - cos x) at 1 = \{d}")
}
```

```text
d/dx (3x^2 - cos x) at 1 = 6.841470984807897
```

### Differentiate a named generic function

A function written against the traits can be passed directly; it is
instantiated at `Dual[Double]`:

```moonbit
fn[T : @autodiff.Ring + @autodiff.Logarithmic] x_ln_x(x : T) -> T {
  x * @autodiff.Logarithmic::ln(x)
}

fn main {
  for x in [0.5, 1.0, 2.0] {
    println("d/dx x ln x at \{x} = \{@autodiff.diff(x_ln_x, x)}")
  }
}
```

```text
d/dx x ln x at 0.5 = 0.3068528194400547
d/dx x ln x at 1 = 1
d/dx x ln x at 2 = 1.6931471805599454
```

The derivative is $\ln x + 1$.

### Find a root with Newton's method

`value_and_diff` gives exactly what a Newton step needs, $x \leftarrow x -
f(x)/f'(x)$:

```moonbit
fn main {
  let f = (x : @autodiff.Dual[Double]) => x * x * x - @autodiff.Dual::constant(2.0)
  let mut x = 1.0
  for _ in 0..<5 {
    let (fx, dfx) = @autodiff.value_and_diff(f, x)
    x = x - fx / dfx
  }
  println("cube root of 2 = \{x}")
}
```

```text
cube root of 2 = 1.2599210498948732
```

### Differentiate through a checked operation

When `f` uses `div_checked` or `sqrt_checked`, wrap the driver call so the
error leaves the closure as a value:

```moonbit
fn safe_derivative(x : Double) -> Result[Double, @autodiff.ArithmeticError] {
  let ctx = @autodiff.ArithmeticContext::new(53)
  let mut failure = None
  let d = @autodiff.diff(
    v => match v.sqrt_checked(ctx) {
      Ok(r) => r
      Err(e) => {
        failure = Some(e)
        @autodiff.Dual::constant(0.0)
      }
    },
    x,
  )
  match failure {
    Some(e) => Err(e)
    None => Ok(d)
  }
}

fn main {
  for x in [4.0, -4.0] {
    match safe_derivative(x) {
      Ok(d) => println("sqrt'(\{x}) = \{d}")
      Err(e) => println("sqrt'(\{x}) failed: domain error \{e.is_domain_error()}")
    }
  }
}
```

```text
sqrt'(4) = 0.25
sqrt'(-4) failed: domain error true
```

## Going further

### Second derivatives

Apply `diff` to a function that itself calls `diff`. The inner function
must be generic so that it can run on `Dual[Dual[Double]]`:

```moonbit
fn[T : @autodiff.Ring + @autodiff.Trigonometric] f(x : T) -> T {
  x * @autodiff.Trigonometric::sin(x)
}

fn main {
  let second = @autodiff.diff(x => @autodiff.diff(f, x), 1.0)
  let expected = 2.0 * @math.cos(1.0) - @math.sin(1.0)
  println("f''(1) = \{second}")
  println("2 cos 1 - sin 1 = \{expected}")
}
```

```text
f''(1) = 0.23913362692838303
2 cos 1 - sin 1 = 0.23913362692838303
```

The nested derivative matches the closed form. Each level doubles the
number of components and triples the cost of a product, so use this for
low orders only.

### Other scalar types

`diff` works for every `T` with `One`; `Float` and even `Int` are fine when
`f` only uses ring operations:

```moonbit
fn main {
  let d : Int = @autodiff.diff(x => x * x * x * x, 3)
  println("d/dx x^4 at 3 = \{d}")
}
```

```text
d/dx x^4 at 3 = 108
```

## Common pitfalls

- **The closure parameter is a dual number.** Write `x.sin()` or
  `@autodiff.Trigonometric::sin(x)`, not `@math.sin(x)`, which takes a
  `Double` and does not compile here.
- **Captured values need `Dual::constant`.** A captured `Dual` that is
  itself `Dual::variable(…)` adds its own tangent and silently changes the
  result.
- **Branches.** `if x.value() < 0.0 { … }` differentiates the branch taken.
  At a kink you get a one-sided derivative.
- **Generic inner functions for nesting.** Nesting `diff` needs the inner
  function generic in `T`; a closure over `Dual[Double]` cannot be applied to
  `Dual[Dual[Double]]`.

## Next steps

- The [forward API](../api/forward.md) states the exact contract of the
  drivers.
- The [dual tutorial](dual.md) seeds tangents by hand, including directional
  derivatives.
- The [linalg tutorial](linalg.md) computes gradients and Jacobians.
- The [forward design](../design/forward.md) explains the method and the
  cost of nesting.
