#!/bin/bash

# =========================================================
# === PBS Directives (保持不变) ===
# =========================================================
#PBS -l nodes=1:ppn=4      # 1 节点，4 核心 (计算深度对线程要求不高)
#PBS -q low
#PBS -d ./                 # 设置工作目录

# =========================================================
# === 脚本配置与变量定义 ===
# =========================================================

# 该脚本用于执行 EIGENSOFT 的 smartpca.projection 功能
# 需要准备 par 文件： smartpca.projection.par

#PBS -l nodes=1:ppn=4 
#PBS -q low 
#PBS -d ./ 

/EIG-8.0.0/src/eigensrc/smartpca -p smartpca.projection.par > smartpca.log 