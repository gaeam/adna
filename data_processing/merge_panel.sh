#!/bin/bash

for chr in $(seq 1 29); do
    cat > merge_chr${chr}.sh << EOF
#!/bin/bash

chr=${chr}
A="/mnt/data3/kexin_li/Goat/GGVD/Goat.sample232.SNP_\${chr}.vcf.gz"
B="/mnt/data3/kexin_li/Goat/VarGoats/vargoats_snps_1372_20230313_\${chr}.EVA.vcf.gz"
B_RENAMED="vargoats_renamed_\${chr}.vcf.gz"  # 新增：重命名后的B文件
CHR_MAP="/mnt/data3/kexin_li/Goat/Panel/chr_map.txt"  # 新增：映射文件路径

if [[ ! -f "\$A" ]] || [[ ! -f "\$B" ]]; then
    echo "警告: 染色体 \${chr} 的文件不存在，跳过" >&2
    exit 1
fi

echo "处理染色体 \${chr}..."

# 新增：对B文件重命名染色体
if [[ ! -f "\$B_RENAMED" ]]; then
    bcftools annotate --rename-chrs "\$CHR_MAP" "\$B" -Oz -o "\$B_RENAMED"
    tabix -p vcf "\$B_RENAMED"
fi

if [[ ! -f "merge_\${chr}.vcf.gz" ]]; then
    bcftools merge -m all "\$A" "\$B_RENAMED" -Oz -o merge_\${chr}.vcf.gz  # 修改：B改为B_RENAMED
    tabix -p vcf merge_\${chr}.vcf.gz
fi

if [[ ! -f "isec_\${chr}.txt" ]]; then
    bcftools isec -n=2 -c all "\$A" "\$B_RENAMED" > isec_\${chr}.txt  # 修改：B改为B_RENAMED
fi

bcftools view -T isec_\${chr}.txt merge_\${chr}.vcf.gz -Oz -o isec_\${chr}.vcf.gz
tabix -p vcf isec_\${chr}.vcf.gz

echo "染色体 \${chr} 完成！"
EOF

    chmod +x merge_chr${chr}.sh
    echo "生成脚本: merge_chr${chr}.sh"
done

echo "所有脚本生成完毕，开始提交..."
for chr in $(seq 1 29); do
    nohup bash merge_chr${chr}.sh > merge_chr${chr}.log 2>&1 &
done