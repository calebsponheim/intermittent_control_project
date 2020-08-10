#!/bin/bash
#SBATCH --array=2-30
#SBATCH --job-name=Bx_ll_sbatch_%A
#SBATCH --output=./data_midway/bx_log_likelihood_%A_%a.out
#SBATCH --error=./data_midway/bx_log_likelihood_%A_%a.err
#SBATCH --partition=broadwl
#SBATCH --ntasks=1
#SBATCH --mem=8G

echo "My SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID

module load matlab/2014b
matlab -nodisplay -r "code/midway_train_HMM_log_likelihood data/Bxcenter_out190228CT0.mat SLURM_ARRAY_TASK_ID 5"