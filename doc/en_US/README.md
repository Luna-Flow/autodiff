# Luna Autodiff Documentation

English documentation for `Luna-Flow/autodiff` `0.1.0`.

## Overview

Luna Autodiff provides forward-mode automatic differentiation over Luna Flow
algebraic and arithmetic structures.

The current release introduces dual numbers:

```text
Dual[T] = value + tangent ε, ε² = 0
```

This lets ordinary scalar functions written against Luna Flow arithmetic be
evaluated together with their first derivative.

## Current Surface

- `Dual[T]` with `value` and `tangent`.
- Constructors: `Dual::new`, `Dual::constant`, and `Dual::variable`.
- Accessors: `Dual::value` and `Dual::tangent`.
- Ring-level algebraic instances where the base scalar supports them.
- Checked division and checked square root through `Luna-Flow/arithmetic`.
- Elementary lifts for `sqrt`, `exp`, `ln`, `sin`, `cos`, and `tan`.
- Forward helpers: `diff` and `value_and_diff`.

## Documents

- Core API: [core/api.md](core/api.md)
- Tutorial: [core/tutorial.md](core/tutorial.md)
- Design notes: [core/design.md](core/design.md)
- Documentation standard: [doc_standard.md](doc_standard.md)

## Validation

Recommended checks:

```bash
moon check
./run_test.sh
moon info
```
