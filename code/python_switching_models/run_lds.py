# -*- coding: utf-8 -*-
"""
Created on Mon July 26 2021

@author: calebsponheim
"""


from import_matlab_data import import_matlab_data
from assign_trials_to_HMM_group import assign_trials_to_HMM_group
from train_lds import train_lds
folderpath = 'C:/Users/calebsponheim/Documents/git/intermittent_control_project/data/python_switching_models/Bxcenter_out1902280.05sBins/'
# folderpath = 'C:/Users/calebsponheim/Documents/git/intermittent_control_project/data/python_switching_models/Bxcenter_out1902280.05_sBins_move_window_only/'
# folderpath = 'C:/Users/calebsponheim/Documents/git/intermittent_control_project/data/python_switching_models/RSCO0.05sBins/'
# folderpath = 'C:/Users/calebsponheim/Documents/git/intermittent_control_project/data/python_switching_models/Bxcenter_out_and_RTP1902280.05sBins/'
# folderpath = 'C:/Users/calebsponheim/Documents/git/intermittent_control_project/data/python_switching_models/Bxcenter_out1803230.05sBins/'

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




data, is_it_breaux = import_matlab_data(folderpath)

#%%

trial_classification = assign_trials_to_HMM_group(data,meta)

#%% saving data

#%% Finding Optimal States

hmm_storage, hmm_lls_storage, bin_sums, bin_sums_select, optimal_state_number = train_lds(data,trial_classification,meta,bin_size,is_it_breaux)