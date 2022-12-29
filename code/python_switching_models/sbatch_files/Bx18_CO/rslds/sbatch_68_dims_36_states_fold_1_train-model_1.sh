#!/bin/bash
#SBATCH --job-name=68_36_1_1
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/Bx18_CO/rSLDS_68_dims_36_states_fold_1_1.out
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/Bx18_CO/rSLDS_68_dims_36_states_fold_1_1.err
#SBATCH --time=19:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2021.05
source activate /project/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py 68 1 36 Bx18 CO 1
sbatch --dependency=afterany:$SLURM_JOB_ID sbatch_68_dims_36_states_fold_1_train-model_0.sh