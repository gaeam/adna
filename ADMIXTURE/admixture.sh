#!/bin/bash
# =========================================================
# === PBS/Queueing Directives (保持不变) ===
# =========================================================
#PBS -l nodes=1:ppn=10      # 请求 1 个节点，使用 10 个核心 (CPU)
#PBS -q low                # 使用 'low' 队列
#PBS -d ./ # 设置工作目录

for i in {1..10}
do
cat > run_K${i}.sh << EOF
#!/bin/bash
# =========================================================
# === PBS/Queueing Directives (保持不变) ===
# =========================================================
#PBS -l nodes=1:ppn=10      # 请求 1 个节点，使用 10 个核心 (CPU)
#PBS -q low                # 使用 'low' 队列
#PBS -d ./ # 设置工作目录
/home/kexin_li/admixture-1.3.0/admixture --cv \
own6.agoat93.abezoar6.GGVD226.pruned.bed ${i} \
| tee K=${i}.log
EOF

chmod +x run_K${i}.sh

# 提交任务
qsub run_K${i}.sh

done
