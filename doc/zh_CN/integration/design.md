# 生态集成设计

## 依赖方向

集成包位于核心 autodiff 层之上：

```text
autodiff/core       -> luna-generic only
autodiff/dual       -> luna-generic, arithmetic
autodiff/elementary -> arithmetic
autodiff/checked    -> arithmetic
autodiff/forward    -> core/dual/elementary
autodiff/linalg     -> autodiff + linear-algebra
autodiff/poly       -> autodiff + luna-poly
```

低层包不导入 `linear-algebra`、`luna-poly`、`floating` 或 `type_theory`。

## 线性代数

当 `T` 满足相应 Luna Flow 代数 trait 时，`Dual[T]` 可作为环层级向量和矩阵操作的合法标量。集成层有意避开需要 `Field`、总除法、逆元或总序的算法。

gradient 和 Jacobian 使用 n-pass 前向模式播种。该方案简单、正确，并保持 API 小。向量值 tangent 存储是未来工作。

## 多项式求值

多项式桥接复用 `luna-poly` 数据结构。它把系数提升为 `Dual[T]` 常量，通过现有 Luna Poly 求值算法执行，再把 tangent 读作该点导数。

这是对求值算法做自动微分，不是符号微分。
