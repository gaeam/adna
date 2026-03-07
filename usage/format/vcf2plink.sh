#!/bin/bash

/home/kexin_li/plink-1.9/plink --vcf Goat.sample232.SNP_auto.vcf.gz \
	--chr-set 29 \
	--allow-no-sex \
	--keep-allele-order \
	--make-bed \
	--out GGVD_232