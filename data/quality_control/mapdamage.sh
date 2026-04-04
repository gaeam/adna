#!/bin/bash

source /home/kexin_li/miniforge3/etc/profile.d/conda.sh
conda activate bioenv

SAMPLE_LIST="sample.list"

if [[ ! -f "$SAMPLE_LIST" ]]; then
    echo "错误：未找到样本列表文件 $SAMPLE_LIST"
    exit 1
fi

echo "开始统计 sample.list 中每个样本的损伤模式..."

while IFS= read -r sample_name
do
    bam="./${sample_name}/${sample_name}.uniq.bam"

    if [[ ! -f "$bam" ]]; then
        echo "警告: $bam 不存在，跳过"
        continue
    fi

    mapDamage -i "$bam" \
        -r /mnt/data3/Genomes/Goat_kexin_260316/ARS1.fna \
        -d "./${sample_name}/${sample_name}_mapdamage"

done < "$SAMPLE_LIST"
