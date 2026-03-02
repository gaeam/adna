#!/bin/bash

bcftools merge

-Oz -o
71yak_highconfidence.2outgroup.nomaf.vcf.gz --threads 30
bcftools index -t 71yak_highconfidence.2outgroup.nomaf.vcf.gz

#!/bin/bash
#PBS -l nodes=1:ppn=5    #ppn=cpu numbers needed for per task
#PBS -q low
#PBS -d .

bcftools merge -m all A.vcf.gz B.vcf.gz -Oz -o merge_AB.vcf.gz

bcftools isec -n=2 -c all A.vcf.gz B.vcf.gz > isec_AB.txt

tabix -p vcf  merge_AB.vcf.gz
bcftools view -T isec_AB.txt merge_AB.vcf.gz -O z -o isec_AB.vcf.gz
