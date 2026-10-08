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
fn contextual_to_univariate_sparse(
  polynomial : @ctx.ContextPolynomial[Double],
  active_variable : Int,
) -> @sparse.SparsePolynomial[Double] {
  @sparse.SparsePolynomial::from_array(
    polynomial
    .to_terms()
    .map(fn(term) {
      let exponents = term.0.to_array()
      let active_exponent = if active_variable < exponents.length() {
        exponents[active_variable]
      } else {
        0U
      }
      ([active_exponent], term.1)
    }),
  )
}

///|
test "linalg value_and_gradient handles simple scalar function" {
  let x = @la.Vector::from_array([2.0, 3.0])
  let (value, gradient) = @linalg.value_and_gradient(
    fn(v : @la.Vector[@autodiff.Dual[Double]]) { v[0] * v[0] + v[0] * v[1] },
    x,
  )
  let expected_gradient = @la.Vector::from_array([7.0, 2.0])
  assert_eq(approx_eq(value, 10.0), true)
  assert_eq(approx_vec_eq(gradient, expected_gradient), true)
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
test "linalg value_and_jacobian returns primal output and output by input jacobian" {
  let x = @la.Vector::from_array([2.0, 3.0])
  let (value, jacobian) = @linalg.value_and_jacobian(
    fn(v : @la.Vector[@autodiff.Dual[Double]]) {
      @la.Vector::from_array([v[0] + v[1], v[0] * v[1], v[0] * v[0]])
    },
    x,
  )
  let expected_value = @la.Vector::from_array([5.0, 6.0, 4.0])
  let expected_jacobian = @la.Matrix::from_2d_array([
    [1.0, 1.0],
    [3.0, 2.0],
    [4.0, 0.0],
  ])
  assert_eq(approx_vec_eq(value, expected_value), true)
  assert_eq(approx_matrix_eq(jacobian, expected_jacobian), true)
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
test "poly dense eval_dual scales tangent by input tangent" {
  let polynomial = @dense.DensePolynomial::from_coefficients([
    1.0, 2.0, 0.0, 1.0,
  ])
  let result = @poly.eval_dual(polynomial, @autodiff.Dual::new(3.0, 4.0))
  assert_eq(approx_eq(result.value(), 34.0), true)
  assert_eq(approx_eq(result.tangent(), 116.0), true)
}

///|
test "poly dense constant derivative is zero" {
  let polynomial = @dense.DensePolynomial::from_coefficients([5.0])
  let (value, derivative) = @poly.dense_value_and_derivative_at(polynomial, 3.0)
  assert_eq(approx_eq(value, 5.0), true)
  assert_eq(approx_eq(derivative, 0.0), true)
}

///|
test "poly dense linear derivative is slope" {
  let polynomial = @dense.DensePolynomial::from_coefficients([-7.0, 4.0])
  let (value, derivative) = @poly.value_and_derivative_at(polynomial, 10.0)
  assert_eq(approx_eq(value, 33.0), true)
  assert_eq(approx_eq(derivative, 4.0), true)
}

///|
test "poly dense helper matches formal derivative polynomial" {
  let polynomial = @dense.DensePolynomial::from_coefficients([
    5.0, -1.0, 0.0, 3.0,
  ])
  let x = 2.0
  let derivative = @poly.dense_derivative_at(polynomial, x)
  let formal = polynomial.derivative().eval(x)
  assert_eq(approx_eq(derivative, formal), true)
}

///|
test "poly dense substitute preserves dual composition semantics" {
  let outer = @dense.DensePolynomial::from_coefficients([1.0, 1.0, 1.0])
  let inner = @dense.DensePolynomial::from_coefficients([2.0, 0.0, 1.0])
  let rewritten = outer.substitute(inner)
  let x = @autodiff.Dual::new(3.0, 2.0)
  let rewritten_result = @poly.eval_dual(rewritten, x)
  let nested_result = @poly.eval_dual(outer, @poly.eval_dual(inner, x))
  assert_eq(approx_eq(rewritten_result.value(), nested_result.value()), true)
  assert_eq(
    approx_eq(rewritten_result.tangent(), nested_result.tangent()),
    true,
  )
}

///|
test "poly sparse univariate missing-degree derivative through dual evaluation" {
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

///|
test "poly sparse univariate constant derivative is zero" {
  let polynomial = @sparse.SparsePolynomial::from_array([([0U], 9.0)])
  let (value, derivative) = @poly.sparse_univariate_value_and_derivative_at(
    polynomial, 5.0,
  )
  assert_eq(approx_eq(value, 9.0), true)
  assert_eq(approx_eq(derivative, 0.0), true)
}

///|
test "poly sparse univariate linear derivative is slope" {
  let polynomial = @sparse.SparsePolynomial::from_array([
    ([1U], -2.0),
    ([0U], 4.0),
  ])
  let (value, derivative) = @poly.sparse_value_and_derivative_at(
    polynomial, 3.0,
  )
  assert_eq(approx_eq(value, -2.0), true)
  assert_eq(approx_eq(derivative, -2.0), true)
}

///|
test "poly sparse compatibility aliases agree" {
  let polynomial = @sparse.SparsePolynomial::from_array([
    ([3U], 2.0),
    ([1U], -1.0),
    ([0U], 4.0),
  ])
  let x = 2.0
  let old_value = @poly.sparse_value_and_derivative_at(polynomial, x)
  let new_value = @poly.sparse_univariate_value_and_derivative_at(polynomial, x)
  let old_derivative = @poly.sparse_derivative_at(polynomial, x)
  let new_derivative = @poly.sparse_univariate_derivative_at(polynomial, x)
  assert_eq(approx_eq(old_value.0, new_value.0), true)
  assert_eq(approx_eq(old_value.1, new_value.1), true)
  assert_eq(approx_eq(old_derivative, new_derivative), true)
}

///|
test "poly sparse bridge works after contextual partial evaluation" {
  let context = @poly_core.VariableContext::from_names(["x", "y"])
  let x = context.require_variable("x")
  let y = context.require_variable("y")
  let polynomial = @ctx.ContextPolynomial::from_named_terms_as_sparse(context, [
    ([(x, 1U), (y, 1U)], 3.0),
    ([(y, 2U)], 1.0),
    ([], 4.0),
  ])
  let partial = polynomial.eval_partial([(x, 2.0)])
  let univariate = contextual_to_univariate_sparse(partial, 1)
  let (value, derivative) = @poly.sparse_univariate_value_and_derivative_at(
    univariate, 5.0,
  )
  assert_eq(approx_eq(value, 59.0), true)
  assert_eq(approx_eq(derivative, 16.0), true)
}
