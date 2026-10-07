# poly tutorial

`autodiff/poly` differentiates a polynomial at a point by evaluating it over
`Dual[T]`.

```moonbit
let p = @dense.DensePolynomial::from_coefficients([1.0, 2.0, 1.0])
let (value, derivative) = @poly.value_and_derivative_at(p, 3.0)
```

For `p(x) = x² + 2x + 1`, the value is `16` and the derivative is `8`.

## Next steps

The [poly API](../api/poly.md) lists the dense and sparse helpers, including
the sparse univariate variants.
