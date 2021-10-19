# -*- coding: utf-8 -*-
"""
Created on Mon Feb 22 09:58:02 2021.

@author: calebsponheim
"""
import matplotlib.pyplot as plt
import ssm
import numpy as np
import autograd.numpy.random as npr
import math

npr.seed(100)


def train_HMM(
    data, trial_classification, meta, bin_size, is_it_breaux, max_state_range
):

    # %%
    trind_train = [i for i, x in enumerate(trial_classification) if x == "train"]
    trind_select = [
        i for i, x in enumerate(trial_classification) if x == "model_select"
    ]
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

    # Okay now that we have the training trials in its own variable, we need
    # to turn it into the right shape for training, presumably.

    mean_spikecount = []

    for iUnit in range(len(trainset)):
        if iUnit == 0:
            bin_sums = trainset[iUnit]
        else:
            bin_sums = np.vstack((bin_sums, trainset[iUnit]))
        print(iUnit)

    for iUnit in range(len(selectset)):
        if iUnit == 0:
            bin_sums_select = selectset[iUnit]
            mean_spikecount.append(sum(selectset[iUnit]) / len(selectset[iUnit]))
        else:
            bin_sums_select = np.vstack((bin_sums_select, selectset[iUnit]))
            mean_spikecount.append(sum(selectset[iUnit]) / len(selectset[iUnit]))
        print(iUnit)

    # %% Calculate Maximum Possible Log Likelihood
    per_neuron_likelihood = []
    for iUnit in range(len(selectset)):
        per_timestep_likelihood = []
        mean_spikecount_temp = mean_spikecount[iUnit]
        first_term = mean_spikecount_temp
        second_term = []
        third_term = []

        for iTimestep in range(len(selectset[iUnit])):
            timestep_temp = selectset[iUnit][iTimestep]
            second_term.append((timestep_temp) * math.log(mean_spikecount_temp))
            third_term.append(math.log(math.factorial(timestep_temp)))

        per_timestep_likelihood.append(-first_term + sum(second_term) - sum(third_term))

        per_neuron_likelihood.append(sum(per_timestep_likelihood))

    max_log_likelihood_possible = sum(per_neuron_likelihood)
    ninety_percent_threshold = max_log_likelihood_possible + (max_log_likelihood_possible*.1)

    # %% Okay NOW we train

    observation_dimensions = bin_sums.shape[0]
    N_iters = 10
    state_range = [1, 100]
    # state_range = np.arange(1, max_state_range, 10)
    bin_sums = bin_sums.astype(np.int64)

    hmm_storage = []
    hmm_lls_storage = []
    hmm_lls_max = []
    select_ll = []
    train_ll = []
    select_likelihood = []
    for iState in state_range:
        hmm = ssm.HMM(iState, observation_dimensions, observations="poisson")
        # hmm_storage.append(hmm)
        hmm.fit(
            np.transpose(bin_sums), method="em", num_iters=N_iters, init_method="kmeans"
        )
        # hmm_lls_storage.append(hmm_lls)
        # hmm_lls_max.append(max(hmm_lls))

        # model selection decode
        select_ll_temp = hmm.log_likelihood(np.transpose(bin_sums_select))
        select_ll.append(select_ll_temp)
        select_likelihood.append(math.exp(select_ll_temp))
        # trainset decode
        train_ll_temp = hmm.log_likelihood(np.transpose(bin_sums))
        train_ll.append(train_ll_temp)
        print(f"Created Model For {iState} States.")

    plt.plot(state_range, np.transpose(select_ll), linestyle="-", marker="o")
    plt.axhline(y=max_log_likelihood_possible, color="r", linestyle="-")
    plt.axhline(y=ninety_percent_threshold, color="b", linestyle="-")
    plt.xlabel("state number")
    plt.title("Model-Select Log Likelihood over state number")
    plt.ylabel("Log Probability")
    plt.show()

    # %% Determine Optimal State using "model classification" trials

    optimal_state_number = 0

    # %% Return variables
    return hmm_storage, optimal_state_number
