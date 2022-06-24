#!/bin/bash
#SBATCH --job-name=CS_rSLDS_%A
#SBATCH --array=2
#SBATCH --output=/dali/nicho/caleb/git/intermittent_control_project/code/python_switching_models/rSLDS__%a.out
#SBATCH --error=/dali/nicho/caleb/git/intermittent_control_project/code/python_switching_models/rSLDS__%a.err
#SBATCH --time=36:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem-per-cpu=6G

echo "My SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID

module load python

source activate /dali/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/

python run_param_search.py $SLURM_ARRAY_TASK_ID