#!/bin/bash
#SBATCH --job-name=22_34_1_1
#SBATCH --output=/project/nicho/projects/caleb/git/intermittent_control_project/code/python_switching_models/out_files/bx_RTP/rSLDS_22_dims_34_states_fold_1_1.out
#SBATCH --output=/project/nicho/projects/caleb/git/intermittent_control_project/code/python_switching_models/error_files/bx_RTP/rSLDS_22_dims_34_states_fold_1_1.err
#SBATCH --time=4:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2022.05
source activate /project/nicho/projects/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/projects/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py 22 1 34 bx RTP 1
sbatch --dependency=afterany:$SLURM_JOB_ID sbatch_22_dims_34_states_fold_1_train-model_0.sh