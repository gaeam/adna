#!/bin/bash

# 将 pos 文件整理为 pileupCaller 需要的格式（0-based）
# pos 文件是从 bcftools isec 的结果 txt 文件中提取的
# If you use a positions-file, it should either contain positions (0-based) or a bed file (see samtools manual for details). 
awk '{print $1"\t"$2-1"\t"$2}' isec_auto.pos > panel.bed

# 准备待 call snp 的样本序号与样本名的映射文件 bam_indiv.map
# /path/A.bam  SampleA
# /path/B.bam  SampleB

awk '{print $1}' bam_indiv.map > bam.list
awk '{print $2}' bam_indiv.map > indiv.list

# random calling
samtools mpileup -B -q30 -Q30 -s -O -R -l /mnt/data3/kexin_li/Goat/Panel/panel.bed \
    -f /mnt/data3/Genomes/Ovis_Capra_genome_zehui_210817/Capra/bwa-0.5.10 \
    -b bam.list | \
pileupCaller --randomHaploid --sampleNameFile indiv.list \
    --samplePopName POP1 -f /mnt/data3/kexin_li/Goat/Panel/isec_auto.snp \
    -e own6.a103
