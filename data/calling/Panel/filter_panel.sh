#!/bin/bash

source /home/kexin_li/miniforge3/etc/profile.d/conda.sh
conda activate bioenv

for chr in {1..29}
do

# 移除 indel 附近 3bp 的 SNP
	bcftools filter \
		--threads 4 \
		-g 3 vargoats_renamed_${chr}.vcf.gz \
		-O z -o vargoats_renamed_${chr}_snpgap3.vcf.gz
	bcftools index -t vargoats_renamed_${chr}_snpgap3.vcf.gz

# 保留 SNP + 保留只有 1 个 ALT allele 的位点（biallelic） + 保留缺失率 <= 10% 的位点
bcftools view \
	-i 'TYPE = "snp" && N_ALT = 1 && F_MISSING <= 0.1' \
	vargoats_renamed_${chr}.vcf.gz \
	-O z -o vargoats_renamed_${chr}_snpgap3_biallelic_missing0.1.vcf.gz

# 保留 MAF >= 0.01 的位点
bcftools view \
  -i 'MAF>=0.01' \
  vargoats_renamed_${chr}_snpgap3_biallelic_missing0.1.vcf.gz \
  -O z -o vargoats_renamed_${chr}_snpgap3_biallelic_missing0.1_maf0.01.vcf.gz
done

