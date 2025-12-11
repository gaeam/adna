#!/bin/bash

# 该脚本用于去除高连锁 SNP，生成 prune.in 和 prune.out 文件
./plink --bfile /Users/likexin/Desktop/cattle/snp.10k/modern216_ld.ancient121.own5.outgroup2 \
    --indep-pairwise 50 5 0.5 \
    --chr-set 29 \
    --allow-no-sex \
    --keep-allele-order \
    --out /Users/likexin/Desktop/cattle/admixture/modern216_ld.ancient121.own5.outgroup2