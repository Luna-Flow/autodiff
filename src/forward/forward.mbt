///|
pub fn[T : One] value_and_diff(f : (Dual[T]) -> Dual[T], x : T) -> (T, T) {
  let y = f(Dual::variable(x))
  (y.value(), y.tangent())
}

///|
pub fn[T : One] diff(f : (Dual[T]) -> Dual[T], x : T) -> T {
  let (_, derivative) = value_and_diff(f, x)
  derivative
}
