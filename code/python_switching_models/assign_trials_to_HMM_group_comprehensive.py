# -*- coding: utf-8 -*\
"""
Created on Tue Feb  9 09:27:33 2021

@author: calebsponheim
"""
import numpy as np


def assign_trials_to_HMM_group_comprehensive(data, meta, step, shuffled_indices):

    number_of_trials = len(data.spikes)

    test_and_model_select_range = np.int32(np.arange(
        number_of_trials * ((step - 1) * 0.1), number_of_trials * (step * 0.1)))

    model_select_trials = shuffled_indices[test_and_model_select_range[0: int(
        len(test_and_model_select_range) / 2)]]

    test_trials = shuffled_indices[test_and_model_select_range[int(
        len(test_and_model_select_range) / 2) + 1: int(len(test_and_model_select_range))]]

    shuffled_indices = np.delete(shuffled_indices, test_and_model_select_range)
    train_trials = shuffled_indices

    trial_classification = []

    for iTrial in range(len(shuffled_indices)):
        if iTrial in model_select_trials:
            trial_classification.append("model_select")
        elif iTrial in test_trials:
            trial_classification.append("test")
        elif iTrial in train_trials:
            trial_classification.append("train")
    return trial_classification
