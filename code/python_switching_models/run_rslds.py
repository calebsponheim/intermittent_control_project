# -*- coding: utf-8 -*-
"""
Created on Mon August 8th 2021.

@author: calebsponheim
"""

import os
import csv
from import_matlab_data import import_matlab_data
from assign_trials_to_HMM_group import assign_trials_to_HMM_group
import pandas as pd

from train_rslds import train_rslds
# from analyze_params import analyze_params
from train_HMM import train_HMM
# from LL_curve_fitting import LL_curve_fitting
import numpy as np
from numpy.linalg import eig
from rslds_cosmoothing import rslds_cosmoothing
# from plot_continuous_states import plot_continuous_states
# from state_prob_over_time import state_prob_over_time
# import autograd.numpy.random as npr


def run_rslds(
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
    fold_number
):
    """
    Summary: Function is the main script for running rslds analysis.

    Returns.
    -------
    None. Writes out data to files.

    """
    # %%
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
    elif subject == "bx18":
        folderpath = folderpath_base + "Bxcenter_out1803230.05sBins/"
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
    if str(num_hidden_state_override) + "_states_" + str(latent_dim_state_range) + "_dims" not in temp_folderlist:
        os.mkdir(folderpath + str(num_hidden_state_override) +
                 "_states_" + str(latent_dim_state_range) + "_dims/")
    if str(num_hidden_state_override) + "_states_" + str(latent_dim_state_range) + "_dims" not in temp_figurelist:
        os.mkdir(figurepath + str(num_hidden_state_override) +
                 "_states_" + str(latent_dim_state_range) + "_dims/")

    folderpath_out = folderpath + str(num_hidden_state_override) + \
        "_states_" + str(latent_dim_state_range) + "_dims/"
    figurepath = figurepath + str(num_hidden_state_override) + \
        "_states_" + str(latent_dim_state_range) + "_dims/"

    class meta:
        def __init__(self, train_portion, model_select_portion, test_portion):
            self.train_portion = train_portion
            self.model_select_portion = model_select_portion
            self.test_portion = test_portion

    bin_size = 50  # in milliseconds
    meta = meta(train_portion, model_select_portion, test_portion)

    data = import_matlab_data(folderpath)

    # %%

    trial_classification, neuron_classification = assign_trials_to_HMM_group(
        data, meta, midway_run, fold_number, folderpath_out)

    # %% Running HMM
    if midway_run == 0:
        hmm_storage, select_ll, state_range = train_HMM(
            data,
            trial_classification,
            meta,
            bin_size,
            hidden_max_state_range,
            hidden_state_skip,
            num_hidden_state_override
        )

    # %% Running Co-Smoothing
    # 1. Set up file directory and folder structure for given log_likelihood files
        #  1a. bring in datapath
        #  1b. see if co-smoothing data folder already exists
        # 1bi. if doesn't exist, make it
        # 1c. see if fold number exists
    # 2. calculate log-likelihood based on held-out test data

    if midway_run == 1:
        log_likelihood_emissions_sum = rslds_cosmoothing(data, trial_classification, meta, bin_size,
                                                         num_hidden_state_override, figurepath,
                                                         rslds_ll_analysis, latent_dim_state_range,
                                                         neuron_classification)
        # test_bits_sum = pd.DataFrame(test_bits_sum)
        # latent_dims = pd.DataFrame([latent_dim_state_range])
        # frames = [test_bits_sum, latent_dims]
        # test_bits_sum = pd.concat(frames, axis=1)
        # first_file = 1
        # for file in os.listdir(folderpath_out):
        #     if file.endswith(str(num_hidden_state_override) + "_states_test_bits.csv"):
        #         first_file = 0

        # if first_file == 1:
        #     test_bits_sum.to_csv(folderpath_out + str(num_hidden_state_override) +
        #                          "_states_test_bits.csv", index=False, header=False)
        # elif first_file == 0:
        #     test_bits_sum.to_csv(folderpath_out + str(num_hidden_state_override) +
        #                          "_states_test_bits.csv", mode='a', index=False, header=False)

        #############
        # Emissions
        #############
        # log_likelihood_emissions_sum = sum(log_likelihood_emissions_sum)
        log_likelihood_emissions_sum = pd.DataFrame([log_likelihood_emissions_sum])
        latent_dims = pd.DataFrame([latent_dim_state_range])
        frames = [log_likelihood_emissions_sum, latent_dims]
        log_likelihood_emissions_sum = pd.concat(frames, axis=1)

        if fold_number == 1:
            log_likelihood_emissions_sum.to_csv(folderpath_out + str(num_hidden_state_override) +
                                                "_states_test_emissions_ll.csv", index=False, header=False)
        elif fold_number > 1:
            log_likelihood_emissions_sum.to_csv(folderpath_out + str(num_hidden_state_override) +
                                                "_states_test_emissions_ll.csv", mode='a', index=False, header=False)

    # %% Running RSLDS
    if midway_run == 0:
        model, xhat_lem, fullset, model_params = train_rslds(
            data, trial_classification, meta, bin_size,
            num_hidden_state_override, figurepath, rslds_ll_analysis,
            latent_dim_state_range
        )

        # %%

        decoded_data_rslds = []

        for iTrial in range(len(fullset)):
            decoded_data_rslds.append(model.most_likely_states(xhat_lem[iTrial], fullset[iTrial]))

        # rslds_likelihood = model.emissions.log_likelihoods(
        #     data=y, input=np.zeros([y[0].shape[0], 0]), mask=None, tag=[], x=xhat_lem)

        real_eigenvalues = []
        imaginary_eigenvalues = []
        real_eigenvectors = []
        imaginary_eigenvectors = []
        for iLatentDim in np.arange(model.dynamics.As.shape[0]):
            eigenvalues_temp, eigenvectors_temp = eig(model.dynamics.As[iLatentDim, :, :])

            real_eigenvalues.append(np.around(eigenvalues_temp.real, 3))
            imaginary_eigenvalues.append(np.around(eigenvalues_temp.imag, 3))
            real_eigenvectors.append(np.around(eigenvectors_temp.real, 3))
            imaginary_eigenvectors.append(np.around(eigenvectors_temp.imag, 3))
        # %% HMM state decoding

        decoded_data_hmm = []
        for iTrial in range(len(fullset)):
            decoded_data_hmm.append(hmm_storage[0].most_likely_states(fullset[iTrial]))

        # %%

        # plot_continuous_states(xhat_lem, latent_dim_state_range, decoded_data_rslds)
        # %% Plot State Probabilities

        # state_prob_over_time(model, xhat_lem, y, num_hidden_state_override, figurepath)

        # %% write data for matlab

        decoded_data_hmm_out = pd.DataFrame(decoded_data_hmm)
        decoded_data_hmm_out.to_csv(folderpath_out + "decoded_data_hmm.csv", index=False)

        decoded_data_rslds_out = pd.DataFrame(decoded_data_rslds)
        decoded_data_rslds_out.to_csv(
            folderpath_out + "decoded_data_rslds.csv", index=False)

        with open(folderpath_out + "trial_classifiction.csv", "w", newline="") as f:
            write = csv.writer(f, delimiter=" ", quotechar="|",
                               quoting=csv.QUOTE_MINIMAL)
            for iTrial in range(len(trial_classification)):
                write.writerow(trial_classification[iTrial])

        for iTrial in range(len(xhat_lem)):
            continuous_states_temp = pd.DataFrame(xhat_lem[iTrial])
            continuous_states_temp.to_csv(folderpath_out + "continuous_states_trial_" +
                                          str(iTrial+1) + ".csv", index=False, header=False)

        real_eigenvalues_out = pd.DataFrame(real_eigenvalues)
        real_eigenvalues_out.to_csv(folderpath_out + "real_eigenvalues.csv", index=False)
        imaginary_eigenvalues_out = pd.DataFrame(imaginary_eigenvalues)
        imaginary_eigenvalues_out.to_csv(folderpath_out + "imaginary_eigenvalues.csv", index=False)

        for iState in range(len(real_eigenvectors)):
            real_eigenvectors_out = pd.DataFrame(real_eigenvectors[iState])
            real_eigenvectors_out.to_csv(folderpath_out + "real_eigenvectors_state_" +
                                         str(iState+1) + ".csv", index=False)
            imaginary_eigenvectors_out = pd.DataFrame(imaginary_eigenvectors[iState])
            imaginary_eigenvectors_out.to_csv(folderpath_out + "imaginary_eigenvectors_state_" +
                                              str(iState+1) + ".csv", index=False)

        # %%
    if midway_run == 0:
        return model, xhat_lem, fullset, model_params, real_eigenvectors_out, imaginary_eigenvectors_out, real_eigenvalues_out, imaginary_eigenvalues_out
