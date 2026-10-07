# autodiff

This manual documents `Luna-Flow/autodiff` `0.2.0`.

## Overview

autodiff provides forward-mode automatic differentiation over Luna Flow
algebraic and arithmetic structures.

The current release introduces dual numbers:

```text
Dual[T] = value + tangent ε, ε² = 0
```

This lets ordinary scalar functions written against Luna Flow arithmetic be
evaluated together with their first derivative.

## Current surface

- `Dual[T]` with `value` and `tangent`.
- Constructors: `Dual::new`, `Dual::constant`, and `Dual::variable`.
- Accessors: `Dual::value` and `Dual::tangent`.
- Ring-level algebraic instances where the base scalar supports them.
- Checked division and checked square root through `Luna-Flow/arithmetic`.
- Elementary lifts for `sqrt`, `exp`, `ln`, `sin`, `cos`, and `tan`.
- Forward helpers: `diff` and `value_and_diff`.
- Linear algebra helpers: `gradient`, `jacobian`, `value_and_gradient`, and
  `value_and_jacobian` in `autodiff/linalg`.
- Polynomial helpers: dual-number evaluation and derivative-at-a-point helpers
  in `autodiff/poly`.

## Documents

- The [core API](api/core.md), [core tutorial](tutorial/core.md) and
  [core design](design/core.md) cover dual numbers and scalar differentiation.
- The [linalg API](api/linalg.md), [linalg tutorial](tutorial/linalg.md) and
  [linalg design](design/linalg.md) cover gradients and Jacobians over
  `linear-algebra` vectors and matrices.
- The [poly API](api/poly.md), [poly tutorial](tutorial/poly.md) and
  [poly design](design/poly.md) cover derivatives of `luna-poly` polynomials.
- The [repository conventions](conventions.md) fix the terminology used in this
  manual.

## Validation

Recommended checks:

```bash
moon check
./run_test.sh
moon info
```
