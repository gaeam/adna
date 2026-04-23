#!/bin/bash

# --double-id 是因为有些样本名里有下划线，加入这个参数之后就会直接把完整样本名复制给FID和IID
/home/kexin_li/plink-1.9/plink --vcf Goat.sample232.SNP_auto.vcf.gz \
	--chr-set 29 \
	--allow-no-sex \
	--keep-allele-order \
	--make-bed \
	--double-id \
	--out GGVD_232
