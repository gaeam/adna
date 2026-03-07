#!/bin/bash

awk '{print$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12}' OFS='\t' yak413.vcf.prune.evec | sed 's/:/\t/g' > yak413.vcf.prune.evec.txt