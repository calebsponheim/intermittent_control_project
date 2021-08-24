# -*- coding: utf-8 -*-
"""
Created on Mon August 8th 2021.

@author: calebsponheim
"""


import csv
from import_matlab_data import import_matlab_data
from assign_trials_to_HMM_group import assign_trials_to_HMM_group
from train_rslds import train_rslds

# folderpath = 'C:/Users/calebsponheim/Documents/git/intermittent_control_project/data/python_switching_models/Bxcenter_out1902280.05sBins/'
# folderpath = 'C:/Users/calebsponheim/Documents/git/intermittent_control_project/data/python_switching_models/Bxcenter_out1902280.05_sBins_move_window_only/'
# folderpath = 'C:/Users/calebsponheim/Documents/git/intermittent_control_project/data/python_switching_models/RSCO0.05sBins/'
folderpath = 'C:/Users/calebsponheim/Documents/git/intermittent_control_project/data/python_switching_models/Bxcenter_out_and_RTP1902280.05sBins/'
# folderpath = 'C:/Users/calebsponheim/Documents/git/intermittent_control_project/data/python_switching_models/Bxcenter_out1803230.05sBins/'


class meta:
    def __init__(self, train_portion, model_select_portion, test_portion):
        self.train_portion = .8
        self.model_select_portion = .1
        self.test_portion = .1


train_portion = .8
model_select_portion = .1
test_portion = .1
bin_size = 50  # in milliseconds
meta = meta(train_portion, model_select_portion, test_portion)


data, is_it_breaux = import_matlab_data(folderpath)

# %%

trial_classification = assign_trials_to_HMM_group(data, meta)

# %% Finding Optimal States
rslds_lem, xhat_lem, y = train_rslds(data, trial_classification,
                           meta, bin_size, is_it_breaux)

# %% Decoding Test Data using Optimal States
decoded_data = rslds_lem.most_likely_states(xhat_lem, y)

# %% write data for matlab

with open(folderpath + 'decoded_test_data.csv', 'w') as f:
    write = csv.writer(f)

    write.writerow(decoded_data)

with open(folderpath + 'trial_classifiction.csv', 'w', newline='') as f:
    # write = csv.writer(f,delimiter=',')
    write = csv.writer(f, delimiter=' ', quotechar='|',
                       quoting=csv.QUOTE_MINIMAL)
    for iTrial in range(len(trial_classification)):
        write.writerow(trial_classification[iTrial])
