# -*- coding: utf-8 -*-
"""
Created on Mon Feb 22 09:58:02 2021

@author: calebsponheim
"""
import numpy as np
import autograd.numpy as np
import autograd.numpy.random as npr
npr.seed(0)

import ssm
from ssm.util import find_permutation
from ssm.plots import gradient_cmap, white_to_color_cmap

import matplotlib.pyplot as plt

import seaborn as sns

def train_HMM_for_optimal_states(data,trial_classification,meta,bin_size):
    trind_train = np.where(trial_classification == 'train')
    trind_train = trind_train[0]
    # trainset = np.zeros([data.spikes.shape[0],data.spikes.shape[1],trind_train.shape[0]])
    trial_count = 1
    for iTrial in np.arange(trial_classification.shape[0]):
        S = data.spikes[:,:,iTrial]
        # S = np.transpose(S)
        if iTrial in trind_train:
            if trial_count == 1:
                trainset = S
                trial_count += 1
            # index_temp = np.where(iTrial == trind_train)[0]
            else:
                trainset = np.hstack((trainset,S))
                trial_count += 1
    
    # Okay now that we have the training trials in its own variable, we need to turn it into the right shape for training, presumably. 
    
    trainset = trainset.astype(np.int64)
    # bins = np.linspace(0, trainset.shape[1]-1, round((trainset.shape[1]-1)/bin_size))
    
    for iUnit in np.arange(0,trainset.shape[0]):
        # bin_sums_temp = np.zeros(bins.shape[0])
        # for iBin in np.arange(bins.shape[0]):
        #     if iBin == 1:
        #         bin_sums_temp[iBin] = np.sum(trainset[iUnit,0:(iBin)])
        #     else:    
        #         bin_sums_temp[iBin] = np.sum(trainset[iUnit,(iBin-1):iBin])
        if iUnit == 0:
            bin_sums = trainset[iUnit,np.arange(0,trainset.shape[1],bin_size)]
        else:
            bin_sums = np.vstack((bin_sums,trainset[np.arange(0,trainset.shape[1],bin_size)]))
        print(iUnit)
        
    #%% Okay NOW we train
    
    time_bins = bin_sums.shape[1]
    observation_dimensions = bin_sums.shape[0]
    N_iters = 50
    state_range = np.arange(1,25)
    bin_sums = bin_sums.astype(np.int64)
  
    hmm_storage = []
    hmm_lls_storage = []
    hmm_lls_max = []

    for iState in state_range:
        hmm = ssm.HMM(iState, observation_dimensions, observations="poisson")
        hmm_storage.append(hmm)
        hmm_lls = hmm.fit(np.transpose(bin_sums), method="em", num_iters=N_iters, init_method="kmeans")
        hmm_lls_storage.append(hmm_lls)
        hmm_lls_max.append(max(hmm_lls))
            
    plt.plot(np.transpose(hmm_lls_storage), label="EM")
    plt.xlabel("EM Iteration")
    plt.ylabel("Log Probability")
    plt.show()
    
    #%% Determine Optimal State using "model classification" trials
    
    trind_select = np.where(trial_classification == 'model_select')
    trind_select = trind_select[0]
    selectset = []
    for iTrial in np.arange(trial_classification.shape[0]):
        S = list(data.spikes[:,:,iTrial].astype(np.int64))
        if iTrial in trind_select:
                selectset.append(S)
    
    # selectset = selectset.astype(np.int64)
    bins = np.linspace(0, len(selectset)-1, round((len(selectset)-1)/50))
    bin_sums_select = []
    for iUnit in np.arange(0,len(selectset)):
        bin_sums_temp = []
        for iBin in np.arange(bins.shape[0]):
            if iBin == 1:
                bin_sums_temp.append(np.sum(selectset[iUnit,0:(iBin)]))
            else:    
                bin_sums_temp.append(np.sum(selectset[iUnit,(iBin-1):iBin]))
            bin_sums_select.append(bin_sums_temp)
        print(iUnit)
 
    optimal_state_number = hmm_lls_max.index(max(hmm_lls_max))+2
    
    return hmm_storage,hmm_lls_storage,bin_sums,optimal_state_number



    hmm_max = []
    for iState in np.arange(23):
        hmm_max.append(max(hmm_lls_storage[iState]))
        
    plt.plot(hmm_max, label="EM")
    plt.xlabel("state number")
    plt.ylabel("Log Probability")
    plt.show()
