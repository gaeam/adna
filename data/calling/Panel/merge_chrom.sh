#!/bin/bash

# 该脚本用于合并相同样本、不同染色体的 PLINK 文件

/home/kexin_li/plink-1.9/plink \
    --merge-list merge.list \
    --chr-set 29 \
    --allow-no-sex \
    --keep-allele-order \
    --make-bed \
    --out VarGoats_1372_common
