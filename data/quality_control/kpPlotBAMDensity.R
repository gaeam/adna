# kpPlotBAMDensity plots the read density of a BAM file.
# It does not plot the coverage but the read density as the number of reads overlapping a every window.
# It uses Rsamtools to efficiently access the BAM file.
# The BAM file must be indexed.

# ARS1.txt
# chr start end
# 1 1 157403528
# 2 1 136510947
# ......

library(karyoploteR)
ARS1 <- toGRanges("D:/Downloads/ARS1.txt)
kp <- plotKaryotype(genome = ARS1)
kpPlotBAMDensity(kp, data = "D:/Downloads/NWU/L0139.uniq.mask2.bam", col "navy")
kpAddMainTitle(kp, "L0139.uniq.mask2.bam")
