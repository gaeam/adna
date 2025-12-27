#!/usr/bin/env python3

import argparse  # 导入argparse模块，用于解析命令行参数
from multiprocessing import Pool  # 导入多进程Pool模块
from itertools import combinations  # 导入itertools模块的combinations函数，用于组合操作
import os  # 导入os模块，用于文件和操作系统交互
import sys  # 导入sys模块，用于系统参数
import random  # 导入random模块，用于生成随机数

# 创建一个命令行参数解析器
parser = argparse.ArgumentParser(description="Automatically run qpAdm in two- and three- way admixture model using a source population panel.")
parser.add_argument("target", help="Target population")  # 定义target参数，用以指定目标群体
parser.add_argument("source", help="Panel of source populations")  # 定义source参数，用以指定源群体面板
parser.add_argument("outgroup", help="Path of outgroup list")  # 定义outgroup参数，用以指定外群列表路径
parser.add_argument("--num", help="The number of admixture model (2, 3 or 4 way ..). Default run 2 way model at most.", type=int, default=2)  # 定义num参数，指定混合模型的数量，默认为2
parser.add_argument("--name", default="", help="Prefix of files")  # 定义name参数，用以指定文件的前缀
parser.add_argument("--jobs", default=1, help="Number of jobs in one run", type=int)  # 定义jobs参数，用以指定一次运行中的任务数量
args = parser.parse_args()  # 解析命令行参数

tg = args.target
source = args.source
out = args.outgroup
name = args.name
num = args.num
jobs = args.jobs

# 读取源群体面板文件，过滤空行和注释行，并排除目标群体自身
with open(source) as f: 
    source_list = [i.strip() for i in f if i.strip()!='' and i[0]!="#" and i.strip()!=tg]

# 读取外群列表文件，过滤空行和注释行
with open(out) as f:
    out_list = [i.strip() for i in f if i.strip()!='' and i[0]!="#"]

job_list = []  # 初始化job列表，用于存储任务

# 定义运行qpAdm的函数
def run(par, log):
    os.system("qpAdm -p {} > {}".format(par, log))  # 通过系统命令执行qpAdm并将输出重定向到日志文件
    return(0)

# 定义生成.par文件的函数
def make_par(tg, source_list, n, out):
    for i in combinations(source_list, n):  # 为源群体创建不同组合
        right = [i for i in out]
        for j in source_list:
            if not j in i:
                right.append(j)  # 添加不在当前左群体组合中的余下源群体到右群体

        # 定义文件名
        left_name = "{}{}_{}.left".format(name, tg, ''.join(i))
        right_name = "{}{}_{}.right".format(name, tg, ''.join(i))
        par_name = "{}{}_{}.par".format(name, tg, ''.join(i))
        log_name = "{}{}_{}.log".format(name, tg, ''.join(i))

        # 写入左群体文件
        with open(left_name, 'w') as f:
            f.write("{}\n".format(tg))
            f.write("\n".join(i))

        # 写入右群体文件
        with open(right_name, 'w') as f:
            f.write("\n".join(right))

        # 写入参数文件
        with open(par_name, 'w') as f:
            f.write('''
genotypename: /home/kexin_li/cattle/D-statistics/251215/modern201_ap114_aoc5_aoy6_waterbufllo2.pileupCaller.geno
snpname: /home/kexin_li/cattle/D-statistics/251215/modern201_ap114_aoc5_aoy6_waterbufllo2.pileupCaller.snp
indivname: /home/kexin_li/cattle/D-statistics/251215/modern201_ap114_aoc5_aoy6_waterbufllo2.pileupCaller.ind
popleft: {}
popright: {}
details: YES
allsnps: YES'''.format(left_name, right_name))
        job_list.append([par_name, log_name])  # 将生成的任务添加到任务列表中
    return(0)

# 根据指定的混合模型数量创建参数文件
if num == 2:
    if num > len(source_list):
        num = len(source_list)
    for n in range(1, num+1):
        make_par(tg, source_list, n, out_list)
else:
    make_par(tg, source_list, num, out_list)

# 创建命令列表用于执行任务
cmds = ["qpAdm -p {} > {}".format(j[0], j[1]) for j in job_list]

# 计算每批次任务的数量和余数
x = len(cmds) // jobs
y = len(cmds) % jobs
wd = os.getcwd()  # 获取当前工作目录

# 为每个批次任务创建Shell脚本
for i in range(0, x+1):
    fn = "{}_qpadm_{}{}_{}.sh".format(tg, random.randint(1, 99), random.randint(1,99), name)
    if i*jobs+y != len(cmds):
        bash_cmd = "\n".join(cmds[i*jobs:(i+1)*jobs])
    else:
        # 处理不能整除的情况
        if y != 0:
            bash_cmd = "\n".join(cmds[i*jobs:])
        else:
            bash_cmd = ''
    with open(fn, 'w') as f:
        f.write('''
#!/bin/bash
#PBS -l nodes=1:ppn=1   #ppn=cpu numbers needed for per task
#PBS -q low
#PBS -d .        

cd {}
{}
'''.format(wd, bash_cmd))
    os.system("qsub {}".format(fn))  # 提交任务到PBS作业调度系统
print("Finish all.")
sys.exit(0)  # 脚本执行结束

