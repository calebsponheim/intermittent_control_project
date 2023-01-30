#!/bin/bash
#SBATCH --job-name=78_38_3_1
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/rj_RTP/rSLDS_78_dims_38_states_fold_3_1.out
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/rj_RTP/rSLDS_78_dims_38_states_fold_3_1.err
#SBATCH --time=28:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2021.05
source activate /project/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py 78 3 38 rj RTP 1
sbatch --dependency=afterany:$SLURM_JOB_ID sbatch_78_dims_38_states_fold_3_train-model_0.sh