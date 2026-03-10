#!/bin/bash

source /home/kexin_li/miniforge3/etc/profile.d/conda.sh
conda activate bioenv

/home/kexin_li/EIG-8.0.0/bin/convertf -p par.PED.EIGENSTRAT

# 这种方式生成的 EIGENSTRAT 文件中的 ind 文件里的群体信息需要自己编辑
