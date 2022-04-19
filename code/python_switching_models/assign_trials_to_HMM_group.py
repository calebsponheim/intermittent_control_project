# -*- coding: utf-8 -*\
"""
Created on Tue Feb  9 09:27:33 2021

@author: calebsponheim
"""
import numpy as np


def assign_trials_to_HMM_group(data, meta):

    train_portion = meta.train_portion
    model_select_portion = meta.model_select_portion

    number_of_trials = len(data.spikes)
    trial_indices = np.arange(0, number_of_trials)

    np.random.shuffle(trial_indices)
    shuffled_indices = trial_indices
    train_trials = shuffled_indices[np.arange(0, int(np.rint(number_of_trials*train_portion)))]
    model_select_trials = shuffled_indices[np.arange(int(np.rint(number_of_trials*train_portion)),
                                                     (int(np.rint(number_of_trials*train_portion))+int(np.rint(number_of_trials*model_select_portion))))]
    test_trials = shuffled_indices[np.arange((int(np.rint(
        number_of_trials*train_portion)+np.rint(number_of_trials*model_select_portion))), shuffled_indices.shape[0])]

    trial_classification = []

    for iTrial in range(len(shuffled_indices)):
        if iTrial in model_select_trials:
            trial_classification.append('model_select')
        elif iTrial in test_trials:
            trial_classification.append('test')
        elif iTrial in train_trials:
            trial_classification.append('train')

    return trial_classification
