#!/bin/bash

# 该脚本用于处理单端测序数据，去接头并转为 bam 格式
# 需要准备 INPUT_LIST 文件：
# SAMEA7368740/ERR4658035
# SAMEA7368740/ERR4659298

# --- 脚本配置与环境设置 ---

# 1. 确保任何命令失败时脚本退出，防止处理不完整的数据
set -e

# 2. 定义常用的路径变量，提高可读性和易维护性
BASE_DIR="/mnt/data3/kexin_li/Goat/PRJEB40573"
PICARD_JAR="/home/kexin_li/picard.jar" # <-- 请根据您的环境修改此路径
INPUT_LIST="${BASE_DIR}/PRJEB40573.list"

# 切换到工作目录
echo "Changing directory to ${BASE_DIR}..."
cd "${BASE_DIR}"

# --- 处理主循环 ---

echo "Starting BAM post-processing loop from ${INPUT_LIST}..."

# 使用 while IFS=/ read -r 是处理以 '/' 分隔的文件的最佳实践
while IFS=/ read -r sample_id run_id
do
    # 检查是否为空行或注释行
    if [[ -z "$sample_id" || "$sample_id" =~ ^# ]]; then
        continue
    fi

    echo "--- Processing Sample: ${sample_id} (Run: ${run_id}) ---"
    
    # 3. 定义循环内的文件路径变量
    INPUT_BAM="./${sample_id}/${run_id}.ARS1.2.mapping.sorted.MQ30.bam"
    RG_BAM="./${sample_id}/${run_id}.ARS1.2.mapping.sorted.MQ30.RG.bam"
    UNIQUE_BAM="./${sample_id}/${run_id}.ARS1.2.mapping.sorted.MQ30.RG.uniq.bam"
    METRICS_FILE="./${sample_id}/${run_id}.ARS1.2.marked.dup.metrics.txt"

    # 4. 健壮性检查：确保输入文件存在
    if [ ! -f "$INPUT_BAM" ]; then
        echo "警告: 找不到输入文件 ($INPUT_BAM)。跳过 ${sample_id}/${run_id}。" >&2
        continue
    fi

    ## 任务 1: Add Read Group (添加 Read Group)
    echo "  1/2. Running Picard AddOrReplaceReadGroups..."
    # 使用 Java 内存参数 (可选，但推荐对于大型文件)
	# RGID: Read Group ID，通常是测序 run 的唯一标识
	# RGLB: Library，测序文库名称
	# RGPL: Platform，测序平台
	# RGPU: Platform Unit，测序单位 (Flowcell/Lane)
	# RGSM: Sample，样本名称 (重要：用于后续多样本分析)
    java -Xmx4G -jar "$PICARD_JAR" AddOrReplaceReadGroups \
        I="$INPUT_BAM" \
        O="$RG_BAM" \
        RGID="${run_id}" \
        RGLB="${run_id}" \
        RGPL="ILLUMINA" \
        RGPU="${run_id}" \
        RGSM="${sample_id}"
	
    ## 任务 2: Mark Duplicates (去除重复序列)
    echo "  2/2. Running Picard MarkDuplicates (Removing duplicates)..."
	# REMOVE_DUPLICATES=true 直接移除重复序列，而不是只标记
    java -Xmx4G -jar "$PICARD_JAR" MarkDuplicates \
        I="$RG_BAM" \
        O="$UNIQUE_BAM" \
        M="$METRICS_FILE" \
        REMOVE_DUPLICATES=true

done < "$INPUT_LIST"

echo "Processing finished for all samples."
