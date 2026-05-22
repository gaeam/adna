#!/bin/bash

# 该脚本用于去除高连锁 SNP，生成 prune.in 和 prune.out 文件
./plink --bfile /Users/likexin/Desktop/cattle/snp.10k/modern216_ld.ancient121.own5.outgroup2 \
    --indep-pairwise 50 5 0.5 \
    --chr-set 29 \
    --allow-no-sex \
    --keep-allele-order \
    --out /Users/likexin/Desktop/cattle/admixture/modern216_ld.ancient121.own5.outgroup2

# --indep-pairwise 50 5 0.5 = 滑动窗口 50 SNP，每次移动 5 SNP，如果 2 个 SNP 的 r^2 > 0.5，就剔除其中 1 个
# --allow-no-sex = 忽略 sex 列
# --keep-allele-order = 保持等位基因顺序不翻转
# prune.in = 保留下来的独立 SNP 列表
# prune.out = 被剔除的 SNP 列表
