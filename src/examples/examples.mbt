///|
pub fn basic_diff_example() -> Double {
  let x = @dual.Dual::variable(2.0)
  let y = x * x + x
  y.tangent()
}

///|
pub fn square_diff_example() -> Double {
  let x = @dual.Dual::variable(2.0)
  (x * x).tangent()
}

///|
pub fn gradient_example() -> @la.Vector[Double] {
  let x = @la.Vector::from_array([2.0, 3.0])
  @linalg.gradient(
    fn(v : @la.Vector[@dual.Dual[Double]]) { v[0] * v[0] + v[0] * v[1] },
    x,
  )
}

///|
pub fn jacobian_example() -> @la.Matrix[Double] {
  let x = @la.Vector::from_array([2.0, 3.0])
  @linalg.jacobian(
    fn(v : @la.Vector[@dual.Dual[Double]]) {
      @la.Vector::from_array([v[0] + v[1], v[0] * v[1]])
    },
    x,
  )
}

///|
pub fn polynomial_derivative_example() -> Double {
  let polynomial = @dense.DensePolynomial::from_coefficients([1.0, 2.0, 1.0])
  @poly.derivative_at(polynomial, 3.0)
}
