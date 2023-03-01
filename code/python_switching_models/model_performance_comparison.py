# -*- coding: utf-8 -*-
"""
Created on Thu Sep 22 14:51:33 2022

Running Performance Comparison Across Different Models. Same folds and trials and stuff.
Different optimal states and dimensions for each type of model.

@author: caleb_work
"""
import os
from import_matlab_data import import_matlab_data
import pandas as pd
import numpy as np
import ssm
import pickle

# %% Parameter Setting

train_portion = 0.8
test_portion = 0.2
subject = 'rj'
task = 'RTP'

if (subject == 'rs') & (task == 'RTP'):
    num_latent_dims_rslds = 25
    num_discrete_states_rslds = 10
    num_latent_dims_lds = 40
    num_discrete_states_hmm = 28
elif (subject == 'rj') & (task == 'RTP'):
    num_latent_dims_rslds = 25
    num_discrete_states_rslds = 10
    num_latent_dims_lds = 43
    num_discrete_states_hmm = 67
elif (subject == 'bx') & (task == 'RTP'):
    num_latent_dims_rslds = 30
    num_discrete_states_rslds = 10
    num_latent_dims_lds = 49
    num_discrete_states_hmm = 43
elif (subject == 'rs') & (task == 'CO'):
    num_latent_dims_rslds = 14
    num_discrete_states_rslds = 8
    num_latent_dims_lds = 80
    num_discrete_states_hmm = 16

trial_folds = int(1/test_portion)
neuron_folds = 4

# %% Data Import
current_working_directory = os.getcwd()
if "calebsponheim" in current_working_directory:
    folderpath_base_base = "C:/Users/calebsponheim/Documents/git/intermittent_control_project/"
elif "dali" in current_working_directory:
    folderpath_base_base = "/dali/nicho/caleb/git/intermittent_control_project/"
elif "Caleb (Work)" in current_working_directory:
    folderpath_base_base = "C:/Users/Caleb (Work)/Documents/git/intermittent_control_project/"
folderpath_base = folderpath_base_base + "data/python_switching_models/"
figurepath_base = folderpath_base_base + "figures/"

if subject == "bx":
    if task == "CO":
        folderpath = folderpath_base + "Bxcenter_out1902280.05sBins/"
        # folderpath = (
        #     folderpath_base + "Bxcenter_out1902280.05_sBins_move_window_only/"
        # )
        figurepath = figurepath_base + "Bx/CO_CT0/rslds/"
    elif task == "CO+RTP":
        folderpath = folderpath_base + "Bxcenter_out_and_RTP1902280.05sBins/"
        figurepath = figurepath_base + "Bx/CO+RTP_CT0/rslds/"
    elif task == "RTP":
        folderpath = folderpath_base + "BxRTP0.05sBins/"
        figurepath = figurepath_base + "Bx/RTP/rslds/"
elif subject == "bx18":
    folderpath = folderpath_base + "Bx18CO0.05sBins/"
    figurepath = figurepath_base + "Bx/CO18_CT0/rslds/"
elif subject == "rs":
    if task == "CO":
        # folderpath = folderpath_base + "RSCO0.05sBins/"
        folderpath = folderpath_base + "RSCO_move_window0.05sBins/"
        figurepath = figurepath_base + "RS/CO_CT0_move_only/rslds/"

    elif task == "RTP":
        folderpath = folderpath_base + "RSRTP0.05sBins/"
        figurepath = figurepath_base + "RS/RTP_CT0/rslds/"
elif subject == "rj":
    folderpath = folderpath_base + "RJRTP0.05sBins/"
    figurepath = figurepath_base + "RJ/RTP_CT0/rslds/"
else:
    print("BAD, NO")

temp_folderlist = os.listdir(folderpath)
temp_figurelist = os.listdir(figurepath)

temp = str(num_discrete_states_rslds) + "_states_" + str(num_latent_dims_rslds) + "_dims"

if temp not in temp_folderlist:
    os.mkdir(folderpath + str(num_discrete_states_rslds) +
             "_states_" + str(num_latent_dims_rslds) + "_dims/")

if temp not in temp_figurelist:
    os.mkdir(figurepath + str(num_discrete_states_rslds) +
             "_states_" + str(num_latent_dims_rslds) + "_dims/")

folderpath_out = folderpath
figurepath = figurepath


class meta:
    def __init__(self, train_portion, test_portion):
        self.train_portion = train_portion
        self.test_portion = test_portion


meta = meta(train_portion, test_portion)
data = import_matlab_data(folderpath)


# %% Big for loop for folds?
hmm_test_ll = []
slds_test_ll = []
rslds_test_ll = []
lds_test_ll = []

# Trial Classification
number_of_trials = len(data.spikes)
number_of_neurons = len(data.spikes[0])
trial_indices = np.arange(0, number_of_trials)
neuron_indices = np.arange(0, number_of_neurons)

# see if multifold shuffles index file csv is already made
temp_datafolderlist = os.listdir(folderpath_out)

# Trials
if 'multifold_trial_classification.csv' in temp_datafolderlist:
    # if it is, then load it
    multifold_shuffled_order = pd.DataFrame.to_numpy(pd.read_csv(
        folderpath_out + 'multifold_trial_classification.csv'))
elif 'multifold_trial_classification.csv' not in temp_datafolderlist:
    # if not, make it
    np.random.shuffle(trial_indices)
    multifold_shuffled_order = trial_indices

    multifold_shuffled_order_out = pd.DataFrame(multifold_shuffled_order)
    multifold_shuffled_order_out.to_csv(
        folderpath_out + 'multifold_trial_classification.csv', index=False, header=True)

iFold = 1
# for iFold in np.arange(1, trial_folds+1):
# bring in which fold it is
# take that segment of data
fold_test_data_range_start = int((
    (test_portion*iFold) - test_portion)*number_of_trials)
fold_test_data_range_end = int((test_portion*iFold)*number_of_trials)
test_mask = np.ones_like(trial_indices, bool)
test_mask[fold_test_data_range_start:fold_test_data_range_end] = False
test_mask = np.logical_not(test_mask)
train_mask = np.logical_not(test_mask)
fold_test_trials = multifold_shuffled_order[test_mask]
fold_train_trials = multifold_shuffled_order[train_mask]
trial_classification = []
for iTrial in range(number_of_trials):
    if iTrial in fold_test_trials:
        trial_classification.append('test')
    elif iTrial in fold_train_trials:
        trial_classification.append('train')

trind_train = [i for i, x in enumerate(trial_classification) if x == "train"]
trind_test = [i for i, x in enumerate(trial_classification) if x == "test"]
trind_full = [i for i, x in enumerate(trial_classification) if x == "test" or "train"]

trainset = []
testset = []
fullset = []

for iTrial in range(len(trial_classification)):
    fullset.append(np.transpose(np.array(data.spikes[iTrial])))
    if iTrial in trind_train:
        trainset.append(np.transpose(np.array(data.spikes[iTrial])))
    elif iTrial in trind_test:
        testset.append(np.transpose(np.array(data.spikes[iTrial])))

observation_dimensions = trainset[0].shape[1]
# %%
# HMM
N_iters = 15
hmm = ssm.HMM(
    num_discrete_states_hmm,
    observation_dimensions,
    observations="poisson",
    transitions="standard",
)

lls = hmm.fit(
    trainset,
    method="em",
    num_iters=N_iters,
    init_method="random",
)
hmm_params = hmm.params
emission_matrix = hmm_params[2]

most_likely_states = []
latent_states_hmm = []
for iTrial in range(len(fullset)):
    most_likely_states = hmm.most_likely_states(fullset[iTrial])
    latent_states_step = []
    for iState in np.arange(len(most_likely_states)):
        latent_states_step.append(np.transpose(emission_matrix[most_likely_states[iState], :]))
    latent_states_step = np.asarray(latent_states_step)
    latent_states_hmm.append(latent_states_step)

for iTrial in range(len(fullset)):
    latent_states_hmm_out = pd.DataFrame(latent_states_hmm[iTrial])
    latent_states_hmm_out.to_csv(folderpath_out + "latent_states_hmm_trial_" + str(
        '{:04}'.format(iTrial+1)) + "_fold_" + str(iFold) + ".csv", index=False, header=False)

# # model selection decode
# hmm_test_ll.append(hmm.log_likelihood(testset))

# print("Created HMM Model")
# %%
# LDS
model = ssm.LDS(observation_dimensions, num_latent_dims_lds,
                emissions="poisson")
model.initialize(trainset)
q_elbos_lem_train, q_lem_train = model.fit(trainset, method="laplace_em",
                                           variational_posterior="structured_meanfield",
                                           num_iters=15)

inputs = inputs = [np.zeros((y.shape[0], model.M)) for y in testset]
masks = []
for y in testset:
    mask = np.ones_like(y)
    mask = mask.astype(bool)
    masks.append(mask)

q_elbos_lem_test, q_lem_test = model.approximate_posterior(
    testset,
    method="laplace_em",
    variational_posterior="structured_meanfield",
    num_iters=15, alpha=0.5)


xhat_lem = []
for iTrial in range(len(trind_train)):
    xhat_lem.insert(trind_train[iTrial], q_lem_train.mean_continuous_states[iTrial])
for iTrial in range(len(trind_test)):
    xhat_lem.insert(trind_test[iTrial], q_lem_test.mean_continuous_states[iTrial])

for iTrial in range(len(xhat_lem)):
    latent_states_rslds_temp = pd.DataFrame(xhat_lem[iTrial])
    latent_states_rslds_temp.to_csv(folderpath_out + "latent_states_lds_trial_" +
                                    str('{:04}'.format(iTrial+1)) + "_fold_" +
                                    str(iFold) + ".csv", index=False, header=False)


lls = 0.0
for tr in range(len(testset)):
    ll = np.sum(model.emissions.log_likelihoods(testset[tr],
                                                inputs[tr],
                                                mask=masks[tr],
                                                tag=None,
                                                x=q_lem_test.mean_continuous_states[tr]))
    lls += ll
lds_test_ll.append(lls)
print("Created LDS Model")

# %%
# rSLDS
model = ssm.SLDS(observation_dimensions, num_discrete_states_rslds, num_latent_dims_rslds,
                 transitions="recurrent",
                 dynamics="diagonal_gaussian",
                 emissions="poisson",
                 single_subspace=True)
model.initialize(trainset)
q_elbos_lem_train, q_lem_train = model.fit(trainset, method="laplace_em",
                                           variational_posterior="structured_meanfield",
                                           initialize=False,
                                           num_iters=15)

# Pickling/Saving Trained Model

filename = folderpath_out + 'fold_' + str(iFold) + '_model_pickle_for_performance_comparison'
outfile = open(filename, 'wb')
pickle.dump(model, outfile)
outfile.close()

q_elbos_lem_test, q_lem_test = model.approximate_posterior(
    datas=testset,
    method="laplace_em",
    variational_posterior="structured_meanfield",
    num_iters=15)

xhat_lem = []
for iTrial in range(len(trind_train)):
    xhat_lem.insert(trind_train[iTrial], q_lem_train.mean_continuous_states[iTrial])
for iTrial in range(len(trind_test)):
    xhat_lem.insert(trind_test[iTrial], q_lem_test.mean_continuous_states[iTrial])

for iTrial in range(len(xhat_lem)):
    latent_states_rslds_temp = pd.DataFrame(xhat_lem[iTrial])
    latent_states_rslds_temp.to_csv(folderpath_out + "latent_states_rslds_trial_" +
                                    str('{:04}'.format(iTrial+1)) + "_fold_" +
                                    str(iFold) + ".csv", index=False, header=False)

inputs = inputs = [np.zeros((y.shape[0], model.M)) for y in testset]
masks = []
for y in testset:
    mask = np.ones_like(y)
    mask = mask.astype(bool)
    masks.append(mask)

_elbos, _q_model = model.approximate_posterior(
    testset,
    method="laplace_em",
    masks=masks,
    variational_posterior="structured_meanfield",
    num_iters=15, alpha=0.5)

lls = 0.0
for tr in range(len(testset)):
    ll = np.sum(model.emissions.log_likelihoods(testset[tr],
                                                inputs[tr],
                                                mask=masks[tr],
                                                tag=None,
                                                x=_q_model.mean_continuous_states[tr]))
    lls += ll
rslds_test_ll.append(lls)
print("Created rSLDS Model")

# %% Save Results

hmm_test_ll_out = pd.DataFrame(hmm_test_ll)
hmm_test_ll_out.to_csv(
    folderpath_out + 'hmm_test_ll_for_model_comparison.csv', index=False, header=True)
lds_test_ll_out = pd.DataFrame(lds_test_ll)
lds_test_ll_out.to_csv(
    folderpath_out + 'lds_test_ll_for_model_comparison.csv', index=False, header=True)
rslds_test_ll_out = pd.DataFrame(rslds_test_ll)
rslds_test_ll_out.to_csv(
    folderpath_out + 'rslds_test_ll_for_model_comparison.csv', index=False, header=True)
