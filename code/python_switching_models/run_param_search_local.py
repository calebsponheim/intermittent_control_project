from run_rslds import run_rslds
train_portion = 0.8
model_select_portion = 0.0
test_portion = 0.2
hidden_max_state_range = 120
hidden_state_skip = 1


latent_dim_state_range = 12
fold_number = 1
subject = 'rs'
task = 'CO'
num_hidden_state_override = 8
rslds_ll_analysis = 0
midway_run = 1
num_neuron_folds = 4

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
    fold_number,
    num_neuron_folds
)
