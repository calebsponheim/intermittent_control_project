#!/bin/bash
#SBATCH --job-name=32_5
#SBATCH --array=2-80:5
#SBATCH --output=/dali/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/rs_CO/rSLDS_%a_32.out
#SBATCH --output=/dali/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/rs_CO/rSLDS_%a_32.err
#SBATCH --time=36:00:00
#SBATCH --partition=broadwl
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=48G
module load python/anaconda-2021.05
source activate /dali/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /dali/nicho/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py $SLURM_ARRAY_TASK_ID 5 32 rs CO