# mapdamage2 结果解读

https://zhuanlan.zhihu.com/p/1909003795842708836

## 结果文件内容

- 3pGtoA_freq.txt：记录 3′ 端不同位置上 G→A 错配的频率（misincorporation），每行一个位置和该位置的 G→A 频率

- 5pCtoT_freq.txt：记录 5′ 端不同位置上 C→T 错配的频率，每行一个位置和该位置的 C→T 频率

- dnacomp.txt：汇总所有 reads 的序列组成统计（A/C/G/T 含量、GC 比例、二核苷酸频率等），用以评估文库质量

- dnacomp_genome.csv：基于参考基因组做的序列组成对比，同样包含单碱基及二核苷酸频率，用于和 dnacomp.txt 中的 reads 组成比较

- Fragmisincorporation_plot.pdf：“fragmentation & misincorporation” 组合图，左侧展示不同片段长度下的碱基错配频率，右侧展示片段长度分布

- Length_plot.pdf：仅展示测序片段（DNA fragment）长度分布的直方图/箱线图

- lgdistribution.txt：列出了每个 fragment 长度及其在数据中出现的绝对和相对频数

- misincorporation.txt：包含所有参考碱基（A/C/G/T）在 5′/3′ 端的每个位置上各种错配类型（C→T、G→A 及其它）的详细频数和频率

- Runtime_log.txt：mapDamage 执行过程中的命令行日志，记录各阶段开始/结束时间、所用参数和可能的警告信息

- Stats_out_MCMC_correct_prob.csv：MCMC 后验校正的碱基质量调整概率矩阵，显示在不同位置和模型假设下“矫正”碱基质量的概率

- Stats_out_MCMC_hist.pdf：MCMC 采样过程中各参数（如脱氨速率、overhang 概率等）的后验分布直方图，用于评估收敛和参数分布

- Stats_out_MCMC_iter.csv：MCMC 每次迭代采样得到的参数值记录，行是迭代步数，列是各个参数

- Stats_out_MCMC_iter_summ_stat.csv：对 Stats_out_MCMC_iter.csv 中参数采样结果的汇总统计（均值、中位数、95% 置信区间等）

- Stats_out_MCMC_post_pred.pdf：基于 MCMC 参数后验分布进行的“后验预测检验”（posterior predictive check）图，用于验证模型对观测数据的拟合程度

- Stats_out_MCMC_trace.pdf：MCMC 采样轨迹图（trace plot），显示每个参数随迭代次数的变化，便于检查链条收敛情况

## 实操

较为重要的输出文件：

**1. Fragmisincorporation_plot.pdf 片段错误插入率图**

https://pica.zhimg.com/v2-84549e9db830ecdcaae2cff478816cd2_r.jpg

Red: C to T substitutions.Blue: G to A substitutions.Grey: All other substitutions.Orange: Soft-clipped bases.Green: Deletions relative to the reference.Purple: Insertions relative to the reference.

每个参考碱基（A、C、G、T）都有两个小图，左边显示 5′ 端（负值为“端外背景”，正值“端内损伤”），右边显示 3′ 端（负值为“端内损伤”，正值为端外背景”）；纵轴是“在该位置测到错误替换的频率（在某个位置上，参考碱基被测序为非参考碱基的比例）”（比如 C→T 的比例），点是平均值，竖线是置信区间

本数据为双端测序merge后进行的mapDamage分析，合并后的那一条“merged read”其实覆盖了原始 DNA 片段的整个双链区段，它的两端分别对应了原始片段在两条互补链上的 5′ 端，这两端都会发生典型的胞嘧啶脱氨（C→T）损伤

- C 面板（绿色）：在 5′ 端第一个碱基（位置 1）有明显的 C→T 峰（频率可达 ~0.3，即所有以C为参考的第一个碱基上，有30%的观察是T）。同样在 3′ 端第一个碱基（位置 -1）也有一个小峰。这正是 aDNA 胞嘧啶脱氨造成 C→U→T 的典型损伤信号，集中在片段末端

- G 面板（黑色）：反映互补链上 C→T 损伤在参考 G 位置上的表现，即参考 G 被读成 A（G→A）。峰值通常不如 C→T 那么高，但仍明显高于片段中间位置

即使在 A 或 T 面板里看到较高的错配率（例如 ~30%），那通常是“所有非 C→T/G→A 错配的平均背景水平”，并不是“某种实际的脱氨损伤”

=只看 C 和 G 图：这是 aDNA 损伤的标志=

=忽略 A 和 T 图中的高值：它们只是测序或比对的通用噪音，不代表链特异的化学损伤=

2. Length_plot.pdf 片段长度分布图（双端测序结果不生成此图）

3. misincorporation.txt 错配信息表

4. dnacomp.txt DNA片段的碱基组成
