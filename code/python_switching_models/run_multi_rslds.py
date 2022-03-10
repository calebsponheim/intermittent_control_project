# -*- coding: utf-8 -*-
"""
Created on Fri Nov 19 14:55:30 2021.

@author: calebsponheim
"""

# Running rslds

# from run_rslds_LL_comprehensive import run_rslds_LL_comprehensive
from run_rslds import run_rslds
import numpy as np

train_portion = 0.8
model_select_portion = 0.1
test_portion = 0.1
hidden_max_state_range = 120
hidden_state_skip = 1
rslds_ll_analysis = 0
latent_dim_state_range = np.arange(4, 6)

subject = 'rs'
task = 'CO'
num_hidden_state_override = 16

# %% Running it
model, xhat_lem, y, model_params, real_eigenvalues_out, imaginary_eigenvalues_out = run_rslds(
    subject, task, train_portion, model_select_portion, test_portion,
    hidden_max_state_range, hidden_state_skip, num_hidden_state_override,
    rslds_ll_analysis, latent_dim_state_range)

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
