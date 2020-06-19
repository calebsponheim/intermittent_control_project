#!/bin/bash
#SBATCH --array=2
#SBATCH --job-name=Bx_ll_sbatch_%A
#SBATCH --output=bx_log_likelihood_%a.out
#SBATCH --error=bx_log_likelihood_%a.err
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks=6
#SBATCH --mem=16000

module load matlab/2014b
matlab -nodisplay -r "code/midway_train_HMM_log_likelihood data/Bxcenter_out190228CT0.mat %a 5"