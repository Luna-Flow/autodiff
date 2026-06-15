///|
/// Creates a dual vector whose `active` coordinate has tangent one and all
/// other coordinates have tangent zero.
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
/// Embeds a primal vector as constants with zero tangents.
fn[T : Zero] constant_vector(x : Vector[T]) -> Vector[Dual[T]] {
  x.map(fn(value) { Dual::constant(value) })
}

///|
/// Computes the gradient of a scalar function by n-pass forward-mode seeding.
///
/// Each input coordinate is seeded with tangent one in a separate pass, and the
/// corresponding output tangent is collected as one gradient component.
/// The function is expected to accept vectors with the same length as `x`.
/// TODO: add checked variants if linear-algebra exposes a shared shape-error API.
pub fn[T : One + Zero] gradient(
  f : (Vector[Dual[T]]) -> Dual[T],
  x : Vector[T],
) -> Vector[T] {
  Vector::makei(x.length(), fn(i) { f(seed_vector(x, i)).tangent() })
}

///|
/// Computes the primal scalar value and gradient of `f` at `x`.
///
/// The value is obtained by evaluating `f` with all tangents set to zero; the
/// gradient is obtained by n-pass forward-mode seeding.
pub fn[T : One + Zero] value_and_gradient(
  f : (Vector[Dual[T]]) -> Dual[T],
  x : Vector[T],
) -> (T, Vector[T]) {
  let value = f(constant_vector(x)).value()
  (value, gradient(f, x))
}

///|
/// Computes the output-by-input Jacobian by n-pass forward-mode seeding.
///
/// For each input coordinate, `f` is evaluated with that coordinate seeded as
/// the active direction. The output tangents fill one Jacobian column.
/// The Jacobian convention is
/// `J[row = output_index, col = input_index]`.
/// The function is expected to return vectors with a stable output length.
/// TODO: add checked variants if linear-algebra exposes a shared shape-error API.
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
/// Computes the primal vector output together with the output-by-input Jacobian.
///
/// The primal output is evaluated with zero tangents, and the Jacobian is
/// computed with the same n-pass seeding as `jacobian`.
pub fn[T : One + Zero] value_and_jacobian(
  f : (Vector[Dual[T]]) -> Vector[Dual[T]],
  x : Vector[T],
) -> (Vector[T], Matrix[T]) {
  let value = f(constant_vector(x)).map(fn(y) { y.value() })
  (value, jacobian(f, x))
}
