#!/bin/bash

# 该脚本用于合并相同样本、不同染色体的 PLINK 文件
# 合并之前必须要先修改 bim 文件里 SNP 的名字

/home/kexin_li/plink-1.9/plink \
    --merge-list merge.list \
    --chr-set 29 \
    --allow-no-sex \
    --keep-allele-order \
    --make-bed \
    --out VarGoats_1372_common
