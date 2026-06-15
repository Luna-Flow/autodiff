# Ecosystem Integration Design

## Dependency Direction

The integration packages sit above the core autodiff layers:

```text
autodiff/core       -> luna-generic only
autodiff/dual       -> luna-generic, arithmetic
autodiff/elementary -> arithmetic
autodiff/checked    -> arithmetic
autodiff/forward    -> core/dual/elementary
autodiff/linalg     -> autodiff + linear-algebra
autodiff/poly       -> autodiff + luna-poly
```

Lower-level packages do not import `linear-algebra`, `luna-poly`, `floating`, or
`type_theory`.

## Linear Algebra

`Dual[T]` is a valid scalar for ring-level vector and matrix operations because
it implements the relevant Luna Flow algebraic traits when `T` does. The
integration intentionally avoids algorithms that require `Field`, total
division, inverses, or total ordering.

Gradients and Jacobians use n-pass forward-mode seeding. This is simple,
correct, and keeps the API small. Vector-valued tangent storage is future work.

## Polynomial Evaluation

The polynomial bridge reuses `luna-poly` data structures. It lifts
coefficients to constants in `Dual[T]`, evaluates through the existing Luna Poly
algorithm, and reads the tangent as the derivative at the point.

This is automatic differentiation through evaluation, not symbolic
differentiation.
