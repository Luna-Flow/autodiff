# Repository conventions

These rules apply to the `autodiff` manual in addition to the Luna Flow
documentation standard.

## Page names

- The root package `Luna-Flow/autodiff` is documented as `autodiff`
  (`api/autodiff.md`, `tutorial/autodiff.md`, `design/autodiff.md`), because
  the name `core` belongs to the package `src/core`.
- Every other package page is named after its directory under `src/`.
- The `examples` and `tests` packages have no pages; the
  [overview](index.md) describes them.

## Terminology

- Keep package terminology aligned with the Luna Flow names from
  `luna-generic` and `arithmetic`.
- Call the components of a dual number its *value* and *tangent*, as the
  code does.
- Do not describe `Dual[T]` as a field or an ordered scalar.

## Examples

- Examples use the aliases `@autodiff`, `@dual`, `@forward`, `@linalg`,
  `@poly`, `@checked`, `@elementary`, `@ad_core` (for
  `Luna-Flow/autodiff/core`), `@la` (for `Luna-Flow/linear-algebra/immut`),
  `@dense` and `@sparse`.
- A program with `fn main` is followed by its exact output in a `text`
  block.

## Scope

- Future work must be clearly marked as future work.
