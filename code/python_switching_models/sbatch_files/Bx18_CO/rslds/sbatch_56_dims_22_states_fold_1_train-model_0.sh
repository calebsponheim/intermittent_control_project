#!/bin/bash
#SBATCH --job-name=56_22_1_0
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/Bx18_CO/rSLDS_56_dims_22_states_fold_1_0.out
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/Bx18_CO/rSLDS_56_dims_22_states_fold_1_0.err
#SBATCH --time=7:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2021.05
source activate /project/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py 56 1 22 Bx18 CO 0
sbatch --dependency=afterany:$SLURM_JOB_ID sbatch_58_dims_22_states_fold_1_train-model_1.sh