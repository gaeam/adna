#!/bin/bash

source /home/kexin_li/miniforge3/etc/profile.d/conda.sh
conda activate bioenv

/home/kexin_li/EIG-8.0.0/bin/convertf -p par.PED.EIGENSTRAT
