#!/bin/bash

/home/kexin_li/plink-1.9/plink --vcf Goat.sample232.SNP_auto.vcf.gz \
	--chr-set 29 \
	--allow-no-sex \
	--keep-allele-order \
	--make-bed \
	--out GGVD_232

# 重命名 bim 文件中的位点
awk '{print $1"\t"$1"_"$4"\t"$3"\t"$4"\t"$5"\t"$6}' isec_auto.bim > isec_auto.new.bim
mv isec_auto.new.bim isec_auto.bim

# 提取 pos 文件
awk '{print $1"\t"$4}' input.bim > input.pos
