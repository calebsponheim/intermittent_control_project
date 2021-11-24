# -*- coding: utf-8 -*-
"""
Created on Fri Nov 19 14:55:30 2021.

@author: calebsponheim
"""

# Running rslds

from run_rslds import run_rslds

train_portion = 0.5
model_select_portion = 0.4
test_portion = 0.1
max_state_range = 50
state_skip = 1

run_rslds(
    "rs",
    "CO",
    train_portion,
    model_select_portion,
    test_portion,
    max_state_range,
    state_skip,
)

run_rslds(
    "rs",
    "RTP",
    train_portion,
    model_select_portion,
    test_portion,
    max_state_range,
    state_skip,
)

run_rslds(
    "rj",
    "RTP",
    train_portion,
    model_select_portion,
    test_portion,
    max_state_range,
    state_skip,
)
