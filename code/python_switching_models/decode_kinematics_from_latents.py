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
    import matplotlib.pyplot as plt
    from import_matlab_data import import_matlab_data
    # from scipy import io
    # from scipy import stats
    # import pickle
    # Load Kinematics

    kinfiles = [
        f
        for f in listdir(folderpath)
        if isfile(join(folderpath, f))
        if f.endswith("_kinematics.csv")
    ]
    file_count = 0
    full_kinematics_by_trial = []
    for iFile in kinfiles:
        kinematics = pd.DataFrame.to_numpy(pd.read_csv(folderpath + iFile))
        full_kinematics_by_trial.append(kinematics)
        file_count += 1
        if file_count % 100 == 0:
            print(f"Processed Kinematics from trial {file_count}")

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
        full_kinematics_binned.extend(Neural_Decoding.bin_output(
            vels, vel_times, dt, t_start, t_end, downsample_factor))
        kin_length.append(len(Neural_Decoding.bin_output(
            vels, vel_times, dt, t_start, t_end, downsample_factor)))

    # Load Latents
    if model == 'raw':
        latents_by_trial = []
        data = import_matlab_data(latentpath)
        file_count = 0
        for iTrial in np.arange(len(data.spikes)):
            latents_by_trial.extend(np.asarray(data.spikes[iTrial][1:]).T[1:, :])
            file_count += 1
            if file_count % 100 == 0:
                print(f"Processed Latents from trial {file_count}")
    else:
        latentfiles = [
            f
            for f in listdir(folderpath)
            if isfile(join(folderpath, f))
            if f.startswith("latent_states_" + model + "_trial_")
        ]
        file_count = 0
        latents_by_trial = []

        for iFile in latentfiles:
            latents = pd.DataFrame.to_numpy(pd.read_csv(folderpath + iFile))
            latents_by_trial.extend(latents[:, :])
            file_count += 1
            if file_count % 100 == 0:
                print(f"Processed Latents from trial {file_count}")

    # %% Decoding
    R2_kf_all = []

    train_portion = .9
    test_portion = .1
    y_valid_predicted_kf = []

    lag = 0
    # X_kf = scipy.ndimage.gaussian_filter1d(np.asarray(latents_by_trial), 3, axis=0)
    X_kf = np.asarray(latents_by_trial)
    y_kf = np.asarray(full_kinematics_binned)
    num_examples_kf = X_kf.shape[0]
    multifold_order = np.asarray(np.arange(num_examples_kf))

    if model == "raw" or model == 'hmm':
        nd_sum = np.nansum(X_kf, axis=0)  # Total number of spikes of each neuron
        rmv_nrn = np.where(nd_sum < 100)  # Find neurons who have less than 100 spikes total
        X_kf = np.delete(X_kf, rmv_nrn, 1)  # Remove those neurons

    for iFold in np.arange(1, 11):

        # Remove neurons with too few spikes in HC dataset

        # Number of examples after taking into account bins removed for lag alignment

        fold_test_data_range_start = int((
            (test_portion*iFold) - test_portion)*num_examples_kf)
        fold_test_data_range_end = int((test_portion*iFold)*num_examples_kf)

        test_mask = np.zeros_like(np.arange(num_examples_kf), bool)
        test_mask[fold_test_data_range_start:fold_test_data_range_end] = True
        test_mask = np.logical_not(test_mask)
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
    # As an example, I plot an example 1000 values of the x velocity (column index 2),
    # both true and predicted with the Kalman filter
    # Note that I add back in the mean value,
    # so that both true and predicted values are in the original coordinates
    # fig_x_kf = plt.figure()
    # plt.plot(y_kf_valid[1000:2000, 0]+y_kf_train_mean[0],
    #          y_kf_valid[1000:2000, 1]+y_kf_train_mean[1], 'b')
    # plt.plot(y_valid_predicted_kf[1000:2000, 0]+y_kf_train_mean[0],
    #          y_valid_predicted_kf[1000:2000, 1]+y_kf_train_mean[1], 'r')
    # plt.plot(y_kf_valid[1000:2000, 2]+y_kf_train_mean[2], 'b')
    # plt.plot(y_valid_predicted_kf[1000:2000, 2]+y_kf_train_mean[2], 'r')
    # plt.plot(y_kf_valid[1000:2000, 3]+y_kf_train_mean[3], 'b')
    # plt.plot(y_valid_predicted_kf[1000:2000, 3]+y_kf_train_mean[3], 'r')    # Save figure
    # fig_x_kf.savefig('x_velocity_decoding.eps')
    return R2_kf_all, y_valid_predicted_kf, model_kf


# %% Parameter Setting


num_latent_dims_rslds = 25
num_discrete_states_rslds = 10
num_latent_dims_slds = 2
num_discrete_states_slds = 2
num_latent_dims_lds = 40
num_discrete_states_hmm = 28
subject = 'rs'
task = 'RTP'
model = 'raw'

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
if str(num_discrete_states_rslds) + "_states_" + str(num_latent_dims_rslds) + "_dims" not in temp_folderlist:
    os.mkdir(folderpath + str(num_discrete_states_rslds) +
             "_states_" + str(num_latent_dims_rslds) + "_dims/")

latentpath = (folderpath)  # + str(num_discrete_states_rslds) +
#  "_states_" + str(num_latent_dims_rslds) + "_dims/")
kinpath = folderpath

R2_kf_all, y_valid_predicted_kf, model_kf = decode_kinematics_from_latents(
    kinpath, latentpath, model)

R2_kf_all_out = pd.DataFrame(R2_kf_all)
R2_kf_all_out.to_csv(
    folderpath + model + '_kalman_test_R2_for_model_comparison.csv', index=False, header=True)
