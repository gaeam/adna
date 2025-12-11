#!/bin/bash

# 该脚本用于处理双端测序数据，去接头并转为 bam 格式
# 需要准备 INPUT_LIST 文件：
# SAMEA7368740/ERR4658035
# SAMEA7368740/ERR4659298

# --- 脚本配置与环境设置 ---

# 1. 确保任何命令失败时脚本退出，防止处理不完整的数据
set -e 

# 2. 定义常用的路径变量，提高可读性和易维护性
INPUT_LIST="/home/kexin_li/paired.PRJEB51668.list"
INPUT_DIR="/home/kexin_li/goat/01.ancient.data/Daly.2022.sample_PRJEB51668_checkok"
OUTPUT_DIR="/mnt/data3/kexin_li/Goat/PRJEB51668"
ADAPTER_REMOVAL="/home/kexin_li/adapterremoval-2.3.4/build/AdapterRemoval"
FASTQ2BAM="/public/software/adna/BCL2BAM2FASTQ_1/fastq2bam/fastq2bam"

# 4. 确保输出和QC目录存在
mkdir -p "${OUTPUT_DIR}"

# --- 处理双端测序数据：主循环 ---

echo "Starting processing loop from ${INPUT_LIST}..."

# 使用 while read 替代 for i in $(cat ...)，这是处理文件列表的最佳实践，更安全地处理文件名中的空格或特殊字符
while IFS= read -r sample_id
do
    # 检查是否为空行
    if [ -z "$sample_id" ]; then
        continue
    fi

    echo "--- Processing Sample: ${sample_id} ---"
    
    # 5. 定义循环内的文件路径变量
    R1_IN="${INPUT_DIR}/${sample_id}_1.fastq.gz"
    R2_IN="${INPUT_DIR}/${sample_id}_2.fastq.gz"
    BASE_OUT="${OUTPUT_DIR}/${sample_id}"
    R1_TRUNCATED="${BASE_OUT}.pair1.truncated.gz"
    R2_TRUNCATED="${BASE_OUT}.pair2.truncated.gz"
    BAM_OUT="${BASE_OUT}.bam"

    # 6. 检查输入文件是否存在 (健壮性检查)
    if [[ ! -f "$R1_IN" ]] || [[ ! -f "$R2_IN" ]]; then
        echo "警告: 找不到 FASTQ 文件 ($R1_IN 或 $R2_IN)。跳过 $sample_id。" >&2
        continue
    fi

    ## 任务 1: Adapter & Quality Trimming (AdapterRemoval)
    echo "  1/2. Running AdapterRemoval (Trimming)..."
    "$ADAPTER_REMOVAL" \
        --file1 "$R1_IN" \
        --file2 "$R2_IN" \
        --basename "$BASE_OUT" \
        --trimns \
        --trimqualities \
        --minadapteroverlap 1 \
        --minlength 30 \
        --gzip

    ## 任务 2: Convert FASTQ to BAM (fastq2bam)
    echo "  2/2. Running fastq2bam (Conversion)..."
    "$FASTQ2BAM" \
        -o "$BAM_OUT" \
        "$R1_TRUNCATED" \
        "$R2_TRUNCATED"
    
done < "${INPUT_LIST}"

echo "Processing finished for all samples."    