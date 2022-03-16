# -*- coding: utf-8 -*-
"""
Created on Mon August 8th 2021.

@author: calebsponheim
"""


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

# from state_prob_over_time import state_prob_over_time


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
    latent_dim_state_range
):
    """
    Summary: Function is the main script for running rslds analysis.

    Returns.
    -------
    None. Writes out data to files.

    """
    # %%

    folderpath_base_base = "C:/Users/calebsponheim/Documents/git/intermittent_control_project/"
    # folderpath_base_base = "C:/Users/Caleb (Work)/Documents/git/intermittent_control_project/"
    folderpath_base = folderpath_base_base + "data/python_switching_models/"
    figurepath_base = folderpath_base_base + "figures/"

    if subject == "bx":
        if task == "CO":
            # folderpath = folderpath_base + "Bxcenter_out1902280.05sBins/"
            folderpath = (
                folderpath_base + "Bxcenter_out1902280.05_sBins_move_window_only/"
            )
            figurepath = figurepath_base + "Bx/CO/"
            # folderpath = folderpath_base + "Bxcenter_out_and_RTP1902280.05sBins/"
            # folderpath = folderpath_base + "Bxcenter_out1803230.05sBins/'
    elif subject == "rs":
        if task == "CO":
            folderpath = folderpath_base + "RSCO0.05sBins/"
            folderpath = folderpath_base + "RSCO_move_window0.05sBins/"
            figurepath = figurepath_base + "RS/CO_CT0_move_only/"

        elif task == "RTP":
            folderpath = folderpath_base + "RSRTP0.05sBins/"
            figurepath = figurepath_base + "RS/RTP_CT0/"
    elif subject == "rj":
        folderpath = folderpath_base + "RJRTP0.05sBins/"
        figurepath = figurepath_base + "RJ/RTP_CT0/"
    else:
        print("BAD, NO")

    class meta:
        def __init__(self, train_portion, model_select_portion, test_portion):
            self.train_portion = 0.5
            self.model_select_portion = 0.1
            self.test_portion = 0.4

    bin_size = 50  # in milliseconds
    meta = meta(train_portion, model_select_portion, test_portion)

    data, is_it_breaux = import_matlab_data(folderpath)

    # %%

    trial_classification = assign_trials_to_HMM_group(data, meta)

    # %% Running HMM to find optimal number of states using LL saturation

    hmm_storage, select_ll, state_range = train_HMM(
        data,
        trial_classification,
        meta,
        bin_size,
        is_it_breaux,
        hidden_max_state_range,
        hidden_state_skip,
        num_hidden_state_override
    )

    # %% Finding 90% cutoff

    # LL_curve_fitting(select_ll, state_range)

    # %% Running PCA-based estimate of # of latent dimensions

    # %% Running RSLDS
    model, xhat_lem, y, model_params = train_rslds(
        data, trial_classification, meta, bin_size,
        is_it_breaux, num_hidden_state_override, figurepath, rslds_ll_analysis,
        latent_dim_state_range
    )

    # %% Trying to Plot/Cluster Model/State Parameters

    # analyze_params(model_params)

    # %% literally making bin_sums for all trials for HMM decode

    if is_it_breaux == 0:
        bin_size = 1
    export_set = []
    for iTrial in range(len(trial_classification)):
        S_temp = data.spikes[iTrial]
        for iUnit in range(len(S_temp)):
            temp = S_temp[iUnit]
            temp_indices = np.arange(0, len(temp), bin_size)
            temp_binned = [temp[i] for i in temp_indices]
            if len(export_set) <= iUnit:
                export_set.append(temp_binned)
            else:
                export_set[iUnit].extend(temp_binned)
    # Okay now that we have the data in the right format, we need to put in an HMM-readable format.

    for iUnit in range(len(export_set)):
        if iUnit == 0:
            bin_sums = export_set[iUnit]
        else:
            bin_sums = np.vstack((bin_sums, export_set[iUnit]))
    # %% Getting test_and_train data

    # %%
    # trind_test = [
    #     i for i, x in enumerate(trial_classification) if x == "model_select" or "test"
    # ]
    # testset = []
    # # S = []
    # # trial_count = 1
    # for iTrial in range(len(trial_classification)):
    #     S_temp = data.spikes[iTrial]
    #     for iUnit in range(len(S_temp)):
    #         temp = S_temp[iUnit]
    #         if is_it_breaux == 1:
    #             temp_indices = np.arange(0, len(temp), bin_size)
    #         else:
    #             temp_indices = np.arange(0, len(temp), 1)
    #         temp_binned = [temp[i] for i in temp_indices]
    #         if iTrial in trind_test:
    #             if len(testset) <= iUnit:
    #                 testset.append(temp_binned)
    #             else:
    #                 testset[iUnit].extend(temp_binned)
    # # Okay now that we have the training trials in its own variable, we need
    # # to turn it into the right shape for training, presumably.

    # for iUnit in range(len(testset)):
    #     if iUnit == 0:
    #         test_data = testset[iUnit]
    #     else:
    #         test_data = np.vstack((test_data, testset[iUnit]))

    # trainset = []

    # for iTrial in range(len(trial_classification)):
    #     S_temp = data.spikes[iTrial]
    #     for iUnit in range(len(S_temp)):
    #         temp = S_temp[iUnit]
    #         if is_it_breaux == 1:
    #             temp_indices = np.arange(0, len(temp), bin_size)
    #         else:
    #             temp_indices = np.arange(0, len(temp), 1)
    #         temp_binned = [temp[i] for i in temp_indices]
    #         if len(trainset) <= iUnit:
    #             trainset.append(temp_binned)
    #         else:
    #             trainset[iUnit].extend(temp_binned)
    #     # print(iTrial)

    # # Okay now that we have the training trials in its own variable, we need
    # # to turn it into the right shape for training, presumably.

    # for iUnit in range(len(trainset)):
    #     if iUnit == 0:
    #         bin_sums = trainset[iUnit]
    #     else:
    #         bin_sums = np.vstack(
    #             (bin_sums, trainset[iUnit]))

    # # %% rSLDS likelihood calculation and state decoding
    # bin_sums = bin_sums.astype(int)

    # y = np.transpose(bin_sums)

    if rslds_ll_analysis == 0:
        decoded_data_rslds = model.most_likely_states(xhat_lem, y)
        rslds_likelihood = model.emissions.log_likelihoods(
            data=y, input=np.zeros([y.shape[0], 0]), mask=None, tag=[], x=xhat_lem)

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
    elif rslds_ll_analysis == 1:
        decoded_data_rslds = []
        rslds_likelihood = []
        for iLatentDim in np.arange(0, latent_dim_state_range.shape[0], 1):
            decoded_data_rslds.append(model[iLatentDim].most_likely_states(
                xhat_lem[iLatentDim], y))

            likelihood_temp = model[iLatentDim].emissions.log_likelihoods(
                data=y, input=np.zeros([y.shape[0], 0]), mask=None, tag=[], x=xhat_lem[iLatentDim])
            rslds_likelihood.append(likelihood_temp[:, 0])
    # %% HMM state decoding
    decoded_data_hmm = []
    for iState in range(len(hmm_storage)):
        decoded_data_hmm.append(
            hmm_storage[iState].most_likely_states(
                np.transpose(np.intc(bin_sums)))
        )

    # %% Plot State Probabilities

    # state_prob_over_time(model, xhat_lem, y, num_hidden_state_override, figurepath)

    # %% write data for matlab

    decoded_data_hmm_out = pd.DataFrame(decoded_data_hmm)
    decoded_data_hmm_out.to_csv(folderpath + "decoded_data_hmm.csv", index=False)

    decoded_data_rslds_out = pd.DataFrame(decoded_data_rslds)
    decoded_data_rslds_out.to_csv(
        folderpath + "decoded_data_rslds.csv", index=False)

    rslds_likelihood_out = pd.DataFrame(rslds_likelihood)
    rslds_likelihood_out.to_csv(
        folderpath + "rslds_likelihood.csv", index=False)

    with open(folderpath + "trial_classifiction.csv", "w", newline="") as f:
        write = csv.writer(f, delimiter=" ", quotechar="|",
                           quoting=csv.QUOTE_MINIMAL)
        for iTrial in range(len(trial_classification)):
            write.writerow(trial_classification[iTrial])

    select_ll = pd.DataFrame(select_ll)
    select_ll.to_csv(folderpath + "select_ll.csv", index=False)

    # with open(folderpath + "num_states.csv", "w") as f:
    #     write = csv.writer(f)
    #     write.writerow(state_range)

    if rslds_ll_analysis == 0:
        real_eigenvalues_out = pd.DataFrame(real_eigenvalues)
        real_eigenvalues_out.to_csv(folderpath + "real_eigenvalues.csv", index=False)
        imaginary_eigenvalues_out = pd.DataFrame(imaginary_eigenvalues)
        imaginary_eigenvalues_out.to_csv(folderpath + "imaginary_eigenvalues.csv", index=False)

        for iState in range(len(real_eigenvectors)):
            real_eigenvectors_out = pd.DataFrame(real_eigenvectors[iState])
            real_eigenvectors_out.to_csv(folderpath + "real_eigenvectors_state_" +
                                         str(iState) + ".csv", index=False)
            imaginary_eigenvectors_out = pd.DataFrame(imaginary_eigenvectors[iState])
            imaginary_eigenvectors_out.to_csv(folderpath + "imaginary_eigenvectors_state_" +
                                              str(iState) + ".csv", index=False)

    # %%
    return model, xhat_lem, y, model_params, real_eigenvalues_out, imaginary_eigenvalues_out
