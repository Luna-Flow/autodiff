# autodiff

`Luna-Flow/autodiff` computes exact first derivatives of ordinary MoonBit
programs by forward-mode automatic differentiation. A program written
against the Luna Flow traits is run on dual numbers $a + b\varepsilon$ with
$\varepsilon^2 = 0$, and the derivative appears in the $\varepsilon$
component. The repository provides the dual-number type, scalar drivers,
checked domains for division and square roots, gradients and Jacobians over
`linear-algebra` vectors, and derivatives of `luna-poly` polynomials.

This manual documents version `0.2.0` on MoonBit 0.10.

## Packages

| Package | Import path | Role | Pages |
| --- | --- | --- | --- |
| `autodiff` | `Luna-Flow/autodiff` | one-stop facade: `Dual`, `diff`, `value_and_diff`, re-exported traits | [API](api/autodiff.md) · [tutorial](tutorial/autodiff.md) · [design](design/autodiff.md) |
| `dual` | `Luna-Flow/autodiff/dual` | the `Dual[T]` type, its arithmetic, rules and instances | [API](api/dual.md) · [tutorial](tutorial/dual.md) · [design](design/dual.md) |
| `forward` | `Luna-Flow/autodiff/forward` | scalar drivers `diff` and `value_and_diff` | [API](api/forward.md) · [tutorial](tutorial/forward.md) · [design](design/forward.md) |
| `core` | `Luna-Flow/autodiff/core` | algebraic facade: `Dual` and the `luna-generic` structure traits | [API](api/core.md) · [tutorial](tutorial/core.md) · [design](design/core.md) |
| `elementary` | `Luna-Flow/autodiff/elementary` | analytic facade: `Dual` and the `arithmetic` function traits | [API](api/elementary.md) · [tutorial](tutorial/elementary.md) · [design](design/elementary.md) |
| `checked` | `Luna-Flow/autodiff/checked` | checked facade: `DivChecked`, `SqrtChecked`, context and errors | [API](api/checked.md) · [tutorial](tutorial/checked.md) · [design](design/checked.md) |
| `linalg` | `Luna-Flow/autodiff/linalg` | gradients and Jacobians over `linear-algebra/immut` | [API](api/linalg.md) · [tutorial](tutorial/linalg.md) · [design](design/linalg.md) |
| `poly` | `Luna-Flow/autodiff/poly` | derivatives of dense and univariate sparse `luna-poly` polynomials | [API](api/poly.md) · [tutorial](tutorial/poly.md) · [design](design/poly.md) |

Two more packages have no manual pages. `examples` holds five small
functions (`basic_diff_example`, `square_diff_example`, `gradient_example`,
`jacobian_example`, `polynomial_derivative_example`) that show each layer in
a few lines; read [`src/examples/examples.mbt`](../../src/examples/examples.mbt).
`tests` is the black-box test suite of all packages, including the
`linear-algebra` and `luna-poly` integration tests. The
[architecture guide](architecture.md) shows how the packages depend on each
other, and the [repository conventions](conventions.md) record the naming
rules of this manual.

## Reading paths

**New to automatic differentiation.** Start with the
[autodiff tutorial](tutorial/autodiff.md), then the
[dual tutorial](tutorial/dual.md), which compares dual numbers with finite
differences.

**Using the library.** Import `Luna-Flow/autodiff` and keep the
[autodiff API](api/autodiff.md) and [dual API](api/dual.md) at hand; add
the [linalg tutorial](tutorial/linalg.md) or the
[poly tutorial](tutorial/poly.md) for vectors and polynomials, and the
[checked tutorial](tutorial/checked.md) when failures must be values.

**Contributing.** Read the [dual design](design/dual.md) for the algebra,
the derivative rules and the error bounds that every new operation must
respect, then the [architecture guide](architecture.md) and the design page
of the package you change.

## Installation

```bash
moon add Luna-Flow/autodiff@0.2.0
```

The bridges need their libraries too: `moon add Luna-Flow/linear-algebra`
for `linalg` and `moon add Luna-Flow/luna-poly` for `poly`.

## Toolchain

The code and the examples in this manual require MoonBit `moonc` 0.10 or
newer and the `moon.mod` / `moon.pkg` manifest format. The test suite runs
on the `wasm-gc`, `wasm`, `js` and `native` targets.

## Validation

```bash
moon check --target all
./run_test.sh
moon info
```
