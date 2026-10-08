# autodiff tutorial

This tutorial is the fastest route through the repository: with the single
import `Luna-Flow/autodiff` you differentiate a function, write generic code
against the re-exported traits, and handle checked failures. Each section
links to the package tutorial that goes deeper.

| I want to | Use |
| --- | --- |
| differentiate a function of one variable | `@autodiff.diff(f, x)` |
| get the value and the derivative together | `@autodiff.value_and_diff(f, x)` |
| write one function for plain and dual numbers | bounds such as `T : @autodiff.Ring + @autodiff.Trigonometric` |
| use $\pi$ or $e$ in differentiated code | `@autodiff.Constants::pi()` |
| get an error instead of NaN | `x.div_checked(y, ctx)`, `x.sqrt_checked(ctx)` |

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
  let (value, slope) = @autodiff.value_and_diff(x => x * x.exp(), 1.0)
  println("f(1) = \{value}")
  println("f'(1) = \{slope}")
}
```

```text
f(1) = 2.718281828459045
f'(1) = 5.43656365691809
```

$f(x) = x e^x$ has $f'(x) = (1 + x)e^x$, so $f'(1) = 2e$.

## Everyday tasks

### Differentiate a closure

```moonbit
fn main {
  let slope = @autodiff.diff(x => x.sin() * x.cos(), 0.0)
  println("d/dx sin x cos x at 0 = \{slope}")
}
```

```text
d/dx sin x cos x at 0 = 1
```

### Write generic code with the re-exported traits

All bounds come from the one import:

```moonbit
fn[T : @autodiff.Ring + @autodiff.Exponential + @autodiff.FromInteger] softplus_like(
  x : T,
) -> T {
  let one : T = @autodiff.FromInteger::from_integer(1N)
  one + @autodiff.Exponential::exp(x)
}

fn main {
  println("value at 0: \{softplus_like(0.0)}")
  println("slope at 0: \{@autodiff.diff(softplus_like, 0.0)}")
}
```

```text
value at 0: 2
slope at 0: 1
```

### Use mathematical constants

`Constants` gives $\pi$, $\tau$ and $e$ as dual constants:

```moonbit
fn main {
  let area_slope = @autodiff.diff(
    r => {
      let pi : @autodiff.Dual[Double] = @autodiff.Constants::pi()
      pi * r * r
    },
    2.0,
  )
  println("d/dr pi r^2 at 2 = \{area_slope}")
}
```

```text
d/dr pi r^2 at 2 = 12.566370614359172
```

### Handle a checked failure

```moonbit
fn main {
  let ctx = @autodiff.ArithmeticContext::new(53)
  let x = @autodiff.Dual::variable(2.0)
  match @autodiff.DivChecked::div_checked(x, x - x, ctx) {
    Ok(_) => println("unexpected")
    Err(e) => println("division by zero: \{e.is_division_by_zero()}")
  }
}
```

```text
division by zero: true
```

## Going further

- Seeding by hand, directional derivatives and finite-difference
  comparisons: the [dual tutorial](dual.md).
- Higher derivatives and Newton's method: the [forward tutorial](forward.md).
- Gradients and Jacobians: the [linalg tutorial](linalg.md).
- Polynomial derivatives: the [poly tutorial](poly.md).
- Checked operations in depth: the [checked tutorial](checked.md).

## Common pitfalls

- **The root package has no gradients.** Import `Luna-Flow/autodiff/linalg`
  for `gradient` and `jacobian`.
- **Re-exported traits are the original traits.** An instance you write for
  `@lg.Ring` is the instance of `@autodiff.Ring`; do not implement both.
- **Literals need `Dual::constant`** or `FromInteger::from_integer` inside
  differentiated code.

## Next steps

- The [autodiff API](../api/autodiff.md) lists every re-exported name.
- The [autodiff design](../design/autodiff.md) explains the facade.
- The [overview](../index.md) maps all packages.
