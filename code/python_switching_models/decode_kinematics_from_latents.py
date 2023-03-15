# -*- coding: utf-8 -*-
"""
Created on Mon Nov 21 09:45:48 2022

@author: caleb_work
"""


import os
import pandas as pd


def decode_kinematics_from_latents(kinpath, latentpath, model):

    import pandas as pd
    import numpy as np
    from os import listdir
    from os.path import isfile, join
    import Neural_Decoding

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

    kinfiles = [
        f
        for f in listdir(folderpath)
        if isfile(join(folderpath, f))
        if f.endswith("_kinematics.csv")
    ]
    file_count = 0
    full_kinematics_by_trial = []
    for iFile in kinfiles:
        iTrial = iFile.split('trial', 1)[1]
        iTrial = int(iTrial.split('_kinematics')[0])
        if iTrial in trind_test:
            kinematics = pd.DataFrame.to_numpy(pd.read_csv(folderpath + iFile))
            full_kinematics_by_trial.append(kinematics)
        file_count += 1

    # Bin Kinematics
    full_kinematics_binned = []
    kin_length = []
    for iTrial in np.arange(len(full_kinematics_by_trial)):
        vels = np.asarray(full_kinematics_by_trial[iTrial])
        vel_times = np.arange(len(full_kinematics_by_trial[iTrial]))/1000
        dt = .05
        t_start = 0
        t_end = len(full_kinematics_by_trial[iTrial])/1000
        downsample_factor = 1
        out = Neural_Decoding.bin_output(vels, vel_times, dt, t_start, t_end, downsample_factor)
        full_kinematics_binned.extend(out)
        kin_length.append(out.shape[0])

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
        file_include_count = 0
        for iTrial in np.arange(len(data)):
            if iTrial+1 in trind_test:
                # print(iTrial)
                latents_by_trial.extend(data[iTrial].T[1:kin_length[file_include_count]+1, :])
                latents_test.append(data[iTrial].T[1:, :])
                latent_length.append(data[iTrial].T[1:, :].shape)
                file_include_count = file_include_count + 1
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
        file_include_count = 0
        for iFile in latentfiles:
            # print(iFile)
            iTrial = iFile.split('trial_', 1)[1]
            iTrial = int(iTrial.split('_fold_')[0])
            if iTrial in trind_test:
                # print(iTrial)
                latents = pd.DataFrame.to_numpy(pd.read_csv(folderpath + iFile))
                latents_by_trial.extend(latents[0:kin_length[file_include_count]])
                latent_length.append(len(latents))
                file_include_count = file_include_count + 1
            file_count += 1

    # %% Decoding
    R2_kf_all = []

    test_portion = .01
    y_valid_predicted_kf = []

    lag = 0
    X_kf = np.asarray(latents_by_trial)
    y_kf = np.asarray(full_kinematics_binned)

    # Remove neurons with too few spikes in HC dataset
    if model == "raw" or model == 'hmm':
        nd_sum = np.nansum(X_kf, axis=0)  # Total number of spikes of each neuron
        rmv_nrn = np.where(nd_sum < 100)  # Find neurons who have less than 100 spikes total
        X_kf = np.delete(X_kf, rmv_nrn, 1)  # Remove those neurons

    num_examples_kf = X_kf.shape[0]
    multifold_order = np.asarray(np.arange(num_examples_kf))

    for iFold in np.arange(1, (1/test_portion)+1):

        # Number of examples after taking into account bins removed for lag alignment

        fold_test_data_range_start = int((
            (test_portion*iFold) - test_portion)*num_examples_kf)
        fold_test_data_range_end = int((test_portion*iFold)*num_examples_kf)

        test_mask = np.zeros_like(np.arange(num_examples_kf), bool)
        test_mask[fold_test_data_range_start:fold_test_data_range_end] = True
        train_mask = np.logical_not(test_mask)
        fold_test_timepoints = multifold_order[test_mask]
        fold_train_timepoints = multifold_order[train_mask]

        # Note that each range has a buffer of 1 bin at the beginning and end
        # This makes it so that the different sets don't include overlapping data

        # Get training data
        X_kf_train = X_kf[fold_train_timepoints, :]
        y_kf_train = y_kf[fold_train_timepoints, :]

        # Get testing data
        X_kf_test = X_kf[fold_test_timepoints, :]
        y_kf_test = y_kf[fold_test_timepoints, :]

        # Z-score inputs
        X_kf_train_mean = np.nanmean(X_kf_train, axis=0)
        X_kf_train_std = np.nanstd(X_kf_train, axis=0)
        X_kf_train = (X_kf_train-X_kf_train_mean)/X_kf_train_std
        X_kf_test = (X_kf_test-X_kf_train_mean)/X_kf_train_std

        # Zero-center outputs
        y_kf_train_mean = np.mean(y_kf_train, axis=0)
        y_kf_train = y_kf_train-y_kf_train_mean
        y_kf_test = y_kf_test-y_kf_train_mean

        # Declare model
        # There is one optional parameter (see ReadMe)
        model_kf = Neural_Decoding.KalmanFilterDecoder(C=1)

        # Fit model
        model_kf.fit(X_kf_train, y_kf_train)

        # Get predictions
        y_test_predicted_kf = model_kf.predict(X_kf_test, y_kf_test)

        # Printing out R2s for all of the kinematics parameters
        R2_kf = Neural_Decoding.get_R2(y_kf_test, y_test_predicted_kf)
        print('R2:', R2_kf)

        R2_kf_all.append(R2_kf)

    return R2_kf_all, y_valid_predicted_kf, model_kf


# %% Parameter Setting
subject = 'bx'
task = 'RTP'
model = 'raw'

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
        # folderpath = (
        #     folderpath_base + "Bxcenter_out1902280.05_sBins_move_window_only/"
        # )
    elif task == "CO+RTP":
        folderpath = folderpath_base + "Bxcenter_out_and_RTP1902280.05sBins/"
    elif task == "RTP":
        folderpath = folderpath_base + "BxRTP0.05sBins/"
elif subject == "bx18":
    folderpath = folderpath_base + "Bx18CO0.05sBins/"
elif subject == "rs":
    if task == "CO":
        # folderpath = folderpath_base + "RSCO0.05sBins/"
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
kinpath = folderpath
# %%

R2_kf_all, y_valid_predicted_kf, model_kf = decode_kinematics_from_latents(
    kinpath, latentpath, model)

# %%
R2_kf_all_out = pd.DataFrame(R2_kf_all)
R2_kf_all_out.to_csv(
    folderpath + model + '_kalman_test_R2_for_model_comparison.csv', index=False, header=True)
