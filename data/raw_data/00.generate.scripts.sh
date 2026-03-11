#!/bin/bash

SAMPLE_LIST="sample.list"

if [[ ! -f "$SAMPLE_LIST" ]]; then
    echo "错误：未找到样本列表文件 $SAMPLE_LIST"
    exit 1
fi

echo "开始为 sample.list 中的每个样本生成处理脚本..."

while IFS= read -r sample_name || [[ -n "$sample_name" ]]; do
    [[ -z "$sample_name" ]] && continue
    [[ "$sample_name" =~ ^#.* ]] && continue

    if [[ -d "./$sample_name" ]]; then
        SCRIPT_PATH="./$sample_name/merge.${sample_name}.sh"

        cat > "$SCRIPT_PATH" << 'EOF'
#!/bin/bash
set -euo pipefail

echo "步骤1: 正在合并BAM文件..."
java -jar /home/kexin_li/picard.jar MergeSamFiles \
    $(printf "I=%s " *.capra.mapping.sorted.MQ30.RG.uniq.bam) \
    O=SAMPLE.bam

echo "步骤2: 正在标记并移除重复序列..."
java -jar /home/kexin_li/picard.jar MarkDuplicates \
    REMOVE_DUPLICATES=true \
    I=SAMPLE.bam \
    O=SAMPLE.uniq.bam \
    M=SAMPLE.marked.dup.metrics.txt

samtools index SAMPLE.uniq.bam

echo "样本 SAMPLE 处理完成！"
EOF

        # 用 sed 替换 SAMPLE 占位符
        sed -i "s/SAMPLE/${sample_name}/g" "$SCRIPT_PATH"

        chmod +x "$SCRIPT_PATH"

	# 提交脚本
        cd "./$sample_name"
        nohup bash "merge.${sample_name}.sh" > "merge.${sample_name}.log" 2>&1 &
        cd ..

        echo "已生成并提交脚本： $SCRIPT_PATH"
    else
        echo "警告：样本目录 '$sample_name' 不存在，已跳过。"
    fi
done < "$SAMPLE_LIST"

echo "所有脚本生成完毕！"
