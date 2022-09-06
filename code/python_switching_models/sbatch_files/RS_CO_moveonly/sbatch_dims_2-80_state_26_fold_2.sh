#!/bin/bash
#SBATCH --job-name=26_2
#SBATCH --array=2-80:5
#SBATCH --output=/dali/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/rs_CO/rSLDS_%a_26.out
#SBATCH --output=/dali/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/rs_CO/rSLDS_%a_26.err
#SBATCH --time=36:00:00
#SBATCH --partition=broadwl
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=48G
module load python/anaconda-2021.05
source activate /dali/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /dali/nicho/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py $SLURM_ARRAY_TASK_ID 2 26 rs CO