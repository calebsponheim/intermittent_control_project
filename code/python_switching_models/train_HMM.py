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
    num_hidden_state_override
):

    # %%
    trind_train = [i for i, x in enumerate(trial_classification) if x == "train"]
    trind_select = [i for i, x in enumerate(trial_classification) if x == "test"]
    trind_select.extend([i for i, x in enumerate(trial_classification) if x == "model_select"])
    trainset = []
    selectset = []

    for iTrial in range(len(trial_classification)):
        if iTrial in trind_train:
            trainset.append(np.transpose(np.array(data.spikes[iTrial])))
        elif iTrial in trind_select:
            selectset.append(np.transpose(np.array(data.spikes[iTrial])))

    bin_sums = trainset
    bin_sums_select = selectset
    # %% Okay NOW we train

    observation_dimensions = bin_sums[0].shape[1]
    hmm_storage = []
    select_ll = []

    if num_hidden_state_override > 0:
        N_iters = 100
        state_range = num_hidden_state_override
        hmm = ssm.HMM(
            num_hidden_state_override,
            observation_dimensions,
            observations="poisson",
            transitions="standard",
        )

        hmm.fit(
            bin_sums,
            method="em",
            num_iters=N_iters,
            init_method="random",
        )
        hmm_storage.append(hmm)

        # model selection decode
        select_ll.append(hmm.log_likelihood(bin_sums_select))

        print(f"Created Model For {num_hidden_state_override} States.")
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
                bin_sums,
                method="em",
                num_iters=N_iters,
                init_method="random",
            )
            hmm_storage.append(hmm)

            # model selection decode
            select_ll.append(hmm.log_likelihood(bin_sums_select))

            print(f"Created Model For {iState} States.")
        state_range = state_range.tolist()

    # %% Return variables
    return hmm_storage, select_ll, state_range
