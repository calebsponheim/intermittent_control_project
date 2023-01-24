from run_rslds import run_rslds

train_portion = 0.8
model_select_portion = 0.0
test_portion = 0.2
hidden_max_state_range = 120
hidden_state_skip = 1


number_of_latent_dimensions = 25
number_of_discrete_states = 10
fold_number = 3
subject = 'rs'
task = 'RTP'
midway_run = 0
rslds_ll_analysis = midway_run
num_neuron_folds = 4
train_model = 1
# %% Running it
run_rslds(
    subject,
    task,
    train_portion,
    model_select_portion,
    test_portion,
    hidden_max_state_range,
    hidden_state_skip,
    number_of_discrete_states,
    rslds_ll_analysis,
    number_of_latent_dimensions,
    midway_run,
    fold_number,
    num_neuron_folds,
    train_model
)
