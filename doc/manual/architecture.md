# Architecture

This guide shows how the packages of `autodiff` depend on each other and on
the rest of Luna Flow, and which invariants keep the layers apart.

## Layers

`Dual[T]` is defined once, in `dual`, so that its methods and trait
instances live with the type. Everything else either re-exports it or uses
it:

```text
luna-generic   arithmetic
      \            /
       +-- dual --+
            |
            +-- forward -- autodiff (root facade, also re-exports dual)
            +-- core
            +-- elementary
            +-- checked
            +-- linalg  (+ linear-algebra/immut)
            +-- poly    (+ luna-poly/immut/dense, sparse)
```

| Package | Depends on | Kind |
| --- | --- | --- |
| `dual` | `luna-generic`, `arithmetic` | implementation |
| `forward` | `dual`, `luna-generic` | implementation |
| `core` | `dual`, `luna-generic` | facade |
| `elementary` | `dual`, `arithmetic` | facade |
| `checked` | `dual`, `arithmetic` | facade |
| `autodiff` | `dual`, `forward`, `luna-generic`, `arithmetic` | facade |
| `linalg` | `dual`, `luna-generic`, `linear-algebra/immut` | bridge |
| `poly` | `dual`, `luna-generic`, `luna-poly/immut/{dense,sparse}` | bridge |
| `examples` | `dual`, `linalg`, `poly`, `linear-algebra`, `luna-poly` | examples |
| `tests` | all of the above (test imports only) | tests |

## Invariants

- Only `dual` and `forward` contain behaviour among the light packages; the
  facades contain only `pub using` lines.
- No light package (`dual`, `forward`, `core`, `elementary`, `checked`, the
  root) imports `linear-algebra`, `luna-poly`, `floating` or `type_theory`.
  Users who need scalar derivatives do not pull in containers.
- The bridges depend on the light packages, never the other way round.
- Trait names are re-exported, never redefined, so instances are shared with
  the whole ecosystem.
- `Dual[T]` implements only ring-level structure traits; see the
  [dual design](design/dual.md#ring-level-instances-only).

## Where to add things

- A new derivative rule goes into `src/dual/dual.mbt`, with the rule stated
  in the [dual API](api/dual.md) and a regression test in `src/tests`.
- A new trait instance on `Dual[T]` needs a derivation of its laws in the
  [dual design](design/dual.md).
- A new bridge to another Luna Flow library is a new package next to
  `linalg` and `poly`.
- Method promotions for MoonBit 0.10 live in `src/dual/extends.mbt`.
