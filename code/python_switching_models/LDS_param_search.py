# -*- coding: utf-8 -*-
"""
HMM Optimal State Estimation Parameter Search.
"""
import os
from import_matlab_data import import_matlab_data
import pandas as pd
import numpy as np
import ssm
import sys
# from numpy.linalg import eig
# import autograd.numpy.random as npr
# import matplotlib.pyplot as plt
# import csv
# from assign_trials_to_HMM_group import assign_trials_to_HMM_group

# %% Parameter Setting

train_portion = 0.8
test_portion = 0.2
num_neuron_folds = 4


fold_number = int(sys.argv[1])
task = str(sys.argv[2])
subject = str(sys.argv[3])
num_dims = int(sys.argv[4])

# fold_number = 1
# task = "CO"
# subject = 'rs'
# num_dims = 2

# %% Data Import
current_working_directory = os.getcwd()
if "calebsponheim" in current_working_directory:
    folderpath_base_base = "C:/Users/calebsponheim/Documents/git/intermittent_control_project/"
elif "dali" in current_working_directory:
    folderpath_base_base = "/dali/nicho/caleb/git/intermittent_control_project/"
elif "project/nicho/projects/caleb" in current_working_directory:
    folderpath_base_base = "/project/nicho/projects/caleb/git/intermittent_control_project/"
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
    folderpath = folderpath_base + "RJRTP0.05sBins_1031126/"
    figurepath = figurepath_base + "RJ/RTP_CT0/rslds/"
else:
    print("BAD, NO")


temp_folderlist = os.listdir(folderpath)
temp_figurelist = os.listdir(figurepath)
if str(num_dims) + "_dims" not in temp_folderlist:
    os.mkdir(folderpath + str(num_dims) + "_dims/")
if str(num_dims) + "_dims" not in temp_figurelist:
    os.mkdir(figurepath + str(num_dims) + "_dims/")

folderpath_out = folderpath + str(num_dims) + "_dims/"
figurepath = figurepath + str(num_dims) + "_lds/"


class meta:
    def __init__(self, train_portion, test_portion):
        self.train_portion = train_portion
        self.test_portion = test_portion


meta = meta(train_portion, test_portion)
data = import_matlab_data(folderpath)

hmm_test_ll = []


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

fold_test_data_range_start = int((
    (test_portion*fold_number) - test_portion)*number_of_trials)
fold_test_data_range_end = int((test_portion*fold_number)*number_of_trials)
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
# Neurons
if 'multifold_neuron_classification.csv' in temp_datafolderlist:
    # if it is, then load it
    multifold_shuffled_neuron_order = pd.DataFrame.to_numpy(pd.read_csv(
        folderpath_out + 'multifold_neuron_classification.csv'))
elif 'multifold_neuron_classification.csv' not in temp_datafolderlist:
    # if not, make it
    np.random.shuffle(neuron_indices)
    multifold_shuffled_neuron_order = neuron_indices

    multifold_shuffled_neuron_order_out = pd.DataFrame(multifold_shuffled_neuron_order)
    multifold_shuffled_neuron_order_out.to_csv(
        folderpath_out + 'multifold_neuron_classification.csv', index=False, header=True)

# bring in which fold it is
# take that segment of data
neuron_classification = []
fold_assignments = np.array_split(multifold_shuffled_neuron_order, num_neuron_folds)
for iFold in np.arange(len(fold_assignments)):
    for iNeuron in fold_assignments[iFold]:
        neuron_classification.insert(int(iNeuron), iFold)

# %%
trind_train = [i for i, x in enumerate(
    trial_classification) if x == "train"]
trind_test = [i for i, x in enumerate(
    trial_classification) if x == "test"]
trainset = []
testset = []

for iTrial in range(len(trial_classification)):
    if iTrial in trind_train:
        trainset.append(np.transpose(np.array(data.spikes[iTrial])))
    elif iTrial in trind_test:
        testset.append(np.transpose(np.array(data.spikes[iTrial])))

# %%
observation_dimensions = trainset[0].shape[1]
N_iters = 15

model = ssm.LDS(observation_dimensions, num_dims,
                emissions="poisson")
model.initialize(trainset)
q_elbos_lem_train, q_lem_train = model.fit(trainset, method="laplace_em",
                                           variational_posterior="structured_meanfield",
                                           num_iters=N_iters)

inputs = inputs = [np.zeros((y.shape[0], model.M)) for y in testset]
lls = [0] * len(np.unique(neuron_classification))

for iFold in np.unique(neuron_classification):
    test_neur = [i for i, x in enumerate(neuron_classification) if x == iFold]
    masks = []
    for y in testset:
        mask = np.ones_like(y)
        mask[:, test_neur] *= 0
        mask = mask.astype(bool)
        masks.append(mask)

    _elbos, _q_model = model.approximate_posterior(
        testset, inputs=inputs, masks=masks,
        method="laplace_em",
        variational_posterior="structured_meanfield",
        num_iters=N_iters, alpha=0.5)

    for tr in range(len(testset)):
        ll = np.sum(model.emissions.log_likelihoods(testset[tr],
                                                    inputs[tr],
                                                    mask=np.invert(masks[tr]),
                                                    tag=None,
                                                    x=_q_model.mean_continuous_states[tr]))
        lls[iFold] = lls[iFold] + ll

log_likelihood_emissions_sum = np.mean(lls)

log_likelihood_emissions_sum = pd.DataFrame([log_likelihood_emissions_sum])

log_likelihood_emissions_sum.to_csv(folderpath_out + str(
    num_dims) + "_dims_test_emissions_ll_fold_" + str(fold_number) + ".csv", index=False, header=False)
