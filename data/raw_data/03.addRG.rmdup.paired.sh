#!/bin/bash
set -euo pipefail

# 定义文件路径变量
INPUT_LIST=SAMEA7368732.list

# 主循环：添加READ GROUP并去重
while IFS= read -r run_id
do
    if [ -z "$run_id" ]; then
        continue # 跳过空行
    fi

    echo "--- Processing SAMEA7368732: ${run_id} ---"
    echo "步骤1: 正在添加READ GROUP..."
    
    # 定义中间和最终文件路径
    INPUT_BAM="${run_id}.paired.capra.mapping.sorted.MQ30.bam"
    RG_BAM="${run_id}.paired.capra.mapping.sorted.MQ30.RG.bam"
    FINAL_BAM="${run_id}.paired.capra.mapping.sorted.MQ30.RG.uniq.bam"
    METRICS_FILE="${run_id}.paired.capra.marked.dup.metrics.txt"

    # 健壮性检查：确保输入文件存在
    if [ ! -f "$INPUT_BAM" ]; then
        echo "警告: 找不到输入文件 ($INPUT_BAM)。跳过 ${run_id}。" >&2
        continue
    fi

    java -jar /home/kexin_li/picard.jar AddOrReplaceReadGroups \
        I="$INPUT_BAM" \
        O="$RG_BAM" \
        RGID="${run_id}_paired" \
        RGLB="${run_id}_paired" \
        RGPL="ILLUMINA" \
        RGPU="${run_id}" \
        RGSM="SAMEA7368732"

    echo "步骤2: 正在标记并移除重复序列..."
    java -jar /home/kexin_li/picard.jar MarkDuplicates \
        REMOVE_DUPLICATES=true \
        I="$RG_BAM" \
        O="$FINAL_BAM" \
        M="$METRICS_FILE"

    samtools index "$FINAL_BAM"

echo "样本 ${run_id} 处理完成！"
done < "$INPUT_LIST"
