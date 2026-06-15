# Documentation Standard

Documentation for `Luna-Flow/autodiff` must describe the implementation on the
current branch. It must stay aligned with the exported MoonBit API, algebraic
constraints, and release scope.

## Rules

- Provide `README.md`, `doc_standard.md`, and subsystem documents for every
  supported locale.
- Document only APIs and behavior that exist in the current branch.
- Keep package terminology aligned with Luna Flow names from `luna-generic` and
  `arithmetic`.
- Do not describe `Dual[T]` as a field or ordered scalar.
- Future work must be clearly marked as future work.
- Each subsystem directory should contain `api.md`, `tutorial.md`, and
  `design.md`.
