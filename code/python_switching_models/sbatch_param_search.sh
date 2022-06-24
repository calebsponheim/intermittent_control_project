#!/bin/bash
#SBATCH --job-name=CS_rSLDS_%A
#SBATCH --array=2-100
#SBATCH --output=/dali/nicho/caleb/git/intermittent_control_project/code/python_switching_models/rSLDS__%a.out
#SBATCH --error=/dali/nicho/caleb/git/intermittent_control_project/code/python_switching_models/rSLDS__%a.err
#SBATCH --time=36:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem-per-cpu=16G

echo "My SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID

module load python

source activate /dali/nicho/caleb/git/intermittent_control_project/data/ssm_midway_python_environment/

python

from run_rslds import run_rslds
import numpy as np

train_portion = 0.8
model_select_portion = 0.0
test_portion = 0.2
hidden_max_state_range = 120
hidden_state_skip = 1
rslds_ll_analysis = 0
multiple_folds = 0
latent_dim_state_range = $SLURM_ARRAY_TASK_ID
midway_run = 1

subject = 'bx18'
task = 'CO'
num_hidden_state_override = 16

# %% Running it
model, xhat_lem, fullset, model_params, real_eigenvectors_out, imaginary_eigenvectors_out, real_eigenvalues_out, imaginary_eigenvalues_out, midway_run = run_rslds(
    subject,
    task,
    train_portion,
    model_select_portion,
    test_portion,
    hidden_max_state_range,
    hidden_state_skip,
    num_hidden_state_override,
    rslds_ll_analysis,
    latent_dim_state_range,
    multiple_folds
)