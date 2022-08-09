# -*- coding: utf-8 -*\
"""
Created on Tue Feb  9 09:27:33 2021

@author: calebsponheim
"""
import numpy as np
import os
import pandas as pd
import csv


def assign_trials_to_HMM_group(data, meta, midway_run, fold_number, folderpath_out):

    train_portion = meta.train_portion
    model_select_portion = meta.model_select_portion

    number_of_trials = len(data.spikes)
    trial_indices = np.arange(0, number_of_trials)

    if midway_run == 1:
        # see if multifold shuffles index file csv is already made
        temp_datafolderlist = os.listdir(folderpath_out)

        if 'multifold_trial_classification.csv' in temp_datafolderlist:
            # if it is, then load it
            pd.read_csv(folderpath_out + 'multifold_trial_classification.csv')
        elif 'multifold_trial_classification.csv' not in temp_datafolderlist:
            # if not, make it
            np.random.shuffle(trial_indices)
            multifold_shuffled_order = trial_indices

            multifold_shuffled_order_out = pd.DataFrame(multifold_shuffled_order)
            multifold_shuffled_order_out.to_csv(
                folderpath_out + 'multifold_trial_classification.csv', index=False, header=False)

            # bring in which fold it is
            # take that segment of data

    else:
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
