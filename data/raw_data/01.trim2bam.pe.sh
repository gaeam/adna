#!/bin/bash

# 该脚本用于处理双端测序数据，去接头并转为 bam 格式
# 需要准备 INPUT_LIST 文件：
# ERR4658035
# ERR4659298

# --- 脚本配置与环境设置 ---

# 1. 确保任何命令失败时脚本退出，防止处理不完整的数据
set -e 

# 2. 定义常用的路径变量，提高可读性和易维护性
INPUT_LIST="SAMEA7368732.list"
INPUT_DIR="/home/kexin_li/goat/01.ancient.data/Daly.2021.sample_PRJEB40573_checkok/SAMEA7368732"
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
    COLLAPSE="${run_id}.collapsed.gz"
    COLLAPSE_TRUNCATED="${run_id}.collapsed.truncated.gz"
    COLLAPSE_ALL="${run_id}.collapsed.all.gz"
    PAIR1_TRUNCATED="${run_id}.pair1.truncated.gz"
    PAIR2_TRUNCATED="${run_id}.pair2.truncated.gz"
    BAM_COLLAPSE="${run_id}.collapsed.bam"
    BAM_PAIRED="${run_id}.paired.bam"
    ADAPTER1="AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC"
    ADAPTER2="AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT"

    # 6. 检查输入文件是否存在 (健壮性检查)
    if [[ ! -f "$R1_IN" ]] || [[ ! -f "$R2_IN" ]]; then
        echo "警告: 找不到 FASTQ 文件 ($R1_IN 或 $R2_IN)。跳过 $run_id。" >&2
        continue
    fi

    ## 任务 1: Adapter & Quality Trimming (AdapterRemoval)
    echo "  1/3. Running AdapterRemoval (Trimming)..."
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

    ## 任务 2: 合并 collapsed 文件
    echo "  2/3. Merging collapsed files..."
    zcat "$COLLAPSE" "$COLLAPSE_TRUNCATED" | gzip > "$COLLAPSE_ALL"

    ## 任务 3: Convert FASTQ to BAM (fastq2bam)
    echo "  3/3. Running fastq2bam (Conversion)..."
    "$FASTQ2BAM" \
        -o "$BAM_COLLAPSE" \
        "$COLLAPSE_ALL"
    "$FASTQ2BAM" \
	-o "$BAM_PAIRED" \
	"$PAIR1_TRUNCATED" \
	"$PAIR2_TRUNCATED"
    
done < "${INPUT_LIST}"

echo "Processing finished for SAMEA7368732."
