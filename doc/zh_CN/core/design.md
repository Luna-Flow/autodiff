# 设计说明

autodiff v0.2 在保持核心层小而明确的同时，加入生态集成包。核心仍只提供基于对偶数的前向模式自动微分，不提供符号代数、反向模式或优化器 API。

## 包所有权

`Dual[T]` 由 `dual` 包拥有，这样 MoonBit 方法和 trait 实现可以与类型放在同一个包中。`core`、`checked`、`elementary`、`forward` 和根包保持为轻量 facade。

`linalg` 和 `poly` 是集成层。它们依赖被桥接的外部 Luna Flow 库，但低层 autodiff 包不依赖这些集成层。

## 代数约束

对偶数是环式标量，但不是域。`0 + 1ε` 是非零幂零元，因此没有乘法逆元。所以 `Dual[T]` 不应实现 `Field`、`MulGroup` 或 `Inverse`。

对偶数也没有自然总序，因此本包不实现 `Compare`。

## Checked 语义

checked 操作复用 `Luna-Flow/arithmetic` 的 `ArithmeticContext`、`ArithmeticError`、`DivChecked` 和 `SqrtChecked`。

## 非 v0.2 范围

- `Forward[T]` 的向量值 tangent 存储
- 高阶 `Jet[T]`
- 区间或 ball 标量上的 validated AD
- 反向模式自动微分
- 基于 CAS 层的符号微分
