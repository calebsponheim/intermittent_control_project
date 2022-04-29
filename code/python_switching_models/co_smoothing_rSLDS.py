# -*- coding: utf-8 -*-
"""
Created on Mon Apr 25 14:32:45 2022

@author: calebsponheim
"""
from ssm.lds import SLDS
import numpy as np
import h5py
from sklearn.linear_model import PoissonRegressor
from datetime import datetime
import gc
from nlb_tools.evaluation import evaluate
from nlb_tools.nwb_interface import NWBDataset
from nlb_tools.make_tensors import (make_train_input_tensors,
                                    make_eval_input_tensors, make_eval_target_tensors, save_to_h5)


def co_smoothing_rSLDS(data, trial_classification, meta, bin_size,
                       is_it_breaux, num_hidden_state_override):

    return info
