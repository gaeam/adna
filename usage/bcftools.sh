# 索引（重新索引）
bcftools index --force vargoats_snps_1372_20230313_auto.vcf.gz 

# 染色体重命名
bcftools annotate --rename-chrs chr_map.txt vargoats_snps_1372_20230313_auto.vcf.gz -Oz -o vargoats_chr_renamed.vcf.gz

# 查询个体名
bcftools query -l vcf.gz

# 查询 SNP 数量
bcftools +counts <vcf.gz 文件路径> > <结果 txt 文件路径>
bcftools index -n Goat.sample232.SNP_auto.vcf.gz # 只在有索引文件时生效
