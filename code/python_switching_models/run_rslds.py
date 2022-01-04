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
from analyze_params import analyze_params
from train_HMM import train_HMM
# from LL_curve_fitting import LL_curve_fitting
import numpy as np

from state_prob_over_time import state_prob_over_time


def run_rslds(
    subject,
    task,
    train_portion,
    model_select_portion,
    test_portion,
    max_state_range,
    state_skip,
    num_state_override
):
    """
    Is this a summary line?

    Parameters
    ----------
    subject : TYPE
        DESCRIPTION.
    task : TYPE
        DESCRIPTION.
    train_portion : TYPE
        DESCRIPTION.
    model_select_portion : TYPE
        DESCRIPTION.
    test_portion : TYPE
        DESCRIPTION.
    max_state_range : TYPE
        DESCRIPTION.
    state_skip : TYPE
        DESCRIPTION.

    Returns
    -------
    None. Writes out data to files.

    """
    # %%

    # folderpath_base = "C:/Users/calebsponheim/Documents/git/intermittent_control_project/data/python_switching_models/"
    folderpath_base = "C:/Users/Caleb (Work)/Documents/git/intermittent_control_project/data/python_switching_models/"

    if subject == "bx":
        if task == "CO":
            # folderpath = folderpath_base + "Bxcenter_out1902280.05sBins/"
            folderpath = (
                folderpath_base + "Bxcenter_out1902280.05_sBins_move_window_only/"
            )
            # folderpath = folderpath_base + "Bxcenter_out_and_RTP1902280.05sBins/"
            # folderpath = folderpath_base + "Bxcenter_out1803230.05sBins/'
    elif subject == "rs":
        if task == "CO":
            folderpath = folderpath_base + "RSCO0.05sBins/"
            folderpath = folderpath_base + "RSCO_move_window0.05sBins/"
        elif task == "RTP":
            folderpath = folderpath_base + "RSRTP0.05sBins/"
    elif subject == "rj":
        folderpath = folderpath_base + "RJRTP0.05sBins/"
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
        max_state_range,
        state_skip,
        num_state_override
    )

    # %% Finding 90% cutoff

    # LL_curve_fitting(select_ll, state_range)

    # %% Running PCA-based estimate of # of latent dimensions

    # %% Running RSLDS
    rslds_lem, xhat_lem, y, model_params = train_rslds(
        data, trial_classification, meta, bin_size, is_it_breaux, num_state_override
    )

    # %% Trying to Plot/Cluster Model/State Parameters

    analyze_params(model_params)

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
    # %% Decoding Test Data using Optimal States
    decoded_data_rslds = rslds_lem.most_likely_states(xhat_lem, y)

    decoded_data_hmm = []
    for iState in range(len(hmm_storage)):
        decoded_data_hmm.append(
            hmm_storage[iState].most_likely_states(
                np.transpose(np.intc(bin_sums)))
        )
    # %% Plot State Probabilities

    state_prob_over_time(rslds_lem, xhat_lem, y, num_state_override)

    # %% write data for matlab

    decoded_data_hmm = pd.DataFrame(decoded_data_hmm)
    decoded_data_hmm.to_csv(folderpath + "decoded_data_hmm.csv", index=False)

    decoded_data_rslds = pd.DataFrame(decoded_data_rslds)
    decoded_data_rslds.to_csv(
        folderpath + "decoded_data_rslds.csv", index=False)

    with open(folderpath + "trial_classifiction.csv", "w", newline="") as f:
        write = csv.writer(f, delimiter=" ", quotechar="|",
                           quoting=csv.QUOTE_MINIMAL)
        for iTrial in range(len(trial_classification)):
            write.writerow(trial_classification[iTrial])

    with open(folderpath + "num_states.csv", "w") as f:
        write = csv.writer(f)
        write.writerow(state_range)

    select_ll = pd.DataFrame(select_ll)
    select_ll.to_csv(folderpath + "select_ll.csv", index=False)
