# autodiff

This manual documents the unreleased `main` branch of `Luna-Flow/autodiff`
(version `0.2.0` in `moon.mod`) after its migration to MoonBit 0.10.

## Overview

`Luna-Flow/autodiff` computes exact first derivatives of ordinary MoonBit
programs by forward-mode automatic differentiation. A program written
against the Luna Flow traits is run on dual numbers $a + b\varepsilon$ with
$\varepsilon^2 = 0$, and the derivative appears in the $\varepsilon$
component. The repository provides the dual-number type, scalar drivers,
checked domains for division and square roots, gradients and Jacobians over
`linear-algebra` vectors, and derivatives of `luna-poly` polynomials.

- `Dual[T]` is generic over the scalar and implements exactly the
  ring-level traits of `luna-generic`: no `Field`, `Inverse` or order,
  because $\varepsilon$ has no inverse.
- Every elementary rule is $f(a + b\varepsilon) = f(a) + f'(a)\,b\,\varepsilon$,
  and the chain rule follows from composition.
- Gradients and Jacobians take one forward pass per input; there is no
  reverse mode.

## Install

```bash
moon add Luna-Flow/autodiff@0.2.0
```

Then import the root package in your `moon.pkg`:

```moonbit nocheck
import {
  "Luna-Flow/autodiff",
}
```

The bridges need their libraries too: `moon add Luna-Flow/linear-algebra`
for `linalg` and `moon add Luna-Flow/luna-poly` for `poly`. The code needs
the MoonBit toolchain 0.10 or later (`moonc` ≥ 0.10) with `moon.mod` /
`moon.pkg` manifests, and the test suite runs on the `wasm-gc`, `wasm`, `js`
and `native` targets.

> [!IMPORTANT]
> The checked operations report the errors of `T`'s own `DivChecked` and
> `SqrtChecked`. This manual describes `Double` as implemented by
> `Luna-Flow/arithmetic` 0.5, the version the repository is developed
> against. `moon.mod` still pins `arithmetic@0.2.1`, whose `Double`
> `sqrt_checked` never fails (a negative input gives NaN) and whose
> `div_checked` reports every zero divisor, including $0/0$, as a division
> by zero. See the [checked API](api/checked.md#versions-of-arithmetic).

## Pages

The root package `Luna-Flow/autodiff` is documented as `autodiff`, because
the name `core` belongs to the package `src/core`. Every other page is named
after its directory under `src/`.

| Part | Tutorial | API | Design |
| --- | --- | --- | --- |
| `autodiff`: one-stop facade with `Dual`, `diff`, `value_and_diff` and the re-exported traits | [tutorial](tutorial/autodiff.md) | [API](api/autodiff.md) | [design](design/autodiff.md) |
| `dual`: the `Dual[T]` type, its arithmetic, derivative rules and instances | [tutorial](tutorial/dual.md) | [API](api/dual.md) | [design](design/dual.md) |
| `forward`: scalar drivers `diff` and `value_and_diff` | [tutorial](tutorial/forward.md) | [API](api/forward.md) | [design](design/forward.md) |
| `core`: algebraic facade, `Dual` and the `luna-generic` structure traits | [tutorial](tutorial/core.md) | [API](api/core.md) | [design](design/core.md) |
| `elementary`: analytic facade, `Dual` and the `arithmetic` function traits | [tutorial](tutorial/elementary.md) | [API](api/elementary.md) | [design](design/elementary.md) |
| `checked`: checked facade, `DivChecked`, `SqrtChecked`, context and errors | [tutorial](tutorial/checked.md) | [API](api/checked.md) | [design](design/checked.md) |
| `linalg`: gradients and Jacobians over `linear-algebra/immut` | [tutorial](tutorial/linalg.md) | [API](api/linalg.md) | [design](design/linalg.md) |
| `poly`: derivatives of dense and univariate sparse `luna-poly` polynomials | [tutorial](tutorial/poly.md) | [API](api/poly.md) | [design](design/poly.md) |
| Guides | [architecture](architecture.md) | [conventions](conventions.md) | |

Two more packages have no manual pages. `examples` holds five small
functions (`basic_diff_example`, `square_diff_example`, `gradient_example`,
`jacobian_example`, `polynomial_derivative_example`) that show each layer in
a few lines; read [`src/examples/examples.mbt`](../../src/examples/examples.mbt).
`tests` is the black-box test suite of all packages, including the
`linear-algebra` and `luna-poly` integration tests.

## Exported items

### The number type

- `Dual[T]` with `Dual::new`, `constant`, `variable`, `value`, `tangent`,
  `zero` and `one`
- Arithmetic: `add`, `sub`, `neg`, `mul`, `div` and `equal`, also as
  operators
- Elementary rules: `sqrt`, `exp`, `exp2`, `ln`, `log2`, `log10`, `sin`,
  `cos`, `tan`
- Checked forms: `div_checked`, `sqrt_checked`

### Drivers

- Scalar: `diff`, `value_and_diff`
- Vector: `gradient`, `value_and_gradient`, `jacobian`,
  `value_and_jacobian`
- Polynomial: `eval_dual`, `dense_value_and_derivative_at`,
  `dense_derivative_at`, the `sparse_univariate_*` functions and their
  compatibility names

### Re-exported vocabulary

- From `luna-generic`: `Zero`, `One`, `AddMonoid`, `AddGroup`, `MulMonoid`,
  `Semiring`, `Ring`, `IntegralHomomorphism`
- From `arithmetic`: `Sqrt`, `SqrtChecked`, `Exponential`, `Logarithmic`,
  `Trigonometric`, `Constants`, `DivChecked`, `ArithmeticContext`,
  `ArithmeticError`, `ArithmeticErrorKind`, `RoundingMode`
- From `linear-algebra` and `luna-poly`: `Vector`, `Matrix`,
  `DensePolynomial`, `SparsePolynomial` in the bridge packages

## Where to read next

The [autodiff tutorial](tutorial/autodiff.md) differentiates a function
with one import. The [dual API](api/dual.md) lists every rule and instance
of the number type, and the [dual design](design/dual.md) derives them,
with the rounding error bounds and the comparison with finite differences.

- New to automatic differentiation: read the
  [autodiff tutorial](tutorial/autodiff.md), then the
  [dual tutorial](tutorial/dual.md), which compares dual numbers with finite
  differences.
- Using it in a library: import `Luna-Flow/autodiff` and keep the
  [autodiff API](api/autodiff.md) and the [dual API](api/dual.md) at hand;
  add the [linalg tutorial](tutorial/linalg.md) or the
  [poly tutorial](tutorial/poly.md) for vectors and polynomials, and the
  [checked tutorial](tutorial/checked.md) when failures must be values.
- Contributing: read the [dual design](design/dual.md) for the algebra, the
  derivative rules and the error bounds that every new operation must
  respect, then the [architecture guide](architecture.md), the
  [repository conventions](conventions.md) and the design page of the
  package you change.

## Validation

Recommended release checks:

```bash
moon check --target all
./run_test.sh
moon info
```
