# dual tutorial

This tutorial computes derivatives by hand with `Dual[T]`: you seed the
inputs, run ordinary arithmetic, and read the derivative from the tangent.
By the end you can differentiate expressions of several variables in any
direction, write one generic function for plain and dual numbers, and handle
division and square-root failures as data. The mathematics is in the
[dual design](../design/dual.md).

## Quick start

Add the module to your project:

```bash
moon add Luna-Flow/autodiff@0.2.0
```

Import the root package in your `moon.pkg`; it re-exports `Dual` and the
traits used below:

```moonbit nocheck
import {
  "Luna-Flow/autodiff",
}
```

Seed $x = 1.5$ as the variable and evaluate $f(x) = x^3 + 2x$:

```moonbit
fn main {
  let x = @autodiff.Dual::variable(1.5)
  let two = @autodiff.Dual::constant(2.0)
  let y = x * x * x + two * x
  println("f(1.5)  = \{y.value()}")
  println("f'(1.5) = \{y.tangent()}")
}
```

```text
f(1.5)  = 6.375
f'(1.5) = 8.75
```

The tangent is $f'(1.5) = 3 \cdot 1.5^2 + 2 = 8.75$.

## Everyday tasks

### Mix constants into a computation

Every value that is not the differentiation variable enters as a constant
with tangent zero. Literals cannot be mixed with dual numbers directly, so
wrap them with `Dual::constant`:

```moonbit
fn main {
  let rate = 0.25
  let x = @autodiff.Dual::variable(2.0)
  let y = @autodiff.Dual::constant(rate) * x.exp()
  println("d/dx 0.25 e^x at 2 = \{y.tangent()}")
}
```

```text
d/dx 0.25 e^x at 2 = 1.8472640247326626
```

### Use the elementary functions

`sqrt`, `exp`, `exp2`, `ln`, `log2`, `log10`, `sin`, `cos` and `tan` are
methods of `Dual[T]` and apply the chain rule for you:

```moonbit
fn main {
  let x = @autodiff.Dual::variable(1.0)
  let y = x.sin().exp() // e^(sin x)
  println("value      = \{y.value()}")
  println("derivative = \{y.tangent()}")
  println("cos(1) e^(sin 1) = \{@math.cos(1.0) * @math.exp(@math.sin(1.0))}")
}
```

```text
value      = 2.319776824715853
derivative = 1.253380767493447
cos(1) e^(sin 1) = 1.253380767493447
```

The second and third lines agree: the tangent is $\cos(1)\,e^{\sin 1}$.

### Differentiate in a chosen direction

With several inputs, the tangents you seed choose the direction. Seeding
$(x, y) = (2, 3)$ with tangents $(1, 0)$ gives $\partial f/\partial x$;
tangents $(v_1, v_2)$ give the directional derivative $\nabla f \cdot v$:

```moonbit
fn f(x : @autodiff.Dual[Double], y : @autodiff.Dual[Double]) -> @autodiff.Dual[Double] {
  x * y + x.sin()
}

fn main {
  let dx = f(@autodiff.Dual::new(2.0, 1.0), @autodiff.Dual::new(3.0, 0.0))
  let dy = f(@autodiff.Dual::new(2.0, 0.0), @autodiff.Dual::new(3.0, 1.0))
  let dv = f(@autodiff.Dual::new(2.0, 0.5), @autodiff.Dual::new(3.0, -1.0))
  println("df/dx = \{dx.tangent()}")
  println("df/dy = \{dy.tangent()}")
  println("grad . (0.5, -1) = \{dv.tangent()}")
}
```

```text
df/dx = 2.5838531634528574
df/dy = 2
grad . (0.5, -1) = -0.7080734182735712
```

For whole gradients and Jacobians, the [linalg tutorial](linalg.md) does
this seeding for you.

### Compare with a finite difference

A central difference needs a step size and loses digits; the dual result is
exact up to rounding:

```moonbit
fn g(x : Double) -> Double {
  @math.exp(@math.sin(x))
}

fn main {
  let exact = @math.cos(1.0) * g(1.0)
  let dual = @autodiff.Dual::variable(1.0).sin().exp().tangent()
  for h in [1.0e-2, 1.0e-5, 1.0e-8] {
    let central = (g(1.0 + h) - g(1.0 - h)) / (2.0 * h)
    println("h = \{h}: error \{(central - exact).abs()}")
  }
  println("dual: error \{(dual - exact).abs()}")
}
```

```text
h = 0.01: error 0.00006752362465478612
h = 0.00001: error 7.4792172455318e-11
h = 1e-8: error 9.450921378828525e-9
dual: error 0
```

The finite-difference error first falls with $h$ and then rises again as
cancellation takes over, exactly as derived in the
[dual design](../design/dual.md#comparison-with-finite-differences).

### Write one function for plain and dual numbers

Write the function against the traits it needs. The same code then runs on
`Double` and, for derivatives, on `Dual[Double]`. Integer constants come
from `IntegralHomomorphism::from_integral`:

```moonbit
fn[T : @autodiff.Ring + @autodiff.IntegralHomomorphism + @autodiff.Trigonometric] h(
  x : T,
) -> T {
  let three : T = @autodiff.IntegralHomomorphism::from_integral(3)
  three * x * x + @autodiff.Trigonometric::cos(x)
}

fn main {
  println("h(0.5)  = \{h(0.5)}")
  let d = h(@autodiff.Dual::variable(0.5))
  println("h(0.5)  = \{d.value()} (dual value)")
  println("h'(0.5) = \{d.tangent()}")
}
```

```text
h(0.5)  = 1.6275825618903728
h(0.5)  = 1.6275825618903728 (dual value)
h'(0.5) = 2.520574461395797
```

The value computed on dual numbers is bit-for-bit the value computed on
`Double`; the tangent is $6x - \sin x$ at $0.5$.

### Report division and square-root failures

`div_checked` and `sqrt_checked` return a `Result` with the `arithmetic`
error instead of an infinity or NaN:

```moonbit
fn main {
  let ctx = @autodiff.ArithmeticContext::new(53)
  for a in [4.0, 0.0, -1.0] {
    match @autodiff.Dual::variable(a).sqrt_checked(ctx) {
      Ok(r) => println("sqrt(\{a}): value \{r.value()}, derivative \{r.tangent()}")
      Err(e) =>
        println(
          "sqrt(\{a}): domain error \{e.is_domain_error()}, division by zero \{e.is_division_by_zero()}",
        )
    }
  }
}
```

```text
sqrt(4): value 2, derivative 0.25
sqrt(0): domain error false, division by zero true
sqrt(-1): domain error true, division by zero false
```

At $0$ the square root exists but its derivative does not, so the tangent
division fails.

## Going further

### Second derivatives by nesting

`Dual[T]` is generic, so `T` can itself be a dual number. Differentiating
a derivative needs the inner function to be generic, which the
[forward tutorial](forward.md) shows with `diff`. By hand:

```moonbit
fn[T : @autodiff.Ring] cube(x : T) -> T {
  x * x * x
}

fn main {
  // outer variable: tangent 1 on the outer level
  let outer : @autodiff.Dual[Double] = @autodiff.Dual::variable(2.0)
  // inner variable: the outer number, seeded with tangent 1 on the inner level
  let inner = @autodiff.Dual::new(outer, @autodiff.Dual::constant(1.0))
  let y = cube(inner)
  println("f   = \{y.value().value()}")
  println("f'  = \{y.tangent().value()}")
  println("f'' = \{y.tangent().tangent()}")
}
```

```text
f   = 8
f'  = 12
f'' = 12
```

The two levels are different types, so tangents of the inner and the outer
derivative cannot be mixed up.

### Your own scalar type

Any `T` with the bounds of the methods you call works. A ring-only type such
as `Int` already supports the product rule:

```moonbit
fn main {
  let x : @autodiff.Dual[Int] = @autodiff.Dual::variable(5)
  let y = x * x * x
  println("d/dx x^3 at 5 = \{y.tangent()}")
}
```

```text
d/dx x^3 at 5 = 75
```

To differentiate through `exp` or `sin` with your own type, implement
`Exponential` or `Trigonometric` from `Luna-Flow/arithmetic` for it.

## Common pitfalls

- **Literals are not dual numbers.** `x * 2.0` does not compile when `x` is
  a `Dual[Double]`. Write `x * @autodiff.Dual::constant(2.0)`, or use
  `IntegralHomomorphism::from_integral(2)` in generic code.
- **Comparisons see only what you compare.** `Dual[T]` has no `<`. Compare
  `x.value()`; the derivative is then the derivative of the branch taken, so
  functions such as `abs` written with a branch have the one-sided derivative
  at the kink.
- **Equality includes the tangent.** `Dual::new(1.0, 0.0) == Dual::new(1.0,
  1.0)` is `false`.
- **Unchecked operations follow `Double`.** `x / y` with `y.value() == 0.0`,
  `ln` of a negative number or `sqrt` at zero give infinities or NaN in the
  tangent. Use the checked forms when that must not happen.
- **Tiny divisors.** The quotient rule divides by $c^2$, which underflows
  for $|c| < 1.5 \times 10^{-162}$; rescale before dividing.
- **No printing.** `Dual[T]` has no `Show`. Print `value()` and `tangent()`,
  or use `debug_inspect` and `@debug.to_string` from `Debug`.

## Next steps

- The [dual API](../api/dual.md) lists every method, rule and instance.
- The [dual design](../design/dual.md) derives the rules and the error
  bounds.
- The [forward tutorial](forward.md) wraps the seeding in `diff` and
  `value_and_diff`; the [linalg tutorial](linalg.md) computes gradients and
  Jacobians; the [poly tutorial](poly.md) differentiates polynomials.
- The scalar traits come from
  [luna-generic](https://lunaflow.cn/en/luna-generic/) and
  [arithmetic](https://lunaflow.cn/en/arithmetic/).
