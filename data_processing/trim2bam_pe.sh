#!/bin/bash

# 该脚本用于处理双端测序数据，去接头并转为 bam 格式
# 需要准备 INPUT_LIST 文件：
# ERR4658035
# ERR4659298

# --- 脚本配置与环境设置 ---

# 1. 确保任何命令失败时脚本退出，防止处理不完整的数据
set -e 

# 2. 定义常用的路径变量，提高可读性和易维护性
INPUT_LIST="SAMEA7368733.list"
INPUT_DIR="/home/kexin_li/goat/01.ancient.data/Daly.2021.sample_PRJEB40573_checkok/SAMEA7368733"
ADAPTER_REMOVAL="/home/kexin_li/adapterremoval-2.3.4/build/AdapterRemoval"
FASTQ2BAM="/public/software/adna/BCL2BAM2FASTQ_1/fastq2bam/fastq2bam"

# --- 处理双端测序数据：主循环 ---

echo "Starting processing loop from ${INPUT_LIST}..."

# 使用 while read 替代 for i in $(cat ...)，这是处理文件列表的最佳实践，更安全地处理文件名中的空格或特殊字符
while IFS= read -r run_id
do
    # 检查是否为空行
    if [ -z "$run_id" ]; then
        continue
    fi

    echo "--- Processing Sample: ${run_id} ---"
    
    # 5. 定义循环内的文件路径变量
    R1_IN="${INPUT_DIR}/${run_id}_1.fastq.gz"
    R2_IN="${INPUT_DIR}/${run_id}_2.fastq.gz"
    COLLAPSE_TRUNCATED="${run_id}.collapsed.truncated.gz"
    BAM_OUT="${run_id}.bam"
    ADAPTER1="AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC"
    ADAPTER2="AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT"

    # 6. 检查输入文件是否存在 (健壮性检查)
    if [[ ! -f "$R1_IN" ]] || [[ ! -f "$R2_IN" ]]; then
        echo "警告: 找不到 FASTQ 文件 ($R1_IN 或 $R2_IN)。跳过 $run_id。" >&2
        continue
    fi

    ## 任务 1: Adapter & Quality Trimming (AdapterRemoval)
    echo "  1/2. Running AdapterRemoval (Trimming)..."
    "$ADAPTER_REMOVAL" \
        --file1 "$R1_IN" \
        --file2 "$R2_IN" \
        --basename "${run_id}" \
        --adapter1 "$ADAPTER1" \
        --adapter2 "$ADAPTER2" \
        --trimns \
        --trimqualities \
        --minadapteroverlap 1 \
        --minlength 30 \
        --gzip \
        --collapse

    ## 任务 2: Convert FASTQ to BAM (fastq2bam)
    echo "  2/2. Running fastq2bam (Conversion)..."
    "$FASTQ2BAM" \
        -o "$BAM_OUT" \
        "$COLLAPSE_TRUNCATED" \
    
done < "${INPUT_LIST}"

echo "Processing finished for SAMEA7368733."    