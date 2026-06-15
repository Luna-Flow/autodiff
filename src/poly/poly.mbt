///|
/// Evaluates a dense polynomial at a dual input.
///
/// If `x = a + dx e`, the result has primal part `p(a)` and tangent part
/// `p'(a) * dx`. This is evaluation-based automatic differentiation, not
/// symbolic differentiation.
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
/// Evaluates a dense polynomial and its first derivative at `x`.
///
/// This helper seeds `x` as a dual variable, so the returned tangent is `p'(x)`.
pub fn[T : Eq + Semiring] dense_value_and_derivative_at(
  polynomial : DensePolynomial[T],
  x : T,
) -> (T, T) {
  let result = eval_dual(polynomial, Dual::variable(x))
  (result.value(), result.tangent())
}

///|
/// Evaluates the first derivative of a dense polynomial at `x`.
pub fn[T : Eq + Semiring] dense_derivative_at(
  polynomial : DensePolynomial[T],
  x : T,
) -> T {
  let (_, derivative) = dense_value_and_derivative_at(polynomial, x)
  derivative
}

///|
/// Compatibility name for `dense_value_and_derivative_at`.
pub fn[T : Eq + Semiring] value_and_derivative_at(
  polynomial : DensePolynomial[T],
  x : T,
) -> (T, T) {
  dense_value_and_derivative_at(polynomial, x)
}

///|
/// Compatibility name for `dense_derivative_at`.
pub fn[T : Eq + Semiring] derivative_at(
  polynomial : DensePolynomial[T],
  x : T,
) -> T {
  dense_derivative_at(polynomial, x)
}

///|
/// Evaluates a sparse polynomial as a single-variable polynomial at a dual input.
///
/// `luna-poly` sparse polynomials can represent multivariate terms, but this
/// bridge currently evaluates with the single assignment `[x]`. The primal part
/// is `p(x)`, and the tangent part is the univariate derivative contribution
/// `p'(x) * dx`. This is not a multivariate partial-derivative API.
pub fn[T : Eq + Semiring] sparse_univariate_eval_dual(
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
/// Evaluates a sparse polynomial as a single-variable polynomial and returns
/// `(p(x), p'(x))`.
pub fn[T : Eq + Semiring] sparse_univariate_value_and_derivative_at(
  polynomial : SparsePolynomial[T],
  x : T,
) -> (T, T) {
  let result = sparse_univariate_eval_dual(polynomial, Dual::variable(x))
  (result.value(), result.tangent())
}

///|
/// Evaluates the single-variable derivative of a sparse polynomial at `x`.
pub fn[T : Eq + Semiring] sparse_univariate_derivative_at(
  polynomial : SparsePolynomial[T],
  x : T,
) -> T {
  let (_, derivative) = sparse_univariate_value_and_derivative_at(polynomial, x)
  derivative
}

///|
/// Compatibility name for `sparse_univariate_eval_dual`.
pub fn[T : Eq + Semiring] eval_sparse_dual(
  polynomial : SparsePolynomial[T],
  x : Dual[T],
) -> Dual[T] {
  sparse_univariate_eval_dual(polynomial, x)
}

///|
/// Compatibility name for `sparse_univariate_value_and_derivative_at`.
pub fn[T : Eq + Semiring] sparse_value_and_derivative_at(
  polynomial : SparsePolynomial[T],
  x : T,
) -> (T, T) {
  sparse_univariate_value_and_derivative_at(polynomial, x)
}

///|
/// Compatibility name for `sparse_univariate_derivative_at`.
pub fn[T : Eq + Semiring] sparse_derivative_at(
  polynomial : SparsePolynomial[T],
  x : T,
) -> T {
  sparse_univariate_derivative_at(polynomial, x)
}
