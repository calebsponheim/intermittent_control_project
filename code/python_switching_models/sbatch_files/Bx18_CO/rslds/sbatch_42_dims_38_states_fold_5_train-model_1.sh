#!/bin/bash
#SBATCH --job-name=42_38_5_1
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/bx18_CO/rSLDS_42_dims_38_states_fold_5_1.out
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/bx18_CO/rSLDS_42_dims_38_states_fold_5_1.err
#SBATCH --time=11:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2021.05
source activate /project/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py 42 5 38 bx18 CO 1
sbatch --dependency=afterany:$SLURM_JOB_ID sbatch_42_dims_38_states_fold_5_train-model_0.sh