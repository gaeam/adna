#!/bin/bash

# 该脚本用于处理单端测序数据，去接头并转为 bam 格式
# 需要准备 INPUT_LIST 文件：
# SAMEA7368740/ERR4658035
# SAMEA7368740/ERR4659298

# --- 脚本配置与环境设置 ---

# 1. 确保任何命令失败时脚本退出，防止处理不完整的数据
set -e 

# 2. 定义常用的路径变量，提高可读性和易维护性
CONDA_BASE_DIR="/home/kexin_li/miniforge3"
CONDA_ENV="bioenv"
INPUT_LIST="/home/kexin_li/single.PRJEB51668.list"
INPUT_DIR="/home/kexin_li/goat/01.ancient.data/Daly.2022.sample_PRJEB51668_checkok"
OUTPUT_DIR="/mnt/data3/kexin_li/Goat/PRJEB51668"
FASTQ2BAM="/public/software/adna/BCL2BAM2FASTQ_1/fastq2bam/fastq2bam"
FASTQC_DIR="${OUTPUT_DIR}/fastqc_reports" # 建议将fastqc报告单独存放在一个子目录

# 3. 激活 Conda 环境
echo "Activating Conda environment: ${CONDA_ENV}"
source "${CONDA_BASE_DIR}/etc/profile.d/conda.sh"
conda activate "${CONDA_ENV}"

# 4. 确保输出和QC目录存在
mkdir -p "${OUTPUT_DIR}"
mkdir -p "${FASTQC_DIR}"

# --- 处理单端测序数据：主循环 ---

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
    INPUT_FASTQ="${INPUT_DIR}/${sample_id}.fastq.gz"
    TRIMMED_FASTQ="${OUTPUT_DIR}/${sample_id}.truncated.fastq.gz"
    OUTPUT_BAM="${OUTPUT_DIR}/${sample_id}.bam"

    # 6. 检查输入文件是否存在 (健壮性检查)
    if [ ! -f "${INPUT_FASTQ}" ]; then
        echo "ERROR: Input FASTQ not found at ${INPUT_FASTQ}. Skipping this sample." >&2
        continue
    fi

    ## 任务 1: Adapter & Quality Trimming (cutadapt)
    echo "  1/3. Running cutadapt (Trimming)..."
    cutadapt \
        -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC \
        -O 1 -m 30 "${INPUT_FASTQ}" \
        -q 2,2 --trim-n \
        -o "${TRIMMED_FASTQ}"

    ## 任务 2: Convert FASTQ to BAM (fastq2bam)
    echo "  2/3. Running fastq2bam (Conversion)..."
    "${FASTQ2BAM}" -o "${OUTPUT_BAM}" "${TRIMMED_FASTQ}"

    ## 任务 3: Quality Control (fastqc)
    # 对处理后的 FASTQ 文件运行 QC
    echo "  3/3. Running fastqc..."
    fastqc -o "${FASTQC_DIR}" "${TRIMMED_FASTQ}"
    
done < "${INPUT_LIST}"

echo "Processing finished for all samples."