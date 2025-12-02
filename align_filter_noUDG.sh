#!/bin/bash

# =========================================================
# === PBS/Queueing Directives (保持不变) ===
# =========================================================
#PBS -l nodes=1:ppn=10      # 请求 1 个节点，使用 10 个核心 (CPU)
#PBS -q low                # 使用 'low' 队列
#PBS -d /mnt/data3/kexin_li/Goat/PRJEB26011/ # 设置工作目录

# =========================================================
# === 脚本配置与变量定义 ===
# =========================================================

# 该脚本用于处理经 UDG 处理或现代数据，与参考基因组比对、过滤
# 需要准备 INPUT_LIST 文件：
# SAMEA7368740/ERR4658035
# SAMEA7368740/ERR4659298

# 1. 健壮性设置：确保任何命令失败时脚本退出
set -e 

# 2. 定义关键路径和参数变量
THREADS=10
REF_FASTA="../Refseq/GCF_001704415.2/GCF_001704415.2_ARS1.2_genomic.fna"
INPUT_LIST="./single.PRJEB26011.noUDG.list"

# 3. 检查输入文件列表是否存在
if [ ! -f "${INPUT_LIST}" ]; then
    echo "ERROR: Input list file not found at ${INPUT_LIST}" >&2
    exit 1
fi

echo "Starting Alignment and Filtering with ${THREADS} threads..."

# =========================================================
# === 主循环：对齐、排序和质量过滤 ===
# =========================================================

# 使用 while read 替代 for i in $(cat ...)，这是处理文件列表的最佳实践
while IFS= read -r sample_id
do
    if [ -z "$sample_id" ]; then
        continue # 跳过空行
    fi

    echo "--- Processing Sample: ${sample_id} ---"
    
    # 定义中间和最终文件路径 (使用变量更清晰)
    INPUT_BAM="./${sample_id}.bam"
    SORTED_BAM="./${sample_id}.ARS1.2.mapping.sorted.bam" # 中间文件
    FINAL_BAM="./${sample_id}.ARS1.2.mapping.sorted.MQ30.bam"

    # 1. BWA 对齐和 Samtools 排序
    # bwa bam2bam 输出流式 BAM 到 samtools sort
    echo "  1/3. Aligning and Sorting..."
    bwa bam2bam -t "${THREADS}" -g "${REF_FASTA}" -n 0.01 -l 16500 -o 2 "${INPUT_BAM}" \
    | samtools sort -o "${SORTED_BAM}" -

    # 2. Samtools 过滤 Mapping Quality (MQ >= 30)
    echo "  2/3. Filtering by Mapping Quality (MQ>=30)..."
    samtools view -h -b -q 30 "${SORTED_BAM}" -o "${FINAL_BAM}"

    # 3. 生成索引
    echo "  3/3. Generating index for final BAM..."
    samtools index "${FINAL_BAM}"

done < "${INPUT_LIST}"

echo "All samples finished processing."