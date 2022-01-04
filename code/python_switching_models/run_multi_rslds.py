# -*- coding: utf-8 -*-
"""
Created on Fri Nov 19 14:55:30 2021.

@author: calebsponheim
"""

# Running rslds

from run_rslds import run_rslds
# from run_rslds_LL_comprehensive import run_rslds_LL_comprehensive

train_portion = 0.9
model_select_portion = 0.05
test_portion = 0.05
max_state_range = 12
state_skip = 1


# run_rslds(
#     "rs",
#     "CO",
#     train_portion,
#     model_select_portion,
#     test_portion,
#     max_state_range,
#     state_skip,
#     16
# )

subject = 'rs'
task = 'CO'
num_state_override = 11

# run_rslds_LL_comprehensive(
#     subject,
#     task,
#     train_portion,
#     model_select_portion,
#     test_portion,
#     max_state_range,
#     state_skip,
#     num_state_override
# )

run_rslds(
    subject,
    task,
    train_portion,
    model_select_portion,
    test_portion,
    max_state_range,
    state_skip,
    num_state_override
)

# run_rslds(
#     "rj",
#     "RTP",
#     train_portion,
#     model_select_portion,
#     test_portion,
#     max_state_range,
#     state_skip,
#     16
# )
