#!/bin/bash

# =========================================================
# === PBS Directives (保持不变) ===
# =========================================================
#PBS -l nodes=1:ppn=1      # 1 节点，1 核心 (计算深度对线程要求不高)
#PBS -q low
#PBS -d ./                 # 设置工作目录

# =========================================================
# === 脚本配置与变量定义 ===
# =========================================================

# 该脚本用于通过 samtools depth 计算样本测序深度
# 需要准备 INPUT_LIST 文件：
# SAMEA7368719
# SAMEA7368722

# 1. 健壮性设置：确保任何命令失败时脚本退出
set -e 

# 2. 定义关键变量
INPUT_LIST="../sample.list" # 假设列表文件名为 sample.list 且位于上一级目录
OUTPUT_REPORT="average_depth_report.txt"
BAM_SUFFIX=".uniq.autosomal.softclip.bam"

# 3. 检查输入列表是否存在
if [ ! -f "${INPUT_LIST}" ]; then
    echo "ERROR: Input sample list not found at ${INPUT_LIST}" >&2
    exit 1
fi

echo "Starting average depth calculation. Results will be saved to ${OUTPUT_REPORT}"

# 4. 初始化报告文件（写入表头）
echo -e "Sample_ID\tAverage_Depth" > "${OUTPUT_REPORT}"

# =========================================================
# === 核心循环：计算深度并追加结果 ===
# =========================================================

# 使用 while read 替代 for i in $(cat ...)：这是读取文件列表的最佳实践
while IFS= read -r sample_id
do
    if [ -z "$sample_id" ]; then
        continue # 跳过空行
    fi

    echo "--- Calculating depth for: ${sample_id} ---"
    
    INPUT_BAM="${sample_id}${BAM_SUFFIX}"

    # 检查 BAM 文件是否存在
    if [ ! -f "${INPUT_BAM}" ]; then
        echo "WARNING: BAM file not found for ${sample_id}. Skipping." >&2
        continue
    fi

    # 核心步骤：计算深度并使用 awk 汇总
    # samtools depth -a 确保计算包含 0 覆盖度的所有位点
    # awk 计算平均深度，并打印结果
    DEPTH_RESULT=$(samtools depth -a "${INPUT_BAM}" | awk -v sample="${sample_id}" '{
        sum+=$3
        count++
    } END {
        if (count > 0) {
            print sample "\t" sum/count
        } else {
            print sample "\tNA"
        }
    }')

    # 将结果追加 (>>) 到报告文件
    echo "${DEPTH_RESULT}" >> "${OUTPUT_REPORT}"

done < "${INPUT_LIST}"

echo "Processing complete. Final report: ${OUTPUT_REPORT}"