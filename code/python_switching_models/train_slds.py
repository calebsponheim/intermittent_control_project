# -*- coding: utf-8 -*-
"""
Created on Mon July 26th 09:58:02 2021.

@author: calebsponheim
"""
import matplotlib.pyplot as plt
import ssm
import numpy as np
import autograd.numpy.random as npr
import seaborn as sns
npr.seed(100)


def train_slds(data, trial_classification, meta, bin_size, is_it_breaux):
    """Train a Switching Linear Dynamical System."""
    # %%
    # trind_train = [i for i, x in enumerate(
    #     trial_classification) if x == "train"]
    # trind_select = [i for i, x in enumerate(
    #     trial_classification) if x == "model_select"]
    # trainset = []
    # selectset = []
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
    #         if iTrial in trind_train:
    #             if len(trainset) <= iUnit:
    #                 trainset.append(temp_binned)
    #             else:
    #                 trainset[iUnit].extend(temp_binned)
    #         elif iTrial in trind_select:
    #             if len(selectset) <= iUnit:
    #                 selectset.append(temp_binned)
    #             else:
    #                 selectset[iUnit].extend(temp_binned)

    # # Okay now that we have the training trials in its own variable, we need
    # to turn it into the right shape for training, presumably.

    # for iUnit in range(len(trainset)):
    #     if iUnit == 0:
    #        bin_sums = trainset[iUnit]
    #     else:
    #         bin_sums = np.vstack(
    #             (bin_sums, trainset[iUnit]))
    #     print(iUnit)

    # for iUnit in range(len(selectset)):
    #     if iUnit == 0:
    #         bin_sums_select = selectset[iUnit]
    #     else:
    #         bin_sums_select = np.vstack(
    #             (bin_sums_select, selectset[iUnit]))
    #     print(iUnit)

    # %% Making a bin_sums that's all trials, because idk how to do cross
    # validation with this method yet

    trainset = []

    for iTrial in range(len(trial_classification)):
        S_temp = data.spikes[iTrial]
        for iUnit in range(len(S_temp)):
            temp = S_temp[iUnit]
            if is_it_breaux == 1:
                temp_indices = np.arange(0, len(temp), bin_size)
            else:
                temp_indices = np.arange(0, len(temp), 1)
            temp_binned = [temp[i] for i in temp_indices]
            if len(trainset) <= iUnit:
                trainset.append(temp_binned)
            else:
                trainset[iUnit].extend(temp_binned)
        print(iTrial)

    # Okay now that we have the training trials in its own variable, we need
    # to turn it into the right shape for training, presumably.

    for iUnit in range(len(trainset)):
        if iUnit == 0:
            bin_sums = trainset[iUnit]
        else:
            bin_sums = np.vstack(
                (bin_sums, trainset[iUnit]))
        print(iUnit)

    # %% Okay NOW we train

    # time_bins = bin_sums.shape[1]
    observation_dimensions = bin_sums.shape[0]
    number_of_states = 8
    bin_sums = bin_sums.astype(int)

    y = np.transpose(bin_sums)

    sns.set_style("white")
    sns.set_context("talk")

    # Set the parameters of the HMM
    K = number_of_states       # number of discrete states
    D = 2       # number of latent dimensions
    N = observation_dimensions      # number of observed dimensions
    # %% Train

    print("Fitting SLDS with Laplace-EM")
    slds = ssm.SLDS(N, K, D, emissions="poisson")
    slds.initialize(y)
    q_lem_elbos, q_laplace_em = slds.fit(y, method="laplace_em",
                                         variational_posterior="structured_meanfield",
                                         initialize=False, num_iters=10)
    q_lem_Ez, q_lem_x = q_laplace_em.mean[0]
    # q_lem_y = slds.smooth(q_lem_x, y)

    # %% Plotting

    plt.figure(figsize=(16, 4))
    for d in range(D):
        plt.plot(q_lem_x[:, d] + 4 * d, '-',
                 label="Laplace-EM" if d == 0 else None)
    plt.ylabel("$x$")
    plt.xlim((0, 400))

    # Plot the ELBOS
    plt.figure()
    plt.plot(q_lem_elbos, label="Laplace EM")
    plt.xlabel("Iteration")
    plt.ylabel("ELBO")
    plt.legend()
    plt.tight_layout()

    # Plot the true and inferred states
    plt.figure(figsize=(25, 4))
    xlim = (0, 200)

    plt.imshow(q_lem_Ez[0].T, aspect="auto", cmap="Greys")
    plt.xlim(xlim)
    plt.title("Inferred State Probability")

    plt.show()

    # %%
    return slds, q_lem_x
