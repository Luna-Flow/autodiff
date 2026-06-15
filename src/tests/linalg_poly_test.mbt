///|
fn approx_vec_eq(a : @la.Vector[Double], b : @la.Vector[Double]) -> Bool {
  if a.length() != b.length() {
    return false
  }
  for i in 0..<a.length() {
    if !approx_eq(a[i], b[i]) {
      return false
    }
  }
  true
}

///|
fn approx_matrix_eq(a : @la.Matrix[Double], b : @la.Matrix[Double]) -> Bool {
  if a.row() != b.row() || a.col() != b.col() {
    return false
  }
  for i in 0..<a.row() {
    for j in 0..<a.col() {
      if !approx_eq(a[i][j], b[i][j]) {
        return false
      }
    }
  }
  true
}

///|
fn dot_dual(
  a : @la.Vector[Double],
  x : @la.Vector[@autodiff.Dual[Double]],
) -> @autodiff.Dual[Double] {
  let mut result = @autodiff.Dual::constant(0.0)
  for i in 0..<a.length() {
    result = result + @autodiff.Dual::constant(a[i]) * x[i]
  }
  result
}

///|
test "linalg gradient handles dot product" {
  let a = @la.Vector::from_array([2.0, -3.0, 5.0])
  let x = @la.Vector::from_array([7.0, 11.0, 13.0])
  let gradient = @linalg.gradient(fn(v) { dot_dual(a, v) }, x)
  assert_eq(approx_vec_eq(gradient, a), true)
}

///|
test "linalg gradient handles symmetric quadratic form" {
  let matrix = @la.Matrix::from_2d_array([[2.0, 1.0], [1.0, 3.0]])
  let x = @la.Vector::from_array([4.0, 5.0])
  let gradient = @linalg.gradient(
    fn(v : @la.Vector[@autodiff.Dual[Double]]) {
      let mut result = @autodiff.Dual::constant(0.0)
      for i in 0..<v.length() {
        for j in 0..<v.length() {
          result = result + v[i] * @autodiff.Dual::constant(matrix[i][j]) * v[j]
        }
      }
      result
    },
    x,
  )
  let expected = @la.Vector::from_array([26.0, 38.0])
  assert_eq(approx_vec_eq(gradient, expected), true)
}

///|
test "linalg jacobian uses output by input orientation" {
  let x = @la.Vector::from_array([2.0, 3.0])
  let jacobian = @linalg.jacobian(
    fn(v : @la.Vector[@autodiff.Dual[Double]]) {
      @la.Vector::from_array([v[0] + v[1], v[0] * v[1], v[0] * v[0]])
    },
    x,
  )
  let expected = @la.Matrix::from_2d_array([[1.0, 1.0], [3.0, 2.0], [4.0, 0.0]])
  assert_eq(approx_matrix_eq(jacobian, expected), true)
}

///|
test "linear algebra consumes dual values as ring scalars" {
  let left = @la.Matrix::from_2d_array([
    [@autodiff.Dual::new(1.0, 1.0), @autodiff.Dual::constant(2.0)],
    [@autodiff.Dual::constant(3.0), @autodiff.Dual::new(4.0, 1.0)],
  ])
  let right = @la.Matrix::identity(2)
  let product = left * right
  assert_eq(approx_eq(product[0][0].value(), 1.0), true)
  assert_eq(approx_eq(product[0][0].tangent(), 1.0), true)
  assert_eq(approx_eq(product[1][1].value(), 4.0), true)
  assert_eq(approx_eq(product[1][1].tangent(), 1.0), true)
}

///|
test "poly dense quadratic derivative through dual evaluation" {
  let polynomial = @dense.DensePolynomial::from_coefficients([1.0, 2.0, 1.0])
  let (value, derivative) = @poly.value_and_derivative_at(polynomial, 3.0)
  assert_eq(approx_eq(value, 16.0), true)
  assert_eq(approx_eq(derivative, 8.0), true)
}

///|
test "poly dense cubic derivative through dual evaluation" {
  let polynomial = @dense.DensePolynomial::from_coefficients([
    1.0, 2.0, 0.0, 1.0,
  ])
  let (value, derivative) = @poly.value_and_derivative_at(polynomial, 3.0)
  assert_eq(approx_eq(value, 34.0), true)
  assert_eq(approx_eq(derivative, 29.0), true)
}

///|
test "poly dense constant derivative is zero" {
  let polynomial = @dense.DensePolynomial::from_coefficients([42.0])
  assert_eq(approx_eq(@poly.derivative_at(polynomial, 3.0), 0.0), true)
}

///|
test "poly dense linear derivative is slope" {
  let polynomial = @dense.DensePolynomial::from_coefficients([7.0, -4.0])
  assert_eq(approx_eq(@poly.derivative_at(polynomial, 3.0), -4.0), true)
}

///|
test "poly sparse derivative through dual evaluation" {
  let polynomial = @sparse.SparsePolynomial::from_array([
    ([5U], 1.0),
    ([2U], 3.0),
    ([0U], 1.0),
  ])
  let (value, derivative) = @poly.sparse_value_and_derivative_at(
    polynomial, 2.0,
  )
  assert_eq(approx_eq(value, 45.0), true)
  assert_eq(approx_eq(derivative, 92.0), true)
}
