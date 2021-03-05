# -*- coding: utf-8 -*-
"""
Created on Tue Feb  9 09:41:28 2021

@author: calebsponheim
"""

def import_matlab_data(folderpath):
    import csv
    from os import listdir
    from os.path import isfile, join
    import numpy as np
    
    spikefiles = [f for f in listdir(folderpath) if isfile(join(folderpath, f)) if f.endswith('_spikes.csv')]
    
    
    file_count = 0
    for iFile in spikefiles:
        with open(folderpath + iFile) as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=',')
            line_count = 0
            for row in csv_reader:
                if line_count == 0:
                    data_ind_file = row
                data_ind_file = np.vstack((data_ind_file,row))
                line_count += 1
        if file_count == 0:
            data_by_trial = data_ind_file
            data_concatenated = data_ind_file
        data_by_trial = np.dstack((data_by_trial,data_ind_file))
        data_concatenated = np.hstack((data_concatenated,data_ind_file))
        file_count += 1
        print(f'Processed spikes from trial {file_count}.')
           
    #%% Import Kinematics into the equation
    kinfiles = [f for f in listdir(folderpath) if isfile(join(folderpath, f)) if f.endswith('_kinematics.csv')]
    file_count = 0
    for iFile in kinfiles:
        with open(folderpath + iFile) as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=',')
            line_count = 0
            for row in csv_reader:
                if line_count == 0:
                    x_ind_file = row
                elif line_count == 1:
                    y_ind_file = row
                elif line_count == 2:
                    speed_ind_file = row
                line_count += 1
        if file_count == 0:
            x_by_trial = x_ind_file
            x_concatenated = x_ind_file
            y_by_trial = y_ind_file
            y_concatenated = y_ind_file
            speed_by_trial = speed_ind_file
            speed_concatenated = speed_ind_file
        x_by_trial = np.dstack((x_by_trial,x_ind_file))
        x_concatenated = np.hstack((x_concatenated,x_ind_file))
        
        y_by_trial = np.dstack((y_by_trial,y_ind_file))
        y_concatenated = np.hstack((y_concatenated,y_ind_file))
        
        speed_by_trial = np.dstack((speed_by_trial,speed_ind_file))
        speed_concatenated = np.hstack((speed_concatenated,speed_ind_file))
        
        file_count += 1
        print(f'Processed Kinematics from trial {file_count}')
    
    #%% Import events
    kinfiles = [f for f in listdir(folderpath) if isfile(join(folderpath, f)) if f.endswith('_events.csv')]
    file_count = 0
    for iFile in kinfiles:
        with open(folderpath + iFile) as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=',')
            line_count = 0
            for row in csv_reader:
                if line_count == 0:
                    start_ind_file = row
                elif line_count == 1:
                    move_ind_file = row
                elif line_count == 2:
                    end_ind_file = row
                line_count += 1
        if file_count == 0:
            start_concatenated = start_ind_file
            move_concatenated = move_ind_file
            end_concatenated = end_ind_file
        start_concatenated = np.hstack((start_concatenated,start_ind_file))
        
        move_concatenated = np.hstack((move_concatenated,move_ind_file))
        
        end_concatenated = np.hstack((end_concatenated,end_ind_file))
        
        file_count += 1
        print(f'Processed events from trial {file_count}')
    
    
    class data:
        def __init__(self,data_by_trial,x_by_trial,y_by_trial,speed_by_trial,start_concatenated,move_concatenated,end_concatenated):
            self.spikes = data_by_trial
            self.x = x_by_trial
            self.y = y_by_trial
            self.speed = speed_by_trial
            self.start = start_concatenated
            self.move = move_concatenated
            self.end = end_concatenated
    
    data = data(data_by_trial,x_by_trial,y_by_trial,speed_by_trial,start_concatenated,move_concatenated,end_concatenated)
    return data