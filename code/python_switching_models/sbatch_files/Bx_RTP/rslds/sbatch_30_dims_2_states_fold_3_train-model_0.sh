#!/bin/bash
#SBATCH --job-name=30_2_3_0
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/bx_RTP/rSLDS_30_dims_2_states_fold_3_0.out
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/bx_RTP/rSLDS_30_dims_2_states_fold_3_0.err
#SBATCH --time=1:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2021.05
source activate /project/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py 30 3 2 bx RTP 0
sbatch --dependency=afterany:$SLURM_JOB_ID sbatch_34_dims_2_states_fold_3_train-model_1.sh