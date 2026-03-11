#!/bin/bash
set -euo pipefail

echo "步骤1: 正在合并BAM文件..."
java -jar /home/kexin_li/picard.jar MergeSamFiles \
    $(printf "I=%s " *.capra.mapping.sorted.MQ30.RG.uniq.bam) \
    O=SAMEA7368732.bam

echo "步骤2: 正在标记并移除重复序列..."
java -jar /home/kexin_li/picard.jar MarkDuplicates \
    REMOVE_DUPLICATES=true \
    I=SAMEA7368732.bam \
    O=SAMEA7368732.uniq.bam \
    M=SAMEA7368732.marked.dup.metrics.txt

samtools index SAMEA7368732.uniq.bam

echo "样本 SAMEA7368732 处理完成！"
