#!/bin/bash

/home/kexin_li/plink-1.9/plink \
    --bfile VarGoats_1372 \
    --chr-set 29 \
    --allow-no-sex \
    --keep-allele-order \
    --export vcf bgz \
    --out VarGoats_1372

tabix -p vcf VarGoats_1372.vcf.gz
