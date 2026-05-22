# ADMIXTURE

> 一般不加入外群

1. LD pruning（去除高连锁 SNP）：LD_pruning.sh

- r^2 阈值：越大越宽松，例如 0.2 代表只允许低相关性，稍微相关就会被剪掉；0.5 允许更高相关性，保留的 SNP 更多

2. 根据 prune.in 文件筛选 SNP：SNP_filtering.sh
   
3. 运行 ADMIXTURE
   
4. 评估 K 值
- CV error 越小，说明 K 值对数据的解释越好

5. 可视化
