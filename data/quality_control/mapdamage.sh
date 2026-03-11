#!/bin/bash

source /home/kexin_li/miniforge3/etc/profile.d/conda.sh
conda activate bioenv

cd /mnt/data3/kexin_li/Goat/PRJEB40573/bam/

for i in $(cat ../sample.list)
do
	mapDamage -i ./${i}.uniq.bam -r ../../Refseq/GCF_001704415.2/GCF_001704415.2_ARS1.2_genomic.fna -d ./${i}_mapdamage
done