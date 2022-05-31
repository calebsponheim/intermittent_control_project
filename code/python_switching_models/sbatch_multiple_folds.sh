#!/bin/bash
#SBATCH --job-name=rSLDS_1-100
#SBATCH --output=/dali/nicho/caleb/git/intermittent_control_project/code/python_switching_models/rSLDS_1-100.out
#SBATCH --error=/dali/nicho/caleb/git/intermittent_control_project/code/python_switching_models/rSLDS_1-100.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem-per-cpu=4000

module load python

source activate /dali/nicho/caleb/git/intermittent_control_project/code/python_switching_models/ssm_midway_python_environment/

python run_multi_rslds.py
