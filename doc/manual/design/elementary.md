# elementary design

This page explains the `elementary` facade: which analytic traits it
exposes, how their derivative rules are justified, and where they stop.

## Design goal

Make analytic code written against the `arithmetic` traits differentiable
without change, by exposing exactly the traits that `Dual[T]` implements
with a correct derivative rule.

## Mathematical background

Every rule has the form $f(a + b\varepsilon) = f(a) + f'(a)\,b\,\varepsilon$
(the [dual design](dual.md#smooth-functions-and-the-chain-rule) derives the
chain rule from it). The derivatives used are the classical ones; for the
inverse-function and base-change cases they follow from the chain rule:

$$
\begin{aligned}
\frac{d}{da}\sqrt a &= \frac{1}{2\sqrt a}
  &&\text{from } (\sqrt a)^2 = a, \\
\frac{d}{da}\,2^a &= \frac{d}{da}\,e^{a\ln 2} = 2^a \ln 2, \\
\frac{d}{da}\log_2 a &= \frac{d}{da}\frac{\ln a}{\ln 2} = \frac{1}{a\ln 2},
  &\frac{d}{da}\log_{10} a &= \frac{1}{a \ln 10}, \\
\frac{d}{da}\tan a &= \frac{d}{da}\frac{\sin a}{\cos a}
  = \frac{\cos^2 a + \sin^2 a}{\cos^2 a} = \frac{1}{\cos^2 a} .
\end{aligned}
$$

Each formula holds on the open domain where $f$ is differentiable: $a > 0$
for the square root and the logarithms, $\cos a \ne 0$ for the tangent, and
everywhere for $\exp$, $\sin$ and $\cos$.

## Design decisions

### Expose what `Dual[T]` implements

The facade re-exports `Sqrt`, `SqrtChecked`, `Exponential`, `Logarithmic`,
`Trigonometric` and `Constants`, the analytic traits with an instance on
`Dual[T]`. `arithmetic` also defines `Hyperbolic`, `InverseTrigonometric`,
`InverseHyperbolic`, `Cbrt` and `Power`; `Dual[T]` has no instance for them
yet, so they are not re-exported.

### Instances need the whole trait

A trait instance must provide all its methods. `Exponential` contains
`exp2`, whose rule needs $\ln 2$, so the instance needs `Logarithmic` and
`IntegralHomomorphism` on `T` even if a caller only uses `exp`. The inherent
method `Dual::exp` has the smaller bound `Exponential + Mul` for that case.

### Constants have tangent zero

$\pi$, $\tau$ and $e$ do not depend on the differentiation variable, so the
`Constants` instance embeds them with `Dual::constant`. This is the
structure-preserving choice: the map $T \to T[\varepsilon]$, $c \mapsto c +
0\varepsilon$, is a ring homomorphism.

## Correctness and invariants

- Each rule matches the derivative table above and is tested on `Double`
  (`sin`, `exp` and others in `src/tests/dual_test.mbt`).
- Outside the open domain, the result follows `T`: for `Double`, `ln(0)` is
  $-\infty$ with tangent $b/0$, and `sqrt` at $0$ has an infinite or NaN
  tangent.
- The tangent error is the error of `T`'s implementation of $f'(a)$ plus at
  most two roundings; see the [dual design](dual.md#rounding-error).

## Alternatives rejected

- **Re-exporting every analytic trait.** Bounds such as `T :
  Hyperbolic` would type-check for `T` but fail to instantiate at
  `Dual[T]`, which is confusing.
- **Checked logarithms in this repository.** `arithmetic` has no checked
  logarithm trait to implement; adding one locally would fork the error
  model.

## Boundaries

- No hyperbolic, inverse trigonometric, inverse hyperbolic, cube-root or
  general power rules.
- No checked forms other than `SqrtChecked`.
- No branch-cut or complex-domain semantics; see
  [luna-complex](https://lunaflow.cn/en/luna-complex/) for complex
  functions.
