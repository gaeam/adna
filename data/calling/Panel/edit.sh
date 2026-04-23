# 提取两个 pos 文件的交集
awk 'NR==FNR{a[$0]=1; next} a[$0]' ../GGVD/GGVD_232.pos VarGoats_1372.pos > common_snps.pos

# 用 fam 文件重命名 ind 文件的群体名
awk 'NR==FNR{a[NR]=$1; next} {$3=a[FNR]; print}' input.fam input.ind > output.ind

# 重命名 bim 文件中的位点
awk 'BEGIN{OFS="\t"} {$2=$1"_"$4; print}' GGVD_232.bim > GGVD_232.new.bim
mv GGVD_232.new.bim GGVD_232.bim

# 提取 pos 文件
awk '{print $1"\t"$4}' input.bim > input.pos
