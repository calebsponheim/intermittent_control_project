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
from plot_continuous_states import plot_continuous_states
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
    latent_dim_state_range,
    multiple_folds,
    midway_run
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
            figurepath = figurepath_base + "Bx/CO/"
        elif task == "CO+RTP":
            folderpath = folderpath_base + "Bxcenter_out_and_RTP1902280.05sBins/"
            figurepath = figurepath_base + "Bx/CO+RTP/"
    elif subject == "bx18":
        folderpath = folderpath_base + "Bxcenter_out1803230.05sBins/"
        figurepath = figurepath_base + "Bx/CO18_CT0/"
    elif subject == "rs":
        if task == "CO":
            # folderpath = folderpath_base + "RSCO0.05sBins/"
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
            self.train_portion = train_portion
            self.model_select_portion = model_select_portion
            self.test_portion = test_portion

    bin_size = 50  # in milliseconds
    meta = meta(train_portion, model_select_portion, test_portion)

    data, is_it_breaux = import_matlab_data(folderpath)

    # %%

    trial_classification = assign_trials_to_HMM_group(data, meta)

    # %% Running HMM to find optimal number of states using LL saturation
    if midway_run == 0:
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

    # %% Trying to Plot/Cluster Model/State Parameters

    # analyze_params(model_params)

    # %% Running Co-Smoothing

    if rslds_ll_analysis == 1:
        lls = rslds_cosmoothing(data, trial_classification, meta, bin_size,
                                is_it_breaux, num_hidden_state_override, figurepath,
                                rslds_ll_analysis, latent_dim_state_range)
        if multiple_folds == 1:
            num_prev_files = 0
            for file in os.listdir(folderpath):
                if file.startswith("lls"):
                    num_prev_files = num_prev_files + 1

            lls = pd.DataFrame(lls)
            lls.to_csv(folderpath + "lls_" +
                       str(num_prev_files + 1) + ".csv", index=False)

        else:
            lls = pd.DataFrame(lls)
            lls.to_csv(folderpath + str(num_hidden_state_override) + "_states_"+ str(latent_dim_state_range) + "_dims_lls.csv", index=False)

    # %% Running RSLDS
    if midway_run == 0:
        model, xhat_lem, fullset, model_params = train_rslds(
            data, trial_classification, meta, bin_size,
            is_it_breaux, num_hidden_state_override, figurepath, rslds_ll_analysis,
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

        plot_continuous_states(xhat_lem, latent_dim_state_range, decoded_data_rslds)
        # %% Plot State Probabilities

        # state_prob_over_time(model, xhat_lem, y, num_hidden_state_override, figurepath)

        # %% write data for matlab

        decoded_data_hmm_out = pd.DataFrame(decoded_data_hmm)
        decoded_data_hmm_out.to_csv(folderpath + "decoded_data_hmm.csv", index=False)

        decoded_data_rslds_out = pd.DataFrame(decoded_data_rslds)
        decoded_data_rslds_out.to_csv(
            folderpath + "decoded_data_rslds.csv", index=False)

        # rslds_likelihood_out = pd.DataFrame(rslds_likelihood)
        # rslds_likelihood_out.to_csv(
        #     folderpath + "rslds_likelihood.csv", index=False)

        with open(folderpath + "trial_classifiction.csv", "w", newline="") as f:
            write = csv.writer(f, delimiter=" ", quotechar="|",
                               quoting=csv.QUOTE_MINIMAL)
            for iTrial in range(len(trial_classification)):
                write.writerow(trial_classification[iTrial])

        # select_ll = pd.DataFrame(select_ll)
        # select_ll.to_csv(folderpath + "select_ll.csv", index=False)

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
                                             str(iState+1) + ".csv", index=False)
                imaginary_eigenvectors_out = pd.DataFrame(imaginary_eigenvectors[iState])
                imaginary_eigenvectors_out.to_csv(folderpath + "imaginary_eigenvectors_state_" +
                                                  str(iState+1) + ".csv", index=False)

        # %%
        return model, xhat_lem, fullset, model_params, real_eigenvectors_out, imaginary_eigenvectors_out, real_eigenvalues_out, imaginary_eigenvalues_out
