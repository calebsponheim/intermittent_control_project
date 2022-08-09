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
        if file_count % 10 == 0:
            print(f"Processed spikes from trial {file_count}.")

    # %% Import Kinematics into the equation
    kinfiles = [
        f
        for f in listdir(folderpath)
        if isfile(join(folderpath, f))
        if f.endswith("_kinematics.csv")
    ]
    file_count = 0
    x_by_trial = []
    y_by_trial = []
    speed_by_trial = []
    x_concatenated = []
    y_concatenated = []
    speed_concatenated = []

    for iFile in kinfiles:
        x_ind_file = []
        y_ind_file = []
        speed_ind_file = []
        with open(folderpath + iFile) as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=",")
            line_count = 0
            for row in csv_reader:
                for i in range(0, len(row)):
                    row[i] = float(row[i])

                if line_count == 0:
                    x_ind_file = row
                    if file_count == 0:
                        x_concatenated.append(row)
                    else:
                        x_concatenated[0].extend(row)
                elif line_count == 1:
                    y_ind_file = row
                    if file_count == 0:
                        y_concatenated.append(row)
                    else:
                        y_concatenated[0].extend(row)
                elif line_count == 2:
                    speed_ind_file = row
                    if file_count == 0:
                        speed_concatenated.append(row)
                    else:
                        speed_concatenated[0].extend(row)
                line_count += 1
        x_by_trial.append(x_ind_file)
        y_by_trial.append(y_ind_file)
        speed_by_trial.append(speed_ind_file)

        file_count += 1
        if file_count % 10 == 0:
            print(f"Processed Kinematics from trial {file_count}")

    # %% export
    class data:
        def __init__(
            self,
            data_by_trial,
            x_by_trial,
            y_by_trial,
            speed_by_trial,
            start_concatenated,
            move_concatenated,
            end_concatenated,
        ):
            self.spikes = data_by_trial
            self.x = x_by_trial
            self.y = y_by_trial
            self.speed = speed_by_trial
            self.start = start_concatenated
            self.move = move_concatenated
            self.end = end_concatenated

    data = data(data_by_trial, x_by_trial, y_by_trial, speed_by_trial, [], [], [])
    return data
