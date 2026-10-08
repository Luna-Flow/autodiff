# poly design

This page explains why evaluating a `luna-poly` polynomial on dual numbers
yields its derivative, what the dense and sparse evaluation orders compute,
how accurate the result is, and why the bridge is limited to one variable.

## Design goal

Give `luna-poly` users the value and the derivative of a polynomial at a
point with no new polynomial representation and no symbolic step, by reusing
the evaluation algorithms `luna-poly` already has.

## Constraints

- `luna-poly` owns the polynomial types and their evaluation; the bridge
  may only call their public API.
- Sparse polynomials are multivariate in `luna-poly`, but a variable has no
  identity outside a `VariableContext`.

## Mathematical background

### Evaluation over dual numbers is the derivative

For $p(x) = \sum_{k=0}^{n} c_k x^k$ over a commutative semiring $R$, the
[dual design](dual.md#polynomials-where-derivatives-come-from) shows

$$
p(a + b\varepsilon) = p(a) + p'(a)\,b\,\varepsilon, \qquad
p'(x) = \sum_{k=1}^{n} k\,c_k x^{k-1},
$$

where $k\,c_k$ means $c_k$ added $k$ times. The identity is algebraic, so it
holds exactly for integer polynomials and up to rounding for floating-point
ones; it needs neither limits nor division.

### Horner's rule on dual numbers

`DensePolynomial::eval` computes $r_{n+1} = 0$, $r_k = r_{k+1}\,x + c_k$ for
$k = n, \dots, 0$, and returns $r_0 = p(x)$. With $x = a + b\varepsilon$, the
lifted coefficients $c_k + 0\varepsilon$, and $r_k = p_k + q_k\varepsilon$,
the dual product and sum give

$$
\begin{aligned}
p_k &= p_{k+1}\,a + c_k, \\
q_k &= p_{k+1}\,b + a\,q_{k+1}, \qquad p_{n+1} = q_{n+1} = 0 .
\end{aligned}
$$

For $b = 1$ this is the classical scheme that evaluates a polynomial and its
derivative together.[^knuth] By induction $p_k = \sum_{i \ge k} c_i
a^{i-k}$ and $q_k = b\sum_{i > k} (i - k)\,c_i a^{i-k-1}$, so $p_0 = p(a)$
and $q_0 = p'(a)\,b$.

[^knuth]: D. E. Knuth, *The Art of Computer Programming*, vol. 2, 3rd ed.,
section 4.6.4.

### Sparse terms by powering

`SparsePolynomial::eval` sums $c\,x^e$ over the stored terms and computes
$x^e$ by binary powering. On dual numbers every product applies the product
rule, so $x^e$ becomes $a^e + e\,a^{e-1} b\,\varepsilon$ (the binomial
identity of the dual design), and the sum of the terms gives $p(a) +
p'(a)\,b\,\varepsilon$ again.

## Design decisions

### Evaluate instead of differentiating symbolically

**Problem.** Users need $p'(x)$ at points.

**Options.** Build the derivative polynomial with
`DensePolynomial::derivative` and evaluate it; evaluate $p$ over
`Dual[T]`.

**Choice.** Evaluate over `Dual[T]`. It returns $p(x)$ and $p'(x)$ from one
pass, needs only `Semiring` (the formal derivative in `luna-poly` also needs
`NatHomomorphism` to form $k\,c_k$), does not allocate a second polynomial
per derivative order, and composes with other dual computations through
`eval_dual`. The formal derivative remains the right tool when the
derivative polynomial itself is wanted; the test suite checks that the two
agree.

### Reuse `luna-poly` evaluation

The bridge lifts the coefficients with `Dual::constant`, builds a
`DensePolynomial[Dual[T]]` or `SparsePolynomial[Dual[T]]` with the ordinary
constructors, and calls `eval`. It does not reimplement Horner's rule, so
any change to `luna-poly` evaluation (and its normalization of zero
coefficients, which is why `T : Eq` is required) applies here too.

### One variable for sparse polynomials

**Problem.** `SparsePolynomial` is multivariate, but a partial derivative
needs a choice of variable, and variable identity lives in the contexts of
`luna-poly` (`VariableContext`, `ContextPolynomial`).

**Choice.** The sparse bridge evaluates with the single assignment `[x]` and
is named `sparse_univariate_*`. A polynomial that uses another variable
makes `eval` abort. A multivariate API would have to take a variable
context and return a gradient; it is future work. Callers with a
contextual polynomial can partially evaluate the other variables first, as
the repository's integration test does.

### Compatibility names

The first release named the functions `derivative_at`,
`value_and_derivative_at`, `eval_sparse_dual`, `sparse_derivative_at` and
`sparse_value_and_derivative_at`. The `dense_` and `sparse_univariate_`
names say which representation and which kind of derivative is meant; the
old names stay as plain aliases so existing code keeps working.

## Correctness and invariants

### Exactness in exact rings

For `T` with exact arithmetic (`Int`, `BigInt`, exact rationals) the results
are exactly $p(x)$ and $p'(x)$, by the identities above.

### Rounding error of the dense evaluation

Use $\mathrm{fl}(x \circ y) = (x \circ y)(1 + \delta)$, $|\delta| \le u$, and
the product lemma $\prod (1 + \delta_i)^{\pm1} = 1 + \theta_k$, $|\theta_k|
\le \gamma_k = ku/(1 - ku)$.[^higham]

[^higham]: N. J. Higham, *Accuracy and Stability of Numerical Algorithms*,
2nd ed., SIAM, 2002, Lemma 3.1 and chapter 5.

*Value.* By the [projection homomorphism](dual.md#the-value-projection-is-a-homomorphism)
$\hat p_0$ is the plain Horner result. Each step multiplies the running sum
by $(1 + \delta_{\times})(1 + \delta_{+})$ and adds $c_k$ once rounded, so
$c_k a^k$ carries $2k + 1$ factors for $k < n$; the leading coefficient
carries $2n$, because the first step $0 \cdot a + c_n$ is exact:

$$
\hat p_0 = \sum_{k=0}^{n} c_k a^k (1 + \theta^{(k)}), \quad |\theta^{(k)}| \le \gamma_{2n},
\qquad
|\hat p_0 - p(a)| \le \gamma_{2n} \sum_{k=0}^{n} |c_k|\,|a|^k .
$$

*Derivative ($b = 1$).* The tangent step computes
$\mathrm{fl}\big(\hat p_{k+1} \cdot 1 + \mathrm{fl}(a\,\hat q_{k+1})\big)$,
and adding the constant $c_k$ adds an exact zero to the tangent. The
derivative contains $k$ copies of $c_k a^{k-1}$, one for each step $j < k$
at which $c_k$ moves from the value chain into the tangent chain. Along such
a path $c_k$ is rounded once when it enters, twice per value step $k - 1,
\dots, j + 1$, once when it moves into the tangent, and twice per tangent
step $j - 1, \dots, 0$: $1 + 2(k - 1 - j) + 1 + 2j = 2k$ factors. Hence

$$
|\hat q_0 - p'(a)| \le \gamma_{2n} \sum_{k=1}^{n} k\,|c_k|\,|a|^{k-1} ,
$$

essentially the bound for evaluating the formal derivative by Horner's
rule, which is $\gamma_{2n-2} \sum_k k\,|c_k|\,|a|^{k-1}$ once the
coefficients $k\,c_k$ are formed exactly; the dual evaluation pays at most
two more roundings per term.
The relative error is small unless the terms cancel, that is unless $p'$ is
ill-conditioned at $a$.

### Cost

Dense: $n + 1$ dual multiply-add steps, that is about $3n$ multiplications
and $3n$ additions of `T`, plus one array of $n + 1$ lifted coefficients.
Sparse: per term one binary powering, $O(\log e)$ dual products, plus one
dual product and one addition.

## Alternatives rejected

- **Symbolic derivative then evaluation.** Two passes, an extra polynomial,
  and a stronger bound on `T`; kept as `luna-poly`'s own
  `DensePolynomial::derivative` for users who need the polynomial.
- **A private Horner loop.** Faster by a constant, but it would duplicate
  `luna-poly` semantics and drift from them.
- **Guessing a variable for multivariate sparse polynomials.** Silent
  partial derivatives with respect to "the first variable" would be easy to
  misuse; the bridge aborts instead.

## Boundaries

- Univariate only: no partial derivatives or gradients of multivariate
  polynomials, no `ContextPolynomial` support.
- First derivatives at points only; no derivative polynomials (use
  `luna-poly`), no higher derivatives.
- No checked variants: dense and sparse evaluation do not fail except for
  the sparse abort described above.
- Dense and sparse `immut` representations only.
