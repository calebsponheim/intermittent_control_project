# -*- coding: utf-8 -*-
"""
Created on Tue Feb  9 09:41:00 2021

@author: calebsponheim
"""

# import csv
# from os import listdir
# from os.path import isfile, join
# import numpy as np
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

# import pickle

# data.trial_classification = trial_classification
# data.meta = meta
# data.folderpath = folderpath

# with open('C:/Users/calebsponheim/Documents/git/intermittent_control_project/data/python_switching_models/hmm_data.pickle', 'wb') as f:
#     pickle.dump(data, f)

#%% Finding Optimal States

hmm_storage,hmm_lls_storage,bin_sums,optimal_state_number = train_HMM_for_optimal_states(data,trial_classification,meta,bin_size)

#%% Separate out Test Data

#%% Decoding Test Data using Optimal States

decoded_test_data = hmm_storage[optimal_state_number-1].most_likely_states(data)