# 山羊项目数据处理记录
1. 去接头 + 转换为未比对 bam 文件

单端测序数据：`trim2bam_se.sh`

双端测序数据：`trim2bam_pe.sh`

对于双端测序数据，采取的策略是：使用 `adapterremoval` 软件 `--collapse` 参数会生成：

`collapsed.truncated.gz`：containing merged reads that have been trimmed due to the `--trimns` or `--trimqualities` options

`pair1.truncated.gz`和 `pair2.truncated.gz`：which contain trimmed pairs of reads which were not collapsed

对于 `collapsed.truncated.gz`，当作单端测序数据使用 `fastq2bam` 程序；对于 `pair1.truncated.gz`和 `pair2.truncated.gz`，当作双端测序数据使用 `fastq2bam` 程序

2. 比对到参考基因组、排序、MQ30 过滤（只保留 mapping quality >= 30 的 reads）

经 UDG 处理的古代数据及现代数据：`align_filter_UDG.sh`

未经 UDG 处理的古代数据：`align_filter_noUDG.sh`

对于当作双端测序处理的  `pair1.truncated.gz`和 `pair2.truncated.gz` 的输出文件，需要额外加入过滤条件：只保留正确配对的双端 reads，单端 reads 会被过滤掉（properly paired），因为比对后的 bam 里，双端 reads 中可能出现：（1）两条都比对上了，且方向正确，即 properly paired（flag 包含 2）；（2）只有一条比对上了，不是 properly paired；（3）两条都没比对上，也不是 properly paired

```bash
samtools view -f 2 your.bam
```
