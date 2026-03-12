# 山羊项目数据处理记录

## pipeline

**1. 去接头 + 转换为未比对 bam 文件**

- 单端测序数据：`trim2bam_se.sh`

- 双端测序数据：`trim2bam_pe.sh`

对于双端测序数据，采取的策略是：使用 `adapterremoval` 软件 `--collapse` 参数

- `collapsed.truncated.gz`：containing merged reads that have been trimmed due to the `--trimns` or `--trimqualities` options，merge 成功，但末端有低质量碱基或 N，经过截断后输出

- `collapsed.gz`：containing merged reads，merge 成功，末端没有需要被 `--trimns` 或 `--trimqualities` 截掉的低质量碱基或 N，直接输出

- `pair1.truncated.gz`和 `pair2.truncated.gz`：which contain trimmed pairs of reads which were not collapsed

```bash
zcat *.collapsed.truncated.gz *.collapsed.gz | gzip > *.collapsed.all.gz
```

对于 `collapsed.truncated.gz` 和 `collapsed.gz`，把它们合并在一起、当作单端测序数据使用 `fastq2bam` 程序；对于 `pair1.truncated.gz`和 `pair2.truncated.gz`，当作双端测序数据使用 `fastq2bam` 程序

**2. 比对到参考基因组 + 排序 + MQ30 过滤（只保留 mapping quality >= 30 的 reads）**

- 经 UDG 处理的古代数据及现代数据：`align_filter_UDG.sh`

- 未经 UDG 处理的古代数据：`align_filter_noUDG.sh`

对于当作双端测序处理的  `pair1.truncated.gz`和 `pair2.truncated.gz` 的输出文件，需要额外加入过滤条件：只保留正确配对的双端 reads，单端 reads 会被过滤掉（properly paired）

```bash
samtools view -f 2 your.bam
```

> 比对后的 bam 里，双端 reads 中可能出现：（1）两条都比对上了，且方向正确，即 properly paired（flag 包含 2）；（2）只有一条比对上了，不是 properly paired；（3）两条都没比对上，也不是 properly paired

**3. 添加 Read Group + 去重**

`addRG_rmdup.sh`

**4. 合并 bam 文件 + 再次去重**

**5. （optional）提取常染色体**

## 问题记录

**(1) mpileup 结果文件格式问题**

```bash
(bioenv) r940xa kexin_li /home/kexin_li/goat/nuclear/ [8] $ samtools mpileup -B -q30 -Q30 -s -O -R -l /mnt/data3/kexin_li/Goat/GGVD/GGVD_232.pos -f /mnt/data3/Genomes/Ovis_Capra_genome_zehui_210817/Capra/whole_genome.fa /home/kexin_li/goat/L3542.goat.bam | pileupCaller --randomHaploid --sampleNames L3542_JRT --samplePopName POP1 -f /mnt/data3/kexin_li/Goat/GGVD/GGVD_232.snp -e L3542
[mpileup] 1 samples in 1 input files
pileupCaller: SeqFormatException "Error while parsing: string. Error occurred when trying to parse this chunk: \"1\\t27450\\tc\\t2\\t..\\t]]\\tFF\\t89,89\\n1\\t27451\\tc\\t2\\t..\\t]]\\tFF\\t90,90\\n1\\t32991\\tc\\t1\\t.\\tZ\\tF\\t41\\n1\\t32999\\tt\\t1\\t.\\tV\\tF"
```

错误原因分析：错误信息 SeqFormatException 说明 pileup 文件的格式不符合预期。从报错内容看，问题出在这段数据最后多了一列：

```plain text
1	27450	c	2	..	]]	FF	89,89
1	27451	c	2	..	]]	FF	90,90
```

标准 pileup 格式是 6列：

```plain text
染色体  位置  参考碱基  覆盖深度  reads碱基  质量值
```

但你的文件有 8列（多了 FF 和 89,89 这两列），这很可能是因为用了多个样本或者 samtools mpileup 加了额外参数（比如 -a 或输出了 mapping quality）
