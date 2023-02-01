# -*- coding: utf-8 -*-
"""
Created on Thu Dec 22 08:46:39 2022

@author: caleb_work
"""

import os
import pandas as pd
import numpy as np
from os import listdir
from os.path import isfile, join
from sklearn.decomposition import PCA
import matplotlib.pyplot as plt

# %% Parameter Setting
subject = 'rj'
task = 'RTP'
model = 'rslds'
cutoff = .9

if (subject == 'rs') & (task == 'RTP'):
    num_latent_dims_rslds = 25
    num_discrete_states_rslds = 10
    num_latent_dims_slds = 2
    num_discrete_states_slds = 2
    num_latent_dims_lds = 40
    num_discrete_states_hmm = 28
elif (subject == 'rj') & (task == 'RTP'):
    num_latent_dims_rslds = 22
    num_discrete_states_rslds = 10
    num_latent_dims_slds = 2
    num_discrete_states_slds = 2
    num_latent_dims_lds = 80
    num_discrete_states_hmm = 16
elif (subject == 'rs') & (task == 'CO'):
    num_latent_dims_rslds = 14
    num_discrete_states_rslds = 8
    num_latent_dims_slds = 2
    num_discrete_states_slds = 2
    num_latent_dims_lds = 80
    num_discrete_states_hmm = 16

# %% Data Import


current_working_directory = os.getcwd()
if "calebsponheim" in current_working_directory:
    folderpath_base_base = "C:/Users/calebsponheim/Documents/git/intermittent_control_project/"
elif "dali" in current_working_directory:
    folderpath_base_base = "/dali/nicho/caleb/git/intermittent_control_project/"
elif "Caleb (Work)" in current_working_directory:
    folderpath_base_base = "C:/Users/Caleb (Work)/Documents/git/intermittent_control_project/"
folderpath_base = folderpath_base_base + "data/python_switching_models/"

if subject == "bx":
    if task == "CO":
        folderpath = folderpath_base + "Bxcenter_out1902280.05sBins/"
    elif task == "CO+RTP":
        folderpath = folderpath_base + "Bxcenter_out_and_RTP1902280.05sBins/"
elif subject == "bx18":
    folderpath = folderpath_base + "Bxcenter_out1803230.05sBins/"
elif subject == "rs":
    if task == "CO":
        folderpath = folderpath_base + "RSCO_move_window0.05sBins/"
    elif task == "RTP":
        folderpath = folderpath_base + "RSRTP0.05sBins/"
elif subject == "rj":
    folderpath = folderpath_base + "RJRTP0.05sBins/"
else:
    print("BAD, NO")

temp_folderlist = os.listdir(folderpath)
temp = str(num_discrete_states_rslds) + "_states_" + str(num_latent_dims_rslds) + "_dims"
if temp not in temp_folderlist:
    os.mkdir(folderpath + str(num_discrete_states_rslds) +
             "_states_" + str(num_latent_dims_rslds) + "_dims/")

# latentpath = folderpath
# %% Load Latents

# # Identifying Test/Train Trials from the models
# test_portion = 0.2
# iFold = 1
# # see if multifold shuffles index file csv is already made
# temp_datafolderlist = os.listdir(latentpath)

# # Trials
# if 'multifold_trial_classification.csv' in temp_datafolderlist:
#     # if it is, then load it
#     multifold_shuffled_order = pd.DataFrame.to_numpy(pd.read_csv(
#         latentpath + 'multifold_trial_classification.csv'))
# elif 'multifold_trial_classification.csv' not in temp_datafolderlist:
#     print('uh oh')
#     # bring in which fold it is
# # take that segment of data
# number_of_trials = len(multifold_shuffled_order)
# trial_indices = np.arange(0, number_of_trials)

# fold_test_data_range_start = int((
#     (test_portion*iFold) - test_portion)*number_of_trials)
# fold_test_data_range_end = int((test_portion*iFold)*number_of_trials)
# test_mask = np.ones_like(trial_indices, bool)
# test_mask[fold_test_data_range_start:fold_test_data_range_end] = False
# test_mask = np.logical_not(test_mask)
# fold_test_trials = multifold_shuffled_order[test_mask]
# trial_classification = []
# for iTrial in range(number_of_trials):
#     if iTrial in fold_test_trials:
#         trial_classification.append('test')
#     else:
#         trial_classification.append('train')

# trind_test = [i for i, x in enumerate(trial_classification) if x == "test"]

# latentfiles = [
#     f
#     for f in listdir(folderpath + str(num_discrete_states_rslds) +
#                      "_states_" + str(num_latent_dims_rslds) + "_dims/")
#     if isfile(join(folderpath + str(num_discrete_states_rslds) +
#                    "_states_" + str(num_latent_dims_rslds) + "_dims/", f))
#     if f.startswith("latent_states_full")
# ]
# file_count = 0
# latents_by_trial = []
# latent_length = []

# for iFile in latentfiles:
#     # print(iFile)
#     iTrial = iFile.split('trial_', 1)[1]
#     iTrial = int(iTrial.split('.csv')[0]) - 1
#     # if iTrial in trind_test:
#     print(iTrial)
#     latents = pd.DataFrame.to_numpy(pd.read_csv(folderpath + str(num_discrete_states_rslds) +
#                                                 "_states_" + str(num_latent_dims_rslds) +
#                                                 "_dims/" + iFile, index_col=False))
#     latents_by_trial.insert(iTrial, latents)
#     latent_length.insert(iTrial, np.shape(latents)[0])
#     file_count += 1

discrete_states_full = pd.DataFrame.to_numpy(pd.read_csv(
    folderpath + str(num_discrete_states_rslds) + "_states_" +
    str(num_latent_dims_rslds) + "_dims/discrete_states_full.csv", header=None))
latent_states_full = pd.DataFrame.to_numpy(pd.read_csv(
    folderpath + str(num_discrete_states_rslds) + "_states_" +
    str(num_latent_dims_rslds) + "_dims/latent_states_full.csv", header=None))

# discrete_state_length = []
# discrete_states_by_trial = []

# %% Variance analysis
variance = []
dims_to_include = []
for iState in np.arange(num_discrete_states_rslds) + 1:
    variance_state = []

    # Pulling in eigenvectors

    state_real_eigenvectors = pd.DataFrame.to_numpy(
        pd.read_csv(folderpath + str(num_discrete_states_rslds) +
                    "_states_" + str(num_latent_dims_rslds) + "_dims/" +
                    'real_eigenvectors_state_' + str(iState) + '.csv'))
    state_imaginary_eigenvectors = pd.DataFrame.to_numpy(
        pd.read_csv(folderpath + str(num_discrete_states_rslds) +
                    "_states_" + str(num_latent_dims_rslds) + "_dims/" +
                    'imaginary_eigenvectors_state_' + str(iState) + '.csv'))
    state_complex_eigenvectors = np.zeros(
        [len(state_real_eigenvectors), len(state_real_eigenvectors)], dtype=np.complex_)
    for iRow in np.arange(len(state_real_eigenvectors)):
        for iColumn in np.arange(len(state_real_eigenvectors)):
            state_complex_eigenvectors[iRow, iColumn] = complex(
                state_real_eigenvectors[iRow, iColumn], state_imaginary_eigenvectors[iRow, iColumn])

    # pulling in state-specific dynamics
    state_specific_dynamics_indices = np.where(discrete_states_full == (iState-1))[0]
    a = latent_states_full[state_specific_dynamics_indices, :]

    # COLUMNS ARE DIMENSIONS
    for iDim in np.arange(len(state_complex_eigenvectors)):
        b = state_complex_eigenvectors[:, iDim]
        # vp = (np.dot(a, b) / np.dot(b, b)) * b # This is my version from thie internet
        vp = np.dot(a, b)  # This is Nicho's version
        variance_state.append(np.var(vp))
    variance_state_ratio = variance_state/sum(variance_state)
    variance_state_sort_order = np.argsort(variance_state_ratio)

    variance_state_cumsum_percentage = np.cumsum(
        np.flip(variance_state_ratio[variance_state_sort_order]))
    variance_states_cutoff = variance_state_cumsum_percentage < cutoff
    variance_states_cutoff[sum(variance_states_cutoff)] = True
    state_dims_to_include = np.flip(variance_state_sort_order)[variance_states_cutoff]
    # Plotting

    plt.plot(np.asarray(np.arange(num_latent_dims_rslds)), np.asarray(
        np.ones([num_latent_dims_rslds, 1])*cutoff), color='black')
    plt.plot(variance_state_cumsum_percentage)

    variance.append(variance_state)
    dims_to_include.append(state_dims_to_include+1)

dims_to_include = pd.DataFrame(dims_to_include)
dims_to_include.to_csv(folderpath + str(num_discrete_states_rslds) +
                       "_states_" + str(num_latent_dims_rslds) + "_dims/" +
                       'dims_to_include.csv', index=False, header=False)
