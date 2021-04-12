# -*- coding: utf-8 -*-
"""
Created on Tue Feb  9 09:41:00 2021

@author: calebsponheim
"""

# import csv
# from os import listdir
# from os.path import isfile, join
import numpy as np
from import_matlab_data import import_matlab_data
from assign_trials_to_HMM_group import assign_trials_to_HMM_group
from train_HMM_for_optimal_states import train_HMM_for_optimal_states
folderpath = 'C:/Users/calebsponheim/Documents/git/intermittent_control_project/data/python_switching_models/Bxcenter_out1902280.05sBins/'

class meta:
    def __init__(self,train_portion,model_select_portion,test_portion):
        self.train_portion = .8
        self.model_select_portion = .1 
        self.test_portion = .1

train_portion = .8
model_select_portion = .1 
test_portion = .1
bin_size = 50 #in milliseconds     
meta = meta(train_portion,model_select_portion,test_portion)


data = import_matlab_data(folderpath)

#%%

trial_classification = assign_trials_to_HMM_group(data,meta)

#%% saving data

#%% Finding Optimal States

hmm_storage, hmm_lls_storage, bin_sums, bin_sums_select, optimal_state_number = train_HMM_for_optimal_states(data,trial_classification,meta,bin_size)

#%% Separate out Test Data


trind_test = [i for i, x in enumerate(
    trial_classification) if x == "test"]
testset = []
# S = []
# trial_count = 1
for iTrial in range(len(trial_classification)):
    S_temp = data.spikes[iTrial]
    for iUnit in range(len(S_temp)):
        temp = S_temp[iUnit]
        temp_indices = np.arange(0, len(temp), bin_size)
        temp_binned = [temp[i] for i in temp_indices]
        if iTrial in trind_test:
            if len(testset) <= iUnit:
                testset.append(temp_binned)
            else:
                testset[iUnit].extend(temp_binned)

# Okay now that we have the training trials in its own variable, we need to turn it into the right shape for training, presumably.

for iUnit in range(len(testset)):
    if iUnit == 0:
        bin_sums_test = testset[iUnit]
    else:
        bin_sums_test = np.vstack(
            (bin_sums_test, testset[iUnit]))
        

#%% Decoding Test Data using Optimal States

decoded_test_data = []
for iState in range(len(hmm_storage)):
    decoded_test_data.append(hmm_storage[iState].most_likely_states(np.transpose(bin_sums_test)))
    
#%% Save

import csv

with open('decoded_test_data.csv', 'w') as f:
    write = csv.writer(f)
    
    write.writerows(decoded_test_data)
    
with open('trial_classifiction.csv', 'w') as f:
    write = csv.writer(f,delimiter=' ')
    for iTrial in range(len(trial_classification)):
        write.writerow(trial_classification[iTrial])