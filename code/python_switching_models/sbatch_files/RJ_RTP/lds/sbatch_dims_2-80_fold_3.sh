#!/bin/bash
#SBATCH --job-name=f_3
#SBATCH --array=2-80
#SBATCH --output=/project/nicho/projects/caleb/git/intermittent_control_project/code/python_switching_models/out_files/rj_RTP/LDS_%a_3.out
#SBATCH --output=/project/nicho/projects/caleb/git/intermittent_control_project/code/python_switching_models/error_files/rj_RTP/LDS_%a_3.err
#SBATCH --time=10:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2022.05
source activate /project/nicho/projects/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/projects/caleb/git/intermittent_control_project/code/python_switching_models/LDS_param_search.py 3 RTP rj $SLURM_ARRAY_TASK_ID 