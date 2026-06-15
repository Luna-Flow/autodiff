///|
fn[T : One + Zero] seed_vector(x : Vector[T], active : Int) -> Vector[Dual[T]] {
  Vector::makei(x.length(), fn(i) {
    if i == active {
      Dual::new(x[i], T::one())
    } else {
      Dual::constant(x[i])
    }
  })
}

///|
fn[T : Zero] constant_vector(x : Vector[T]) -> Vector[Dual[T]] {
  x.map(fn(value) { Dual::constant(value) })
}

///|
pub fn[T : One + Zero] gradient(
  f : (Vector[Dual[T]]) -> Dual[T],
  x : Vector[T],
) -> Vector[T] {
  Vector::makei(x.length(), fn(i) { f(seed_vector(x, i)).tangent() })
}

///|
pub fn[T : One + Zero] value_and_gradient(
  f : (Vector[Dual[T]]) -> Dual[T],
  x : Vector[T],
) -> (T, Vector[T]) {
  let value = f(constant_vector(x)).value()
  (value, gradient(f, x))
}

///|
/// Returns the output-by-input Jacobian, with
/// `J[row = output_index, col = input_index]`.
pub fn[T : One + Zero] jacobian(
  f : (Vector[Dual[T]]) -> Vector[Dual[T]],
  x : Vector[T],
) -> Matrix[T] {
  let base = f(constant_vector(x))
  let rows = base.length()
  let cols = x.length()
  let columns = Array::make(cols, base)
  for col in 0..<cols {
    columns[col] = f(seed_vector(x, col))
  }
  Matrix::make(rows, cols, fn(row, col) { columns[col][row].tangent() })
}

///|
/// Returns the primal output together with the output-by-input Jacobian.
pub fn[T : One + Zero] value_and_jacobian(
  f : (Vector[Dual[T]]) -> Vector[Dual[T]],
  x : Vector[T],
) -> (Vector[T], Matrix[T]) {
  let value = f(constant_vector(x)).map(fn(y) { y.value() })
  (value, jacobian(f, x))
}
