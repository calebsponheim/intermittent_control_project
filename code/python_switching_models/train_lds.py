# -*- coding: utf-8 -*-
"""
Created on Mon July 26th 09:58:02 2021

@author: calebsponheim
"""
import matplotlib.pyplot as plt
import ssm
import numpy as np
import autograd.numpy.random as npr
npr.seed(100)


def train_lds(data, trial_classification, meta, bin_size, is_it_breaux):

    # %%
    trind_train = [i for i, x in enumerate(
        trial_classification) if x == "train"]
    trind_select = [i for i, x in enumerate(
        trial_classification) if x == "model_select"]
    trainset = []
    selectset = []
    # S = []
    # trial_count = 1
    for iTrial in range(len(trial_classification)):
        S_temp = data.spikes[iTrial]
        for iUnit in range(len(S_temp)):
            temp = S_temp[iUnit]
            if is_it_breaux == 1:
                temp_indices = np.arange(0, len(temp), bin_size)
            else:
                temp_indices = np.arange(0, len(temp), 1)
            temp_binned = [temp[i] for i in temp_indices]
            if iTrial in trind_train:
                if len(trainset) <= iUnit:
                    trainset.append(temp_binned)
                else:
                    trainset[iUnit].extend(temp_binned)
            elif iTrial in trind_select:
                if len(selectset) <= iUnit:
                    selectset.append(temp_binned)
                else:
                    selectset[iUnit].extend(temp_binned)

    # Okay now that we have the training trials in its own variable, we need to turn it into the right shape for training, presumably.

    for iUnit in range(len(trainset)):
        if iUnit == 0:
            bin_sums = trainset[iUnit]
        else:
            bin_sums = np.vstack(
                (bin_sums, trainset[iUnit]))
        print(iUnit)
        
    for iUnit in range(len(selectset)):
        if iUnit == 0:
            bin_sums_select = selectset[iUnit]
        else:
            bin_sums_select = np.vstack(
                (bin_sums_select, selectset[iUnit]))
        print(iUnit)

    # %% Okay NOW we train

    # time_bins = bin_sums.shape[1]
    observation_dimensions = bin_sums.shape[0]
    N_iters = 100
    state_range = np.arange(2, 30, 1)
    # state_range = np.arange(1,5)
    bin_sums = bin_sums.astype(np.int64)

    hmm_storage = []
    hmm_lls_storage = []
    hmm_lls_max = []
    select_ll = []
    train_ll = []
    AIC = []
    


    return hmm_storage, hmm_lls_storage, bin_sums, bin_sums_select, optimal_state_number