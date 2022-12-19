#!/bin/bash
#SBATCH --job-name=64_16_3_0
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/rs_CO/rSLDS_64_dims_16_states_fold_3_0.out
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/rs_CO/rSLDS_64_dims_16_states_fold_3_0.err
#SBATCH --time=6:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2021.05
source activate /project/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py 64 3 16 rs CO 0
sbatch --dependency=afterany:$SLURM_JOB_ID sbatch_66_dims_16_states_fold_3_train-model_1.sh