#!/bin/bash
#SBATCH --job-name=44_38_5_0
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/rs_CO/rSLDS_44_dims_38_states_fold_5_0.out
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/rs_CO/rSLDS_44_dims_38_states_fold_5_0.err
#SBATCH --time=11:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2021.05
source activate /project/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py 44 5 38 rs CO 0
sbatch --dependency=afterany:$SLURM_JOB_ID sbatch_46_dims_38_states_fold_5_train-model_1.sh