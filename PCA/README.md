# smartpca

> PCA 结果只能讲古代个体间的关系，不能讨论古代个体和现代个体的关系（因为古代样本的位置是投影上去的），但在 (Han等,2025) 文章中对数据解释时进行了古代群体与现代群体关系的描述

## pipline

**1. 准备 smartpca.par 文件**

- 需要投影：`smartpca.ancient.par`

- 不需要投影（如 panel）：`smartpca.panel.par`

**2. 运行 smartpca**

`smartpca.sh`

**3. 可视化**

（1）准备输入文件：

- `group_styles.csv`

- `evec.txt`：通过 `log2txt.sh` 将分析结果转化为 txt 文件

- `eval`：smartpca 程序直接生成

（2）绘图：

`plot_pca.r`
