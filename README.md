# autodiff

`Luna-Flow/autodiff` provides forward-mode automatic differentiation for
MoonBit. Run a function on dual numbers $a + b\varepsilon$ with
$\varepsilon^2 = 0$ and you get its value and its exact first derivative in
one pass, with no step size and no symbolic algebra. `Dual[T]` is generic
over the Luna Flow scalar traits, and bridges compute gradients and
Jacobians over `linear-algebra` vectors and derivatives of `luna-poly`
polynomials.

## Install

```bash
moon add Luna-Flow/autodiff@0.3.0
```

```moonbit nocheck
// moon.pkg
import {
  "Luna-Flow/autodiff",
}
```

## Example

```moonbit
fn main {
  let (value, slope) = @autodiff.value_and_diff(x => x * x + x.sin(), 2.0)
  println("f(2) = \{value}, f'(2) = \{slope}")
}
```

```text
f(2) = 4.909297426825682, f'(2) = 3.5838531634528574
```

## Packages

| Package | Purpose |
| --- | --- |
| `Luna-Flow/autodiff` | facade: `Dual`, `diff`, `value_and_diff`, re-exported traits and error types |
| `Luna-Flow/autodiff/dual` | `Dual[T]`: arithmetic, derivative rules, checked division and square root, trait instances |
| `Luna-Flow/autodiff/forward` | scalar drivers `diff` and `value_and_diff` |
| `Luna-Flow/autodiff/core` | algebraic facade (`Dual` and `luna-generic` structure traits) |
| `Luna-Flow/autodiff/elementary` | analytic facade (`Sqrt`, `Exponential`, `Logarithmic`, `Trigonometric`, `Constants`) |
| `Luna-Flow/autodiff/checked` | checked facade (`DivChecked`, `SqrtChecked`, `ArithmeticContext`, `ArithmeticError`) |
| `Luna-Flow/autodiff/linalg` | `gradient`, `jacobian` and their `value_and_*` forms over `linear-algebra/immut` |
| `Luna-Flow/autodiff/poly` | derivatives of dense and univariate sparse `luna-poly` polynomials |

`Dual[T]` implements the ring-level traits of `luna-generic` and no `Field`,
`Inverse` or order, because $\varepsilon$ has no inverse. Gradients use one
forward pass per input. Reverse mode, higher-order (jet) types, symbolic
differentiation and multivariate polynomial partial derivatives are not part
of this release.

## Toolchain

MoonBit `moonc` 0.10 or newer, with `moon.mod` / `moon.pkg` manifests. Tests
run on `wasm-gc`, `wasm`, `js` and `native`.

The checked operations return the errors of the scalar's own instances; the
[checked API](doc/manual/api/checked.md) lists them for `Double` from
`Luna-Flow/arithmetic` 0.5.

## Documentation

The manual, with API, tutorial and design pages for every package and
Chinese and Japanese translations, is published at
<https://lunaflow.cn/en/autodiff/>. Its English source is
[`doc/manual/index.md`](doc/manual/index.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and the
[correctness checklist](CORRECTNESS_CHECKLIST.md). Run `./ready_to_pr.sh`
before opening a pull request.

## License

Apache-2.0, as declared in `moon.mod`.
