# 设计说明

Luna Autodiff v0.1 有意保持小而明确。它只提供基于对偶数的前向模式自动微分，不提供符号代数、反向模式或优化器 API。

## 包所有权

`Dual[T]` 由 `dual` 包拥有，这样 MoonBit 方法和 trait 实现可以与类型放在同一个包中。`core`、`checked`、`elementary`、`forward` 和根包保持为轻量 facade。

## 代数约束

对偶数是环式标量，但不是域。`0 + 1ε` 是非零幂零元，因此没有乘法逆元。所以 `Dual[T]` 不应实现 `Field`、`MulGroup` 或 `Inverse`。

对偶数也没有自然总序，因此本包不实现 `Compare`。

## Checked 语义

checked 操作复用 `Luna-Flow/arithmetic` 的 `ArithmeticContext`、`ArithmeticError`、`DivChecked` 和 `SqrtChecked`。

## 非 v0.1 范围

- 向量值 tangent 的前向模式
- 基于线性代数类型的 gradient 和 Jacobian
- 高阶 `Jet[T]`
- 多项式桥接
- 区间或 ball 标量上的 validated AD
- 反向模式自动微分
