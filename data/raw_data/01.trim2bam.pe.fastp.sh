#!/bin/bash

# =========================================================
# === PBS/Queueing Directives (保持不变) ===
# =========================================================
#PBS -l nodes=1:ppn=10      # 请求 1 个节点，使用 10 个核心 (CPU)
#PBS -q low                # 使用 'low' 队列
#PBS -d ./ # 设置工作目录


# 该脚本用于处理双端测序数据，去接头并转为 bam 格式
# 需要准备 INPUT_LIST 文件：
# ERR4658035
# ERR4659298

# --- 脚本配置与环境设置 ---

# 1. 确保任何命令失败时脚本退出，防止处理不完整的数据
set -e 

# 2. 定义常用的路径变量，提高可读性和易维护性
INPUT_LIST="SAMN10615267.list"
INPUT_DIR="/home/kexin_li/goat/01.ancient.data/Cai.2020.sample_PRJNA510797_checkok/SAMN10615267"
FASTP="/home/kexin_li/fastp"
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
    R1_CLEAN="${run_id}_1.clean.gz"
    R2_CLEAN="${run_id}_2.clean.gz"
    BAM="${run_id}.bam"

    # 6. 检查输入文件是否存在 (健壮性检查)
    if [[ ! -f "$R1_IN" ]] || [[ ! -f "$R2_IN" ]]; then
        echo "警告: 找不到 FASTQ 文件 ($R1_IN 或 $R2_IN)。跳过 $run_id。" >&2
        continue
    fi

    ## 任务 1: Adapter & Quality Trimming (fastp)
    echo "  1/2. Running fastp (Trimming)..."
    "$FASTP" \
        -i "$R1_IN" \
        -I "$R2_IN" \
        -o "$R1_CLEAN" \
        -O "$R2_CLEAN"

    ## 任务 2: Convert FASTQ to BAM (fastq2bam)
    echo "  2/2. Running fastq2bam (Conversion)..."
    "$FASTQ2BAM" \
	-o "$BAM" \
	"$R1_CLEAN" \
	"$R2_CLEAN"
    
done < "${INPUT_LIST}"

echo "Processing finished for SAMN10615267."
