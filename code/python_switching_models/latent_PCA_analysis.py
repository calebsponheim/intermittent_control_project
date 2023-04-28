# -*- coding: utf-8 -*-
"""
Created on Thu Dec 22 08:46:39 2022

@author: caleb_work
"""

import os
import pandas as pd
import numpy as np
# from os import listdir
# from os.path import isfile, join
# from sklearn.decomposition import PCA
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
    num_latent_dims_rslds = 25
    num_discrete_states_rslds = 10
    num_latent_dims_slds = 2
    num_discrete_states_slds = 2
    num_latent_dims_lds = 80
    num_discrete_states_hmm = 16
elif (subject == 'bx') & (task == 'RTP'):
    num_latent_dims_rslds = 30
    num_discrete_states_rslds = 10
    num_latent_dims_lds = 46
    num_discrete_states_hmm = 43
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
    elif task == "RTP":
        folderpath = folderpath_base + "BxRTP0.05sBins/"
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

discrete_states_full = pd.DataFrame.to_numpy(pd.read_csv(
    folderpath + str(num_discrete_states_rslds) + "_states_" +
    str(num_latent_dims_rslds) + "_dims/discrete_states_full.csv", header=None))
latent_states_full = pd.DataFrame.to_numpy(pd.read_csv(
    folderpath + str(num_discrete_states_rslds) + "_states_" +
    str(num_latent_dims_rslds) + "_dims/latent_states_full.csv", header=None))

latent_states_speed = np.vstack((np.diff(latent_states_full, axis=0),
                                np.zeros([1, num_latent_dims_rslds])))

# %% Variance analysis
variance = []
dims_to_include = []
avg_state_speed = []
avg_avg_state_speed = []
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
        # vp = (np.dot(a, b) / np.dot(b, b)) * b # This is my version from the internet
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

    ###################### Trajectory Speed #########################

    # pulling in state-specific dynamics
    state_specific_dynamics_indices = np.where(discrete_states_full == (iState-1))[0]
    speed = latent_states_speed[state_specific_dynamics_indices, :]
    avg_avg_state_speed.append(np.mean(np.mean(abs(speed), axis=0)))
    avg_state_speed.append(np.mean(abs(speed), axis=0))


avg_state_speed = pd.DataFrame(avg_state_speed)
avg_state_speed.to_csv(folderpath + str(num_discrete_states_rslds) +
                       "_states_" + str(num_latent_dims_rslds) + "_dims/" +
                       'avg_state_trajectory_speed.csv', index=False, header=False)


dims_to_include = pd.DataFrame(dims_to_include)
dims_to_include.to_csv(folderpath + str(num_discrete_states_rslds) +
                       "_states_" + str(num_latent_dims_rslds) + "_dims/" +
                       'dims_to_include.csv', index=False, header=False)
