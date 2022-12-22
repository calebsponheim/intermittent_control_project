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
subject = 'rs'
task = 'RTP'
model = 'rslds'

if (subject == 'rs') & (task == 'RTP'):
    num_latent_dims_rslds = 25
    num_discrete_states_rslds = 10
    num_latent_dims_slds = 2
    num_discrete_states_slds = 2
    num_latent_dims_lds = 40
    num_discrete_states_hmm = 28
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

latentpath = folderpath

# Identifying Test/Train Trials from the models
test_portion = 0.2
iFold = 1
# see if multifold shuffles index file csv is already made
temp_datafolderlist = os.listdir(latentpath)

# Trials
if 'multifold_trial_classification.csv' in temp_datafolderlist:
    # if it is, then load it
    multifold_shuffled_order = pd.DataFrame.to_numpy(pd.read_csv(
        latentpath + 'multifold_trial_classification.csv'))
elif 'multifold_trial_classification.csv' not in temp_datafolderlist:
    print('uh oh')
    # bring in which fold it is
# take that segment of data
number_of_trials = len(multifold_shuffled_order)
trial_indices = np.arange(0, number_of_trials)

fold_test_data_range_start = int((
    (test_portion*iFold) - test_portion)*number_of_trials)
fold_test_data_range_end = int((test_portion*iFold)*number_of_trials)
test_mask = np.ones_like(trial_indices, bool)
test_mask[fold_test_data_range_start:fold_test_data_range_end] = False
test_mask = np.logical_not(test_mask)
fold_test_trials = multifold_shuffled_order[test_mask]
trial_classification = []
for iTrial in range(number_of_trials):
    if iTrial in fold_test_trials:
        trial_classification.append('test')
    else:
        trial_classification.append('train')

trind_test = [i for i, x in enumerate(trial_classification) if x == "test"]


# Load Latents
if model == 'raw':
    latents_by_trial = []
    latents_test = []
    latent_length = []

    # Importing Raw Spiking Data
    spikefiles = [
        f
        for f in listdir(folderpath)
        if isfile(join(folderpath, f))
        if f.endswith("_spikes.csv")
    ]

    file_count = 0
    data = []
    for iFile in spikefiles:
        data_ind_file = pd.DataFrame.to_numpy(pd.read_csv(folderpath + iFile))
        data.append(data_ind_file)
        file_count += 1

    # Putting spikes into Latent Structure for decode
    file_count = 0
    for iTrial in np.arange(len(data)):
        if iTrial+1 in trind_test:
            # print(iTrial)
            latents_by_trial.extend(data[iTrial].T[1:, :])
            latents_test.append(data[iTrial].T[1:, :])
            latent_length.append(data[iTrial].T[1:, :].shape)
        file_count += 1
else:
    latentfiles = [
        f
        for f in listdir(folderpath)
        if isfile(join(folderpath, f))
        if f.startswith("latent_states_" + model + "_trial_")
    ]
    file_count = 0
    latents_by_trial = []
    latent_length = []

    for iFile in latentfiles:
        # print(iFile)
        iTrial = iFile.split('trial_', 1)[1]
        iTrial = int(iTrial.split('_fold_')[0])
        if iTrial in trind_test:
            # print(iTrial)
            latents = pd.DataFrame.to_numpy(pd.read_csv(folderpath + iFile))
            latents_by_trial.extend(latents)
            latent_length.append(len(latents))
        file_count += 1

# %% PCA analysis

X_kf = np.asarray(latents_by_trial)

pca = PCA()

pca.fit(X_kf)
print(pca.explained_variance_ratio_)
covariance_matrix = pca.get_covariance()
PCA_eigs = np.linalg.eig(covariance_matrix)
PCA_eigs_ratio = PCA_eigs[0]/sum(PCA_eigs[0])
PCA_eigs_cumsum_percentage = np.cumsum(PCA_eigs_ratio)
plt.plot(np.asarray(np.arange(25)), np.asarray(np.ones([25, 1])*.8), color='black')
plt.plot(PCA_eigs_cumsum_percentage)

PCA_eigs = pd.DataFrame(PCA_eigs)
PCA_eigs.to_csv(
    folderpath + model + '_PCA_eigs.csv', index=False, header=True)
