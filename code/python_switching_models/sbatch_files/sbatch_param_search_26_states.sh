#!/bin/bash
#SBATCH --job-name=CS_rSLDS_%A
#SBATCH --array=2-80
#SBATCH --output=/dali/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/rSLDS_%a.out
#SBATCH --error=/dali/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/rSLDS_%a.err
#SBATCH --time=36:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=64G

echo "My SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID
echo "My SLURM_ARRAY_JOB_ID: " $SLURM_ARRAY_JOB_ID

module load python/anaconda-2021.05

source activate /dali/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/

python run_param_search.py $SLURM_ARRAY_TASK_ID 26