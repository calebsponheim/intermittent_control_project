#!/bin/bash
#SBATCH --job-name=46_6_5_1
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/bx_RTP/rSLDS_46_dims_6_states_fold_5_1.out
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/bx_RTP/rSLDS_46_dims_6_states_fold_5_1.err
#SBATCH --time=2:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2021.05
source activate /project/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py 46 5 6 bx RTP 1
sbatch --dependency=afterany:$SLURM_JOB_ID sbatch_46_dims_6_states_fold_5_train-model_0.sh