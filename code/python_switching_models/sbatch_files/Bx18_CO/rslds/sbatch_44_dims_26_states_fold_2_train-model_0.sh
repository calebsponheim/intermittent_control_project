#!/bin/bash
#SBATCH --job-name=44_26_2_0
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/out_files/Bx18_CO/rSLDS_44_dims_26_states_fold_2_0.out
#SBATCH --output=/project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/error_files/Bx18_CO/rSLDS_44_dims_26_states_fold_2_0.err
#SBATCH --time=6:00:00
#SBATCH --mem-per-cpu=48G
#SBATCH --account=pi-nicho
#SBATCH --partition=caslake
module load python/anaconda-2021.05
source activate /project/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/
python /project/nicho/caleb/git/intermittent_control_project/code/python_switching_models/run_param_search.py 44 2 26 Bx18 CO 0
sbatch --dependency=afterany:$SLURM_JOB_ID sbatch_46_dims_26_states_fold_2_train-model_1.sh