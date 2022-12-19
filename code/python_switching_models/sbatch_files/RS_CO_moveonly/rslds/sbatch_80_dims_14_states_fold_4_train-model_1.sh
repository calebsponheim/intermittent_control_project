#!/bin/bash
#SBATCH --job-name=80_14_4_1
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/rs_CO/rSLDS_80_dims_14_states_fold_4_1.out
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/rs_CO/rSLDS_80_dims_14_states_fold_4_1.err
#SBATCH --time=9:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2021.05
source activate /project/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py 80 4 14 rs CO 1
sbatch --dependency=afterany:$SLURM_JOB_ID sbatch_80_dims_14_states_fold_4_train-model_0.sh