# -*- coding: utf-8 -*-
"""
Created on Mon Nov 21 09:45:48 2022

@author: caleb_work
"""
import pandas as pd
from os import listdir
from os.path import isfile, join


def decode_kinematics_from_latents(folderpath):
    # Load Kinematics
    kinfiles = [
        f
        for f in listdir(folderpath)
        if isfile(join(folderpath, f))
        if f.endswith("_kinematics.csv")
    ]
    file_count = 0
    x_by_trial = []
    y_by_trial = []
    x_velocity_by_trial = []
    y_velocity_by_trial = []
    speed_by_trial = []

    for iFile in kinfiles:
        kinematics = pd.DataFrame.to_numpy(pd.read_csv(folderpath + iFile))
        x_by_trial.append(kinematics[:, 0])
        y_by_trial.append(kinematics[:, 1])
        x_velocity_by_trial.append(kinematics[:, 2])
        y_velocity_by_trial.append(kinematics[:, 3])
        speed_by_trial.append(kinematics[:, 4])

        file_count += 1
        if file_count % 100 == 0:
            print(f"Processed Kinematics from trial {file_count}")
    # Load Latents

    infile = open(folderpath_out + 'fold_' + str(fold_number) + '_model', 'rb')
    model = pickle.load(infile)
    infile.close()
    # Structure Latent Data to be timesteps x neurons, float64 array, non-numpy.

    # Bin Kinematics into 50ms bins

    # Structure Kinematics to be timesteps x kinematics

    #
