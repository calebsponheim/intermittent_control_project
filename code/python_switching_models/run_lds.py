# -*- coding: utf-8 -*-
"""
Created on Mon July 26 2021.

@author: calebsponheim
"""


import csv
import numpy as np
from import_matlab_data import import_matlab_data
from assign_trials_to_HMM_group import assign_trials_to_HMM_group
from train_lds import train_lds
from train_slds import train_slds
# folderpath = 'C:/Users/calebsponheim/Documents/git/intermittent_control_project/data/python_switching_models/Bxcenter_out1902280.05sBins/'
folderpath = 'C:/Users/calebsponheim/Documents/git/intermittent_control_project/data/python_switching_models/Bxcenter_out1902280.05_sBins_move_window_only/'
# folderpath = 'C:/Users/calebsponheim/Documents/git/intermittent_control_project/data/python_switching_models/RSCO0.05sBins/'
# folderpath = 'C:/Users/calebsponheim/Documents/git/intermittent_control_project/data/python_switching_models/Bxcenter_out_and_RTP1902280.05sBins/'
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

# hmm_storage, hmm_lls_storage, bin_sums, bin_sums_select, optimal_state_number = train_lds(
#     data, trial_classification, meta, bin_size, is_it_breaux)

# %% Finding Optimal States
slds, q_lem_x = train_slds(data, trial_classification,
                           meta, bin_size, is_it_breaux)

# %% structure all data for decode
if is_it_breaux == 0:
    bin_size = 1

export_set = []
for iTrial in range(len(trial_classification)):
    S_temp = data.spikes[iTrial]
    for iUnit in range(len(S_temp)):
        temp = S_temp[iUnit]
        temp_indices = np.arange(0, len(temp), bin_size)
        temp_binned = [temp[i] for i in temp_indices]
        if len(export_set) <= iUnit:
            export_set.append(temp_binned)
        else:
            export_set[iUnit].extend(temp_binned)

# Okay now that we have the data in the right format,
# we need to put in an HMM-readable format.

for iUnit in range(len(export_set)):
    if iUnit == 0:
        bin_sums = export_set[iUnit]
    else:
        bin_sums = np.vstack(
            (bin_sums, export_set[iUnit]))


# %% Decoding Test Data using Optimal States
    decoded_data = slds.most_likely_states(q_lem_x, np.transpose(bin_sums))

# %% Save Data

with open(folderpath + 'decoded_test_data.csv', 'w') as f:
    write = csv.writer(f)

    write.writerow(decoded_data)

with open(folderpath + 'trial_classifiction.csv', 'w', newline='') as f:
    # write = csv.writer(f,delimiter=',')
    write = csv.writer(f, delimiter=' ', quotechar='|',
                       quoting=csv.QUOTE_MINIMAL)
    for iTrial in range(len(trial_classification)):
        write.writerow(trial_classification[iTrial])
