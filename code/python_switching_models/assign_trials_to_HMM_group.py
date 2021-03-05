# -*- coding: utf-8 -*\
"""
Created on Tue Feb  9 09:27:33 2021

@author: calebsponheim
"""
import numpy as np

def assign_trials_to_HMM_group(data,meta):
    
    train_portion = meta.train_portion    
    model_select_portion = meta.model_select_portion
    
    number_of_trials = data.spikes.shape[2]
    trial_indices = np.arange(0,number_of_trials)
    
    np.random.shuffle(trial_indices)
    shuffled_indices = trial_indices
    train_trials = shuffled_indices[np.arange(0,int(np.rint(number_of_trials*train_portion)))]
    model_select_trials = shuffled_indices[np.arange(int(np.rint(number_of_trials*train_portion)),\
       (int(np.rint(number_of_trials*train_portion))+int(np.rint(number_of_trials*model_select_portion))))]
    test_trials = shuffled_indices[np.arange((int(np.rint(number_of_trials*train_portion)+np.rint(number_of_trials*model_select_portion))),shuffled_indices.shape[0])]
    
    trial_classification = np.array([],dtype='S')
    
    for iTrial in np.arange(0,shuffled_indices.shape[0]):
        if iTrial == 1:
            if iTrial in model_select_trials:
                trial_classification = 'model_select'
            elif iTrial in test_trials:
                trial_classification = 'test'
            elif iTrial in train_trials:
                trial_classification = 'train'
        elif iTrial in model_select_trials:
            trial_classification = np.hstack((trial_classification,'model_select'))
        elif iTrial in test_trials:
            trial_classification = np.hstack((trial_classification,'test'))
        elif iTrial in train_trials:
            trial_classification = np.hstack((trial_classification,'train'))
        # trial_classification[model_select_trials] = 'model_select'
        # trial_classification[test_trials] = 'test'
        # trial_classification[train_trials] = 'train'
    
    return trial_classification
    