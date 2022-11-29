# -*- coding: utf-8 -*-
"""
Created on Mon Nov 21 09:45:48 2022

@author: caleb_work
"""


import os


def decode_kinematics_from_latents(kinpath, latentpath, model):

    import pandas as pd
    import numpy as np
    from os import listdir
    from os.path import isfile, join
    import Neural_Decoding
    import matplotlib.pyplot as plt
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
    x_by_trial = []
    y_by_trial = []
    x_velocity_by_trial = []
    y_velocity_by_trial = []
    speed_by_trial = []
    full_kinematics_by_trial = []
    for iFile in kinfiles:
        kinematics = pd.DataFrame.to_numpy(pd.read_csv(folderpath + iFile))
        x_by_trial.append(kinematics[:, 0])
        y_by_trial.append(kinematics[:, 1])
        x_velocity_by_trial.append(kinematics[:, 2])
        y_velocity_by_trial.append(kinematics[:, 3])
        speed_by_trial.append(kinematics[:, 4])
        full_kinematics_by_trial.append(kinematics)
        file_count += 1
        if file_count % 100 == 0:
            print(f"Processed Kinematics from trial {file_count}")

    # Bin Kinematics
    full_kinematics_binned = []
    for iTrial in np.arange(len(full_kinematics_by_trial)):
        vels = np.asarray(full_kinematics_by_trial[iTrial])
        vel_times = np.arange(len(x_by_trial[iTrial]))/1000
        dt = .05
        t_start = 0
        t_end = len(x_by_trial[iTrial])/1000
        downsample_factor = 1
        full_kinematics_binned.append(Neural_Decoding.bin_output(
            vels, vel_times, dt, t_start, t_end, downsample_factor))

    # Load Latents
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
        latents_by_trial.append(latents)
        file_count += 1
        if file_count % 100 == 0:
            print(f"Processed Latents from trial {file_count}")

    # %% Decoding
    training_range = [0, 0.7]
    testing_range = [0.7, 0.85]
    valid_range = [0.85, 1]
    y_valid_predicted_kf_all = []
    R2_kf = np.zeros([len(full_kinematics_by_trial), 5])
    for iTrial in np.arange(len(full_kinematics_by_trial)):
        lag = 0
        X_kf = latents_by_trial[iTrial]
        y_kf = full_kinematics_binned[iTrial]

        # Number of examples after taking into account bins removed for lag alignment
        num_examples_kf = X_kf.shape[0]

        # Note that each range has a buffer of 1 bin at the beginning and end
        # This makes it so that the different sets don't include overlapping data
        training_set = np.arange(int(np.round(
            training_range[0]*num_examples_kf))+1, int(np.round(training_range[1]*num_examples_kf))-1)
        testing_set = np.arange(int(
            np.round(testing_range[0]*num_examples_kf))+1, int(np.round(testing_range[1]*num_examples_kf))-1)
        valid_set = np.arange(int(
            np.round(valid_range[0]*num_examples_kf))+1, int(np.round(valid_range[1]*num_examples_kf))-1)

        # Get training data
        X_kf_train = X_kf[training_set, :]
        y_kf_train = y_kf[training_set, :]

        # Get testing data
        X_kf_test = X_kf[testing_set, :]
        y_kf_test = y_kf[testing_set, :]

        # Get validation data
        X_kf_valid = X_kf[valid_set, :]
        y_kf_valid = y_kf[valid_set, :]

        # Z-score inputs
        X_kf_train_mean = np.nanmean(X_kf_train, axis=0)
        X_kf_train_std = np.nanstd(X_kf_train, axis=0)
        X_kf_train = (X_kf_train-X_kf_train_mean)/X_kf_train_std
        X_kf_test = (X_kf_test-X_kf_train_mean)/X_kf_train_std
        X_kf_valid = (X_kf_valid-X_kf_train_mean)/X_kf_train_std

        # Zero-center outputs
        y_kf_train_mean = np.mean(y_kf_train, axis=0)
        y_kf_train = y_kf_train-y_kf_train_mean
        y_kf_test = y_kf_test-y_kf_train_mean
        y_kf_valid = y_kf_valid-y_kf_train_mean

        # Declare model
        # There is one optional parameter that is set to the default in this example (see ReadMe)
        model_kf = Neural_Decoding.KalmanFilterDecoder(C=1)

        # Fit model
        model_kf.fit(X_kf_train, y_kf_train)

        # Get predictions
        y_valid_predicted_kf = model_kf.predict(X_kf_valid, y_kf_valid)
        y_valid_predicted_kf_all.append(y_valid_predicted_kf)
        # Get metrics of fit (see read me for more details on the differences between metrics)
        # First I'll get the R^2
        R2_kf[iTrial, :] = Neural_Decoding.get_R2(y_kf_valid, y_valid_predicted_kf)
        # I'm just printing the R^2's of the 3rd and 4th entries that correspond to the velocities
        # Next I'll get the rho^2 (the pearson correlation squared)
        # rho_kf = Neural_Decoding.get_rho(y_kf_valid, y_valid_predicted_kf)
        # I'm just printing the rho^2's of the 3rd and 4th entries that correspond to the velocities

        # As an example, I plot an example 1000 values of the x velocity (column index 2), both true and predicted with the Kalman filter
        # Note that I add back in the mean value, so that both true and predicted values are in the original coordinates
        if (iTrial % 100) == 0:
            fig_x_kf = plt.figure()
            plt.plot(y_kf_valid[:, 0]+y_kf_train_mean[0], y_kf_valid[:, 1]+y_kf_train_mean[1], 'b')
            plt.plot(y_valid_predicted_kf[:, 0]+y_kf_train_mean[0],
                     y_valid_predicted_kf[:, 1]+y_kf_train_mean[1], 'r')
        # Save figure
        # fig_x_kf.savefig('x_velocity_decoding.eps')
    return R2_kf, y_valid_predicted_kf_all


# %% Parameter Setting

num_latent_dims_rslds = 25
num_discrete_states_rslds = 10
num_latent_dims_slds = 2
num_discrete_states_slds = 2
num_latent_dims_lds = 2
num_discrete_states_hmm = 2
subject = 'rs'
task = 'RTP'
model = 'rslds'

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
    latentpath = (folderpath + str(num_discrete_states_rslds) +
                  "_states_" + str(num_latent_dims_rslds) + "_dims/")

kinpath = folderpath

R2_kf, y_valid_predicted_kf_all = decode_kinematics_from_latents(kinpath, latentpath, model)
