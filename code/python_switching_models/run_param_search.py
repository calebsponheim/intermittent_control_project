from run_rslds import run_rslds
import numpy as np
import sys

train_portion = 0.8
model_select_portion = 0.0
test_portion = 0.2
hidden_max_state_range = 120
hidden_state_skip = 1
rslds_ll_analysis = 1
multiple_folds = 0
latent_dim_state_range = int(sys.argv[1])
# latent_dim_state_range = int(2)
midway_run = 1

subject = 'bx18'
task = 'CO'
num_hidden_state_override = 16

# %% Running it
model, xhat_lem, fullset, model_params, real_eigenvectors_out, imaginary_eigenvectors_out, real_eigenvalues_out, imaginary_eigenvalues_out = run_rslds(
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
    multiple_folds,
    midway_run
)
