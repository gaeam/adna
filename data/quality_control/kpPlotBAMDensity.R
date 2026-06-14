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

# window.size defaults to 1e6, 1Mb
# 只有 plotKaryotype 和 kpPlotBAMDensity 需要保存（也就是复制给一个参数），kpAddMainTitle 和 kpAxis 是绘图函数，不需要保存
kp_L0139 <- kpPlotBAMDensity(kp, data = "D:/Downloads/NWU/L0139.uniq.mask2.bam", col "navy", normalize = TRUE, window.size = 5e5) 
kpAddMainTitle(kp_L0139, "L0139.uniq.mask2.bam")

# 给 reads density 图添加纵坐标轴
# maxD = kp_L0139$latest.plot$computed.values$max.density
# kpAxis(kp_L0139, ymin = 0, ymax = maxD*1.2, cex = 0.6)

# 如果有一个图层画错了，只能关闭设备重新绘图
# dev.off()
