///|
pub fn[T : Eq + Semiring] eval_dual(
  polynomial : DensePolynomial[T],
  x : Dual[T],
) -> Dual[T] {
  let coefficients = polynomial
    .to_coefficients()
    .map(fn(coefficient) { Dual::constant(coefficient) })
  let lifted = DensePolynomial::from_coefficients(coefficients)
  lifted.eval(x)
}

///|
pub fn[T : Eq + Semiring] value_and_derivative_at(
  polynomial : DensePolynomial[T],
  x : T,
) -> (T, T) {
  let result = eval_dual(polynomial, Dual::variable(x))
  (result.value(), result.tangent())
}

///|
pub fn[T : Eq + Semiring] derivative_at(
  polynomial : DensePolynomial[T],
  x : T,
) -> T {
  let (_, derivative) = value_and_derivative_at(polynomial, x)
  derivative
}

///|
pub fn[T : Eq + Semiring] eval_sparse_dual(
  polynomial : SparsePolynomial[T],
  x : Dual[T],
) -> Dual[T] {
  let terms = polynomial
    .to_terms()
    .map(fn(term) { (term.0, Dual::constant(term.1)) })
  let lifted = SparsePolynomial::from_terms(terms)
  lifted.eval([x])
}

///|
pub fn[T : Eq + Semiring] sparse_value_and_derivative_at(
  polynomial : SparsePolynomial[T],
  x : T,
) -> (T, T) {
  let result = eval_sparse_dual(polynomial, Dual::variable(x))
  (result.value(), result.tangent())
}

///|
pub fn[T : Eq + Semiring] sparse_derivative_at(
  polynomial : SparsePolynomial[T],
  x : T,
) -> T {
  let (_, derivative) = sparse_value_and_derivative_at(polynomial, x)
  derivative
}
