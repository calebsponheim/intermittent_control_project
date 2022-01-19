# -*- coding: utf-8 -*-
"""
Created on Fri Nov 19 14:55:30 2021.

@author: calebsponheim
"""

# Running rslds

from run_rslds_LL_comprehensive import run_rslds_LL_comprehensive
from run_rslds import run_rslds

train_portion = 0.8
model_select_portion = 0.1
test_portion = 0.1
max_state_range = 9
state_skip = 1

subject = 'rs'
task = 'CO'
num_state_override = 8

# %% Running it
run_rslds(subject, task, train_portion, model_select_portion, test_portion,
          max_state_range, state_skip, num_state_override)

# %%


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
