#!/bin/bash
#SBATCH --job-name=2_38_1_0
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/projects/code/python_switching_models/out_files/bx_RTP/rSLDS_2_dims_38_states_fold_1_0.out
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/projects/code/python_switching_models/error_files/bx_RTP/rSLDS_2_dims_38_states_fold_1_0.err
#SBATCH --time=4:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2021.05
source activate /project/nicho/projects/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/projects/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py 2 1 38 bx RTP 0
sbatch --dependency=afterany:$SLURM_JOB_ID sbatch_6_dims_38_states_fold_1_train-model_1.sh