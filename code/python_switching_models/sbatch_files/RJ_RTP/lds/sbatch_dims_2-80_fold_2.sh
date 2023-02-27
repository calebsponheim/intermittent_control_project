#!/bin/bash
#SBATCH --job-name=f_2
#SBATCH --array=2-80
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/rj_RTP/LDS_%a_2.out
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/rj_RTP/LDS_%a_2.err
#SBATCH --time=1:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2021.05
source activate /project/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/LDS_param_search.py 2 RTP rj $SLURM_ARRAY_TASK_ID 