# -*- coding: utf-8 -*-
"""
Created on Tue Feb  9 09:41:28 2021.

@author: calebsponheim
"""


def import_matlab_data(folderpath):
    # %%
    import csv
    from os import listdir
    from os.path import isfile, join
    # import pandas as pd

    spikefiles = [
        f
        for f in listdir(folderpath)
        if isfile(join(folderpath, f))
        if f.endswith("_spikes.csv")
    ]

    file_count = 0
    data_by_trial = []
    # data_concatenated = []
    for iFile in spikefiles:

        with open(folderpath + iFile) as csv_file:
            data_ind_file = []
            csv_reader = csv.reader(csv_file, delimiter=",")
            line_count = 0
            for row in csv_reader:
                for i in range(0, len(row)):
                    row[i] = int(row[i])
                data_ind_file.append(row)
                # if file_count == 0:
                #     data_concatenated.append(row)
                # else:
                #     data_concatenated[line_count].extend(row)
                line_count += 1
        data_by_trial.append(data_ind_file)
        file_count += 1
        if file_count % 100 == 0:
            print(f"Processed spikes from trial {file_count}.")

    # %% Import Kinematics into the equation
    # kinfiles = [
    #     f
    #     for f in listdir(folderpath)
    #     if isfile(join(folderpath, f))
    #     if f.endswith("_kinematics.csv")
    # ]
    # file_count = 0
    # x_by_trial = []
    # y_by_trial = []
    # speed_by_trial = []

    # for iFile in kinfiles:
    #     kinematics = pd.DataFrame.to_numpy(pd.read_csv(folderpath + iFile))
    #     x_by_trial.append(kinematics[:, 0])
    #     y_by_trial.append(kinematics[:, 1])
    #     speed_by_trial.append(kinematics[:, 4])

    #     file_count += 1
    #     if file_count % 100 == 0:
    #         print(f"Processed Kinematics from trial {file_count}")

    # %% export
    class data:
        def __init__(
            self,
            data_by_trial,
        ):
            self.spikes = data_by_trial

    data = data(data_by_trial)
    return data
