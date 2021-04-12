# -*- coding: utf-8 -*-
"""
Created on Mon Feb 22 09:58:02 2021

@author: calebsponheim
"""
import matplotlib.pyplot as plt
import ssm
import numpy as np
import autograd.numpy.random as npr
npr.seed(0)


def train_HMM_for_optimal_states(data, trial_classification, meta, bin_size):

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
            temp_indices = np.arange(0, len(temp), bin_size)
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
    N_iters = 30
    state_range = np.arange(2, 26, 1)
    # state_range = np.arange(1,5)
    bin_sums = bin_sums.astype(np.int64)

    hmm_storage = []
    hmm_lls_storage = []
    hmm_lls_max = []
    select_ll = []
    AIC = []
    
    for iState in state_range:
        hmm = ssm.HMM(iState, observation_dimensions, observations="poisson")
        hmm_storage.append(hmm)
        hmm_lls = hmm.fit(np.transpose(bin_sums), method="em",
                          num_iters=N_iters, init_method="kmeans")
        hmm_lls_storage.append(hmm_lls)
        hmm_lls_max.append(max(hmm_lls))
        
        # modele selection decode
        select_ll_temp = hmm.log_likelihood(np.transpose(bin_sums_select))
        select_ll.append(select_ll_temp)
       
        #AIC Section
        if iState == 1:
            num_params = (len(hmm.params[0][0]) + len(hmm.params[1][0]) + len(hmm.params[2]))
        else:
            num_params = (len(hmm.params[0][0]) + (len(hmm.params[1][0]) * len(hmm.params[1][0])) + (len(hmm.params[2]) * len(hmm.params[2][1])))
        
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
    plt.title("Log Likelihood over state number")
    plt.ylabel("Log Probability")
    plt.show()
    # %% Determine Optimal State using "model classification" trials
    
    optimal_state_number = state_range[select_ll == max(select_ll)]


    #%% AIC Calculation
   
    # AIC with training LL
    AIC_train = []
    for iState in range(0,len(state_range)):
        LL = hmm_lls_max[iState]
        
        if iState == 0:
            num_params = (len(hmm_storage[iState].params[0][0]) + len(hmm_storage[iState].params[1][0]) + len(hmm_storage[iState].params[2]))
        else:
            num_params = (len(hmm_storage[iState].params[0][0]) + (len(hmm_storage[iState].params[1][0]) * len(hmm_storage[iState].params[1][0])) + (len(hmm_storage[iState].params[2]) * len(hmm_storage[iState].params[2][1])))
        

        k = num_params
        AIC_train.append(((-2)*(LL)) + (2 * (k)))
        
    plt.plot(state_range,AIC_train)
    plt.title("Akiake Information Criterion, with increasing state number")
    plt.xlabel("state number")
    plt.ylabel("AIC")
    plt.show()

    #%% Return variables
    return hmm_storage, hmm_lls_storage, bin_sums, bin_sums_select, optimal_state_number