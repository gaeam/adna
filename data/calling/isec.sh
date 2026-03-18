# 提取两个 pos 文件的交集
awk 'NR==FNR{a[$0]=1; next} a[$0]' ../GGVD/GGVD_232.pos VarGoats_1372.pos > common_snps.pos
