# elementary tutorial

This tutorial differentiates analytic code written against the
`arithmetic` traits. You will write a function once with `Exponential`,
`Logarithmic` and `Trigonometric` bounds, evaluate it on `Double`, and get
its derivative by running it on `Dual[Double]`. The rules behind it are in
the [elementary design](../design/elementary.md).

| I want to | Use |
| --- | --- |
| differentiate `exp`, `ln`, `sin`, ... | the methods `x.exp()`, `x.ln()`, `x.sin()`, ... |
| write generic analytic code | bounds such as `T : @elementary.Exponential` |
| use other bases | `exp2`, `log2`, `log10` |
| use $\pi$, $\tau$ or $e$ | `@elementary.Constants::pi()`, `tau()`, `e()` |
| a square root that reports errors | `SqrtChecked::sqrt_checked` |

## Quick start

```bash
moon add Luna-Flow/autodiff@0.2.0
```

```moonbit nocheck
import {
  "Luna-Flow/autodiff/elementary",
}
```

```moonbit
fn[T : @elementary.Trigonometric + Mul] sin_squared(x : T) -> T {
  let s = @elementary.Trigonometric::sin(x)
  s * s
}

fn main {
  let y = sin_squared(@elementary.Dual::variable(0.5))
  println("sin^2(0.5) = \{y.value()}")
  println("derivative = \{y.tangent()}")
}
```

```text
sin^2(0.5) = 0.22984884706593015
derivative = 0.8414709848078965
```

The derivative is $2\sin x\cos x = \sin 2x$, here $\sin 1$.

## Everyday tasks

### Logarithms and exponentials

```moonbit
fn[T : @elementary.Exponential + @elementary.Logarithmic + Mul] f(x : T) -> T {
  @elementary.Exponential::exp(x) * @elementary.Logarithmic::ln(x)
}

fn main {
  let y = f(@elementary.Dual::variable(1.0))
  println("f(1) = \{y.value()}, f'(1) = \{y.tangent()}")
}
```

```text
f(1) = 0, f'(1) = 2.718281828459045
```

$(e^x \ln x)' = e^x \ln x + e^x/x$, which is $e$ at $x = 1$.

### Other bases

`exp2`, `log2` and `log10` include the base-change factors:

```moonbit
fn main {
  let x = @elementary.Dual::variable(3.0)
  println("d/dx 2^x at 3     = \{x.exp2().tangent()}")
  println("d/dx log2 x at 3  = \{x.log2().tangent()}")
  println("d/dx log10 x at 3 = \{x.log10().tangent()}")
}
```

```text
d/dx 2^x at 3     = 5.545177444479562
d/dx log2 x at 3  = 0.48089834696298783
d/dx log10 x at 3 = 0.14476482730108392
```

### Constants inside generic code

```moonbit
fn[T : @elementary.Trigonometric + @elementary.Constants + Mul] wave(t : T) -> T {
  let tau : T = @elementary.Constants::tau()
  @elementary.Trigonometric::sin(tau * t)
}

fn main {
  let y = wave(@elementary.Dual::variable(0.0))
  println("slope at 0 = \{y.tangent()}")
}
```

```text
slope at 0 = 6.283185307179586
```

The constant $\tau = 2\pi$ has tangent zero, so only $t$ is differentiated.

### The tangent and its poles

```moonbit
fn main {
  for a in [0.0, 1.0, 1.5] {
    let y = @elementary.Dual::variable(a).tan()
    println("tan'(\{a}) = \{y.tangent()}")
  }
}
```

```text
tan'(0) = 1
tan'(1) = 3.425518820814759
tan'(1.5) = 199.8500445264925
```

The derivative $1/\cos^2 a$ grows without bound towards $\pi/2$.

## Going further

- Combine the analytic traits with `Ring` from the root package or `core` to
  write full models; see the [autodiff tutorial](autodiff.md).
- For a custom scalar, implement `Exponential`, `Logarithmic` and
  `Trigonometric`; `Dual` of it then differentiates them with the same
  rules.
- For domain-checked square roots, use `SqrtChecked`, see the
  [checked tutorial](checked.md).

## Common pitfalls

- **Outside the domain you get NaN or infinity.** `ln` of a non-positive
  number and `sqrt` at zero are not checked. `ln` of a negative number has a
  NaN value but a finite tangent, so test the value.
- **The trait instances need more than the method.** Calling
  `@elementary.Exponential::exp` on `Dual[T]` needs the full instance bound
  (`Logarithmic` and `IntegralHomomorphism` on `T`); the method `x.exp()`
  needs less.
- **No hyperbolic or inverse functions.** `sinh`, `asin`, `atan` and friends
  have no dual rule yet; compose them from the available functions if you
  need them.

## Next steps

- The [elementary API](../api/elementary.md) lists the traits and bounds.
- The [dual API](../api/dual.md#elementary-functions) lists every rule as
  computed.
- [arithmetic](https://lunaflow.cn/en/arithmetic/) documents the traits.
