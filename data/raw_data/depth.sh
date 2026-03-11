#!/bin/bash

SAMPLE_LIST="sample.list"

if [[ ! -f "$SAMPLE_LIST" ]]; then
    echo "错误：未找到样本列表文件 $SAMPLE_LIST"
    exit 1
fi

echo "开始计算 sample.list 中每个样本的 depth..."

while IFS= read -r sample_name
do
    bam="./${sample_name}/${sample_name}.uniq.bam"

    if [[ ! -f "$bam" ]]; then
        echo "警告: $bam 不存在，跳过"
        continue
    fi

    /home/kexin_li/PanDepth-2.26/pandepth \
        -t 4 \
        -i "$bam" \
        -o "./${sample_name}/${sample_name}"

done < "$SAMPLE_LIST"
