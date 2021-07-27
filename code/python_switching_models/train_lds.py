# -*- coding: utf-8 -*-
"""
Created on Mon July 26th 09:58:02 2021

@author: calebsponheim
"""
import matplotlib.pyplot as plt
from ssm import LDS
import numpy as np
import autograd.numpy.random as npr
npr.seed(100)
import seaborn as sns

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
    number_of_states = 2
    bin_sums = bin_sums.astype(int)

    hmm_storage = []
    hmm_lls_storage = []
    hmm_lls_max = []
    select_ll = []
    train_ll = []
    AIC = []
    y = np.transpose(bin_sums);
    
    lds = LDS(observation_dimensions, number_of_states, emissions="poisson")
    lds.initialize(y)
    
    #%% fit
    
    q_lem_elbos, q_lem = lds.fit(y, method="laplace_em", variational_posterior="structured_meanfield",
                                 num_iters=10, initialize=False)
    
    # Get the posterior mean of the continuous states
    q_lem_x = q_lem.mean_continuous_states[0]
    # Smooth the data under the variational posterior
    q_lem_y = lds.smooth(q_lem_x, y)


    # %% Plotting
    sns.set_style("white")
    sns.set_context("talk")
    
    color_names = ["windows blue",
               "red",
               "amber",
               "faded green",
               "dusty purple",
               "orange",
               "clay",
               "pink",
               "greyish",
               "mint",
               "light cyan",
               "steel blue",
               "forest green",
               "pastel purple",
               "salmon",
               "dark brown"]
    colors = sns.xkcd_palette(color_names)

    plt.figure()
    plt.plot(q_lem_elbos, label="LDS")
    plt.xlabel("Iteration")
    plt.ylabel("ELBO")
    plt.legend()


    plt.figure(figsize=(8,4))
    for d in range(number_of_states):
        plt.plot(q_lem_x[:,d] + 4 * d, '--', color=colors[2], label="Laplace-EM" if d==0 else None)
    plt.ylabel("$x$")
    plt.xlim((0,200))



    # Plot the smoothed observations
    plt.figure(figsize=(20,100))
    for n in range(observation_dimensions):
        plt.plot(y[:, n] + 4 * n, '-k', label="True" if n == 0 else None)
        plt.plot(q_lem_y[:, n] + 4 * n, '--',  color=colors[2], label="Laplace-EM" if n == 0 else None)
    plt.xlabel("time")
    plt.xlim((0,100))

    # %%
    return hmm_storage, hmm_lls_storage, bin_sums, bin_sums_select, optimal_state_number