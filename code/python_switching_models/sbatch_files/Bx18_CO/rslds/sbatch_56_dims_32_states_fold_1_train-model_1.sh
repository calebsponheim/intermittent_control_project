#!/bin/bash
#SBATCH --job-name=56_32_1_1
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/bx18_CO/rSLDS_56_dims_32_states_fold_1_1.out
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/bx18_CO/rSLDS_56_dims_32_states_fold_1_1.err
#SBATCH --time=11:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2021.05
source activate /project/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py 56 1 32 bx18 CO 1
sbatch --dependency=afterany:$SLURM_JOB_ID sbatch_56_dims_32_states_fold_1_train-model_0.sh