#!/bin/bash

# 直接运行 --bmerge 后如果碰到下面的报错，需要先运行 flip，再重新合并（少的话就直接删了吧）
# Error: 7188 variants with 3+ alleles present.
# * If you believe this is due to strand inconsistency, try --flip with
#  GGVD_232_VarGoats_1372_common-merge.missnp.
#  (Warning: if the subsequent merge seems to work, strand errors involving SNPs
#  with A/T or C/G alleles probably remain in your data.  If LD between nearby
#  SNPs is high, --flip-scan should detect them.)
# * If you are dealing with genuine multiallelic variants, we recommend exporting
#  that subset of the data to VCF (via e.g. '--recode vcf'), merging with
#  another tool/script, and then importing the result; PLINK is not yet suited
#  to handling them.

# flip
/home/kexin_li/plink-1.9/plink \
    --bfile VarGoats_1372_common \
    --flip GGVD_232_VarGoats_1372_common-merge.missnp \
    --chr-set 29 \
    --allow-no-sex \
    --keep-allele-order \
    --make-bed \
    --out VarGoats_1372_common_flip

# bmerge
/home/kexin_li/plink-1.9/plink \
    --bfile GGVD_232_common \
    --bmerge VarGoats_1372_common_flip.bed VarGoats_1372_common_flip.bim VarGoats_1372_common_flip.fam \
    --chr-set 29 \
    --allow-no-sex \
    --keep-allele-order \
    --make-bed \
    --out GGVD_232_VarGoats_1372_common
