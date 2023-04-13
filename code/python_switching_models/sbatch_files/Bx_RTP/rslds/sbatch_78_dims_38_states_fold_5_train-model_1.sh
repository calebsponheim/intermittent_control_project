#!/bin/bash
#SBATCH --job-name=78_38_5_1
#SBATCH --output=/project/nicho/projects/caleb/git/intermittent_control_project/code/python_switching_models/out_files/bx_RTP/rSLDS_78_dims_38_states_fold_5_1.out
#SBATCH --output=/project/nicho/projects/caleb/git/intermittent_control_project/code/python_switching_models/error_files/bx_RTP/rSLDS_78_dims_38_states_fold_5_1.err
#SBATCH --time=27:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2022.05
source activate /project/nicho/projects/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/projects/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py 78 5 38 bx RTP 1
sbatch --dependency=afterany:$SLURM_JOB_ID sbatch_78_dims_38_states_fold_5_train-model_0.sh