1. 查看未比对 bam 里 reads 的 flag 信息（单端/双端）
samtools view your.bam | head -20 | awk '{print $1, $2}'
- 如果看到 flag = 4，是单端（collapsed reads）
- 如果看到 flag = 77 和 141 成对出现，是双端（paired reads）

2. 
