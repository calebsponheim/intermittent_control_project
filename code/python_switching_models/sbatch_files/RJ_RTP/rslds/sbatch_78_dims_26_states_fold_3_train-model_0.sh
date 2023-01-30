#!/bin/bash
#SBATCH --job-name=78_26_3_0
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/rj_RTP/rSLDS_78_dims_26_states_fold_3_0.out
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/rj_RTP/rSLDS_78_dims_26_states_fold_3_0.err
#SBATCH --time=16:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2021.05
source activate /project/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py 78 3 26 rj RTP 0
sbatch --dependency=afterany:$SLURM_JOB_ID sbatch_82_dims_26_states_fold_3_train-model_1.sh