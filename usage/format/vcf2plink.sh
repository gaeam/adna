#!/bin/bash

# --double-id 是因为有些样本名里有下划线，加入这个参数之后就会直接把完整样本名复制给FID和IID
/home/kexin_li/plink-1.9/plink --vcf Goat.sample232.SNP_auto.vcf.gz \
	--chr-set 29 \
	--allow-no-sex \
	--keep-allele-order \
	--make-bed \
	--double-id \
	--out GGVD_232

# 重命名 bim 文件中的位点
awk 'BEGIN{OFS="\t"} {$2=$1"_"$4; print}' GGVD_232.bim > GGVD_232.new.bim
mv GGVD_232.new.bim GGVD_232.bim

# 提取 pos 文件
awk '{print $1"\t"$4}' input.bim > input.pos
