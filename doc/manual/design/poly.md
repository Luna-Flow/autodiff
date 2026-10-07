# poly design

The polynomial bridge reuses `luna-poly` data structures. It lifts
coefficients to constants in `Dual[T]`, evaluates through the existing Luna Poly
algorithm, and reads the tangent as the derivative at the point.

This is automatic differentiation through evaluation, not symbolic
differentiation.
