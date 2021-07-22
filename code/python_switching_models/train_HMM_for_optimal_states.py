# -*- coding: utf-8 -*-
"""
Created on Mon Feb 22 09:58:02 2021

@author: calebsponheim
"""
import matplotlib.pyplot as plt
import ssm
import numpy as np
import autograd.numpy.random as npr
npr.seed(100)


def train_HMM_for_optimal_states(data, trial_classification, meta, bin_size, is_it_breaux):

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
    N_iters = 50
    state_range = np.arange(2, 30, 1)
    # state_range = np.arange(1,5)
    bin_sums = bin_sums.astype(np.int64)

    hmm_storage = []
    hmm_lls_storage = []
    hmm_lls_max = []
    select_ll = []
    train_ll = []
    AIC = []
    
    for iState in state_range:
        hmm = ssm.HMM(iState, observation_dimensions, observations="poisson")
        hmm_storage.append(hmm)
        hmm_lls = hmm.fit(np.transpose(bin_sums), method="em",
                          num_iters=N_iters, init_method="kmeans")
        hmm_lls_storage.append(hmm_lls)
        hmm_lls_max.append(max(hmm_lls))
        
        # model selection decode
        select_ll_temp = hmm.log_likelihood(np.transpose(bin_sums_select))/len(trind_select)
        select_ll.append(select_ll_temp)
        
        # trainset decode
        train_ll_temp = hmm.log_likelihood(np.transpose(bin_sums))/len(trind_train)
        train_ll.append(train_ll_temp)
      
        #AIC Section
        if iState == 1:
            # num_params = (len(hmm.params[0][0]))# + len(hmm.params[1][0]) + len(hmm.params[2]))
            num_params = 1
        else:
            num_params = iState * (iState-1)
            # num_params = (len(hmm.params[0][0]))# + (len(hmm.params[1][0]) * len(hmm.params[1][0])) + (len(hmm.params[2]) * len(hmm.params[2][1])))
        
        
        LL = select_ll_temp
        k = num_params
        AIC.append(((-2)*(LL)) + (2 * (k)))
        
        print(f'Created Model For {iState} States.')

    plt.plot(range(0,N_iters+1),np.transpose(hmm_lls_storage), label="EM")
    plt.xlabel("EM Iteration")
    plt.ylabel("Log Probability")
    plt.title("Probability over iterations, with increasing state number")
    plt.show()


    plt.plot(state_range,np.transpose(select_ll))
    plt.xlabel("state number")
    plt.title("Model-Select Log Likelihood over state number")
    plt.ylabel("Log Probability")
    plt.show()

    plt.plot(state_range,np.transpose(AIC))
    plt.xlabel("state number")
    plt.title("AIC over state number")
    plt.ylabel("AIC")
    plt.show()
    #%% AIC Calculation
   
    # AIC with training LL
    # AIC_train = []
    # BIC_train = []
    # for iState in range(0,len(state_range)):
    #     LL = hmm_lls_max[iState]
        
    #     if iState == 0:
    #         num_params = (len(hmm_storage[iState].params[0][0]) + len(hmm_storage[iState].params[1][0]) + len(hmm_storage[iState].params[2]))
    #     else:
    #         num_params = (len(hmm_storage[iState].params[0][0]) + (len(hmm_storage[iState].params[1][0]) * len(hmm_storage[iState].params[1][0])) + (len(hmm_storage[iState].params[2]) * len(hmm_storage[iState].params[2][1])))
        
    #     N = len(bin_sums[0])
    #     k = num_params
    #     AIC_train.append(((-2)*(LL)) + (2 * (k)))
    #     BIC_train.append(((-2)*(LL)) + (np.log(N) * (k)))
        
    # plt.plot(state_range,AIC_train)
    # # plt.plot(state_range,BIC_train)
    # plt.title("Akiake Information Criterion, with increasing state number")
    # plt.xlabel("state number")
    # plt.ylabel("AIC")
    # plt.show()
    # %% Determine Optimal State using "model classification" trials
    
    optimal_state_number = state_range[AIC.index(min(AIC))]


    #%% Return variables
    return hmm_storage, hmm_lls_storage, bin_sums, bin_sums_select, optimal_state_number