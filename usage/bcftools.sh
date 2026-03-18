## 在服务器上和 bioenv 里有两个版本的 bcftools，bioenv 更新

# 索引（重新索引）
bcftools index --force vargoats_snps_1372_20230313_auto.vcf.gz 

# 染色体重命名
bcftools annotate --rename-chrs chr_map.txt vargoats_snps_1372_20230313_auto.vcf.gz -Oz -o vargoats_chr_renamed.vcf.gz

# 查询个体名
bcftools query -l vcf.gz

# 查询染色体名
bcftools query -f '%CHROM\n' input.vcf.gz | sort -u

# 查询 SNP 数量
bcftools +counts <vcf.gz 文件路径> > <结果 txt 文件路径>
bcftools index -n Goat.sample232.SNP_auto.vcf.gz # 只在有索引文件时生效

# 统计多等位位点的数量
bcftools view --min-alleles 3 vargoats_snps_1372_20230313_29.EVA.vcf.gz | bcftools stats | grep "^SN"
