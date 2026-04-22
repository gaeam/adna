## 在服务器上和 bioenv 里有两个版本的 bcftools，bioenv 的版本更新
source /home/kexin_li/miniforge3/etc/profile.d/conda.sh
conda activate bioenv

# 查看 vcf 文件过滤条件/处理步骤
bcftools view -h vargoats_renamed_29.vcf.gz | less

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

# 把两个VCF文件按样本合并（横向合并，样本不同位点相同）
bcftools merge -m all A.vcf.gz B.vcf.gz -Oz -o merge.vcf.gz # -m all：全部合并，允许合并多等位基因

# 提取两个VCF文件的交集位点
bcftools isec -n=2 -c all A.vcf.gz B.vcf.gz > isec.txt # -n=2：只输出在2个文件中都出现的位点；-c all：合并所有等位基因类型来比较

# 从合并后的VCF中提取交集位点
bcftools view -T isec.txt merge.vcf.gz -Oz -o isec.vcf.gz
