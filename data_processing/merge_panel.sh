#!/bin/bash

bcftools merge

-Oz -o
71yak_highconfidence.2outgroup.nomaf.vcf.gz --threads 30
bcftools index -t 71yak_highconfidence.2outgroup.nomaf.vcf.gz
