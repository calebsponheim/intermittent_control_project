from run_rslds import run_rslds
import sys

train_portion = 0.8
model_select_portion = 0.0
test_portion = 0.2
hidden_max_state_range = 120
hidden_state_skip = 1
rslds_ll_analysis = 1
multiple_folds = 0
# latent_dim_state_range = int(sys.argv[1])
latent_dim_state_range = 11
# midway_run = 1
midway_run = 0

subject = 'rs'
task = 'RTP'
# num_hidden_state_override = int(sys.argv[2])
num_hidden_state_override = 16

# %% Running it
run_rslds(
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
