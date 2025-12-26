# qpAdm
## 一、qpAdm 在“逻辑上”到底在干嘛？
> qpAdm 用一组外群（Right populations），测试目标群体（Target）是否可以表示为若干源群体（Left populations）的线性混合，并估计混合比例。
它解决的是这个问题：
> Target ≈ a₁·Source₁ + a₂·Source₂ + … + aₙ·Sourceₙ
> 在一组外群的约束下，这个等式是否成立？

## 二、qpAdm 的核心数学思想（不看公式也能懂）
### （1）f4 统计量是核心
qpAdm 的所有检验，本质上都建立在 f4 统计量上：
> f4(A, B; C, D)
直观理解：
- 如果 A 和 B 在 C、D 的分化方向上是等价的
- 那么 f4 ≈ 0
### （2）qpAdm 的“约束思想”
假设你有：
- **Left（左边）：**
    - Target
    - Source₁, Source₂, … Sourceₙ
- **Right（右边）：**
    - Outgroup₁, Outgroup₂, … Outgroupₖ
qpAdm 的假设是：
> 如果 Target 真的是这些 Source 的线性混合
> 那么 Target 与每一个 Right 的 f4 关系，都可以由 Source 与 Right 的 f4 关系线性解释
换句话说：
```
f4(Target, X; Right_i, Right_j)
≈
a₁·f4(Source₁, X; Right_i, Right_j)
+ ...
+ aₙ·f4(Sourceₙ, X; Right_i, Right_j)
```
其中 X 是 Left 里的任意参考群体。