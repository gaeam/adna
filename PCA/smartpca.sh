#!/bin/bash

source /home/kexin_li/miniforge3/etc/profile.d/conda.sh
conda activate bioenv

export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH

/home/kexin_li/EIG-8.0.0/bin/smartpca -p smartpca.par > smartpca.log
