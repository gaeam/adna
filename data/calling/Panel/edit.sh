# 提取两个 pos 文件的交集
awk 'NR==FNR{a[$0]=1; next} a[$0]' ../GGVD/GGVD_232.pos VarGoats_1372.pos > common_snps.pos

# 用 fam 文件重命名 ind 文件的群体名
awk 'NR==FNR{a[NR]=$1; next} {$3=a[FNR]; print}' input.fam input.ind > output.ind
