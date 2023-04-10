#!/bin/bash
#SBATCH --job-name=78_26_4_1
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/projects/code/python_switching_models/out_files/bx_RTP/rSLDS_78_dims_26_states_fold_4_1.out
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/projects/code/python_switching_models/error_files/bx_RTP/rSLDS_78_dims_26_states_fold_4_1.err
#SBATCH --time=15:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2021.05
source activate /project/nicho/projects/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/projects/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py 78 4 26 bx RTP 1
sbatch --dependency=afterany:$SLURM_JOB_ID sbatch_78_dims_26_states_fold_4_train-model_0.sh