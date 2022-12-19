#!/bin/bash
#SBATCH --job-name=42_20_5_0
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/rs_CO/rSLDS_42_dims_20_states_fold_5_0.out
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/rs_CO/rSLDS_42_dims_20_states_fold_5_0.err
#SBATCH --time=4:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2021.05
source activate /project/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py 42 5 20 rs CO 0
sbatch --dependency=afterany:$SLURM_JOB_ID sbatch_44_dims_20_states_fold_5_train-model_1.sh