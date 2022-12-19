#!/bin/bash
#SBATCH --job-name=24_34_4_0
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/rs_CO/rSLDS_24_dims_34_states_fold_4_0.out
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/rs_CO/rSLDS_24_dims_34_states_fold_4_0.err
#SBATCH --time=5:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2021.05
source activate /project/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py 24 4 34 rs CO 0
sbatch --dependency=afterany:$SLURM_JOB_ID sbatch_26_dims_34_states_fold_4_train-model_1.sh