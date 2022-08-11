from run_rslds import run_rslds
import sys

train_portion = 0.8
model_select_portion = 0.0
test_portion = 0.2
hidden_max_state_range = 120
hidden_state_skip = 1
rslds_ll_analysis = 1
latent_dim_state_range = int(sys.argv[1])
# latent_dim_state_range = 2
midway_run = 1
fold_number = int(sys.argv[2])
# fold_number = 1

# subject = 'rs'
subject = str(sys.argv[4])
# task = 'CO'
task = str(sys.argv[5])

num_hidden_state_override = int(sys.argv[3])
# num_hidden_state_override = 2

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
    midway_run,
    fold_number
)
