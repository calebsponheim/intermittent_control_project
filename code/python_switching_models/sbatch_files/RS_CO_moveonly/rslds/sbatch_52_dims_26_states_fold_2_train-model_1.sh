#!/bin/bash
#SBATCH --job-name=52_26_2_1
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/rs_CO/rSLDS_52_dims_26_states_fold_2_1.out
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/rs_CO/rSLDS_52_dims_26_states_fold_2_1.err
#SBATCH --time=7:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2021.05
source activate /project/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py 52 2 26 rs CO 1
sbatch --dependency=afterany:$SLURM_JOB_ID sbatch_52_dims_26_states_fold_2_train-model_0.sh