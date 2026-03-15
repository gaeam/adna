# 查看 reads 数量
samtools view -c <bam file>

# 整理 header
samtools view -H YJL02G.autosomal.bam > header.sam
grep -E '^@HD|^@RG|^@PG|^@SQ.*SN:(1|2|3|4|5|6|7|8|9|1[0-9]|2[0-9])\b' header.sam > cleaned_header.sam
samtools reheader cleaned_header.sam YJL02G.autosomal.bam > YJL02G.autosomal.reheader.bam

# 提取常染色体
samtools view -b SAMBG15.merged.uniq.rescaled.bam 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 > SAMBG15.merged.uniq.rescaled.autosomal.bam

# 从 fasta 参考基因组中提取常染色体
samtools faidx ARS1.fna 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 > ARS1_auto.fna
