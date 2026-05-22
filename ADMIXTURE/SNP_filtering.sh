#!/bin/bash

/home/kexin_li/plink-1.9/plink \
  --bfile /mnt/data3/kexin_li/Goat/Analysis/PCA/GGVD+ancient/own6.agoat93.abezoar6.GGVD226 \
  --extract own6.agoat93.abezoar6.GGVD226.prune.in \
  --make-bed \
  --chr-set 29 \
  --allow-no-sex \
  --keep-allele-order \
  --out own6.agoat93.abezoar6.GGVD226.pruned

# --extract = 保留 prune.in 文件列出的 SNP
