#!/bin/bash

/home/kexin_li/plink-1.9/plink \
  --bfile /Users/likexin/Desktop/cattle/snp.10k/modern216_ld.ancient121.own5.outgroup2 \
  --extract /Users/likexin/Desktop/cattle/admixture/modern216_ld.ancient121.own5.outgroup2.prune.in \
  --make-bed \
  --chr-set 29 \
  --allow-no-sex \
  --keep-allele-order \
  --out /Users/likexin/Desktop/cattle/admixture/modern216_ld.ancient121.own5.outgroup2.prune

# --extract = 保留 prune.in 文件列出的 SNP
