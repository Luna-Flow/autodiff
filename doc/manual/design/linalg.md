# linalg design

`Dual[T]` is a valid scalar for ring-level vector and matrix operations because
it implements the relevant Luna Flow algebraic traits when `T` does. The
integration intentionally avoids algorithms that require `Field`, total
division, inverses, or total ordering.

Gradients and Jacobians use n-pass forward-mode seeding. This is simple,
correct, and keeps the API small. Vector-valued tangent storage is future work.
