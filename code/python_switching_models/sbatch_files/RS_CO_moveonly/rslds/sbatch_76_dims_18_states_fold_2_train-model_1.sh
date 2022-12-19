#!/bin/bash
#SBATCH --job-name=76_18_2_1
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/rs_CO/rSLDS_76_dims_18_states_fold_2_1.out
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/rs_CO/rSLDS_76_dims_18_states_fold_2_1.err
#SBATCH --time=10:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2021.05
source activate /project/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py 76 2 18 rs CO 1
sbatch --dependency=afterany:$SLURM_JOB_ID sbatch_76_dims_18_states_fold_2_train-model_0.sh