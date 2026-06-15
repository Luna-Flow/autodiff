# 生态集成 API

本文档描述 v0.2 中面向 Luna Flow 生态库的桥接包。

## `autodiff/linalg`

`linalg` 包使用 `Luna-Flow/linear-algebra/immut` 的不可变向量和矩阵。

- `gradient(f, x) -> Vector[T]`
- `jacobian(f, x) -> Matrix[T]`
- `value_and_gradient(f, x) -> (T, Vector[T])`
- `value_and_jacobian(f, x) -> (Vector[T], Matrix[T])`

`gradient` 的概念签名：

```text
f : Vector[Dual[T]] -> Dual[T]
x : Vector[T]
```

`jacobian` 的概念签名：

```text
f : Vector[Dual[T]] -> Vector[Dual[T]]
x : Vector[T]
```

Jacobian 使用“输出乘输入”的方向：

```text
J[row = output_index, col = input_index]
```

该包使用 n-pass 前向模式播种。它不要求、也不定义 `Dual[T]` 的域级行为。

## `autodiff/poly`

`poly` 包桥接到 `Luna-Flow/luna-poly`。

dense 单变量辅助函数：

- `eval_dual(p, x_dual) -> Dual[T]`
- `value_and_derivative_at(p, x) -> (T, T)`
- `derivative_at(p, x) -> T`

sparse 单变量使用方式的辅助函数：

- `eval_sparse_dual(p, x_dual) -> Dual[T]`
- `sparse_value_and_derivative_at(p, x) -> (T, T)`
- `sparse_derivative_at(p, x) -> T`

这些函数通过对偶数求值复用 Luna Poly 的现有表示。它们不进行符号微分，也不引入新的多项式表示。
