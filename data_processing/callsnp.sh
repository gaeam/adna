#!/bin/bash

samtools mpileup -B -q30 -Q20 -s -O -l <panel.bed> -R -f <ref.fa> <input.bam> \
| pileupCaller --randomHaploid \

--sampleNameFile low_sample.list --samplePopName POP1 -f <panel.snp> -e <PREFIX.pileupCaller>
--sampleNames NAME1,NAME2
