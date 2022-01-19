# -*- coding: utf-8 -*-
"""
Created on Mon Feb 22 09:58:02 2021.

@author: calebsponheim
"""
import ssm
import numpy as np

# import math

# npr.seed(100)


def train_HMM(
    data,
    trial_classification,
    meta,
    bin_size,
    is_it_breaux,
    max_state_range,
    state_skip,
    num_state_override
):

    # %%
    trind_train = [i for i, x in enumerate(trial_classification) if x == "train"]
    trind_select = [
        i for i, x in enumerate(trial_classification) if x == "model_select" or "test"
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

    for iUnit in range(len(trainset)):
        if iUnit == 0:
            bin_sums = trainset[iUnit]
        else:
            bin_sums = np.vstack((bin_sums, trainset[iUnit]))
        print(iUnit)
    for iUnit in range(len(selectset)):
        if iUnit == 0:
            bin_sums_select = selectset[iUnit]
        else:
            bin_sums_select = np.vstack((bin_sums_select, selectset[iUnit]))
        print(iUnit)
    # %% Okay NOW we train

    observation_dimensions = bin_sums.shape[0]
    bin_sums = bin_sums.astype(np.int64)
    hmm_storage = []
    select_ll = []

    if num_state_override > 0:
        N_iters = 100
        state_range = num_state_override
        hmm = ssm.HMM(
            num_state_override,
            observation_dimensions,
            observations="poisson",
            transitions="standard",
        )

        hmm.fit(
            np.transpose(bin_sums),
            method="em",
            num_iters=N_iters,
            init_method="random",
        )
        hmm_storage.append(hmm)

        # model selection decode
        select_ll.append(hmm.log_likelihood(np.transpose(bin_sums_select)))

        print(f"Created Model For {num_state_override} States.")
    else:
        N_iters = 20
        state_range = np.arange(1, max_state_range, state_skip)
        for iState in state_range:
            hmm = ssm.HMM(
                iState,
                observation_dimensions,
                observations="poisson",
                transitions="standard",
            )

            hmm.fit(
                np.transpose(bin_sums),
                method="em",
                num_iters=N_iters,
                init_method="random",
            )
            hmm_storage.append(hmm)

            # model selection decode
            select_ll.append(hmm.log_likelihood(np.transpose(bin_sums_select)))

            print(f"Created Model For {iState} States.")
        state_range = state_range.tolist()

    # %% Return variables
    return hmm_storage, select_ll, state_range
