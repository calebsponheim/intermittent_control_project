#!/bin/bash
#SBATCH --job-name=4_1
#SBATCH --array=2-80:2
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/rs_RTP/rSLDS_%a_4.out
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/rs_RTP/rSLDS_%a_4.err
#SBATCH --time=36:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2021.05
source activate /project/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py $SLURM_ARRAY_TASK_ID 1 4 rs RTP 0
