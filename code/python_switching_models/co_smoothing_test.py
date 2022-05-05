# -*- coding: utf-8 -*-
"""
Created on Wed Apr 27 12:26:55 2022

@author: calebsponheim
"""

from nlb_tools.nwb_interface import NWBDataset
from nlb_tools.make_tensors import make_train_input_tensors, make_eval_input_tensors, make_eval_target_tensors, save_to_h5
from nlb_tools.evaluation import evaluate
from pynwb import NWBHDF5IO
from nwbwidgets import nwb2widget
import ssm
import numpy as np
import h5py
import sys

# co-smoothing test

dataset_name = 'mc_maze_small'
datapath = 'C:/Users/calebsponheim/Documents/git/nlb_tools/000127/sub-Han'
dataset = NWBDataset(datapath)


# %%

io = NWBHDF5IO(datapath, mode='r')
nwb = io.read()

nwb2widget(nwb)


# %%
# Choose the phase here, either 'val' or 'test'
phase = 'val'

# Choose bin width and resample
bin_width = 5
dataset.resample(bin_width)

# Create suffix for group naming later
suffix = '' if (bin_width == 5) else f'_{int(round(bin_width))}'

# Make train input data

# Generate input tensors
train_trial_split = 'train' if (phase == 'val') else ['train', 'val']
train_dict = make_train_input_tensors(dataset, dataset_name=dataset_name,
                                      trial_split=train_trial_split, save_file=False, include_forward_pred=True)

# Unpack input data
train_spikes_heldin = train_dict['train_spikes_heldin']
train_spikes_heldout = train_dict['train_spikes_heldout']

# Make eval input data

# Generate input tensors
eval_trial_split = phase
eval_dict = make_eval_input_tensors(
    dataset, dataset_name=dataset_name, trial_split=eval_trial_split, save_file=False)

# Unpack data
eval_spikes_heldin = eval_dict['eval_spikes_heldin']

# Prep input

# Combine train spiking data into one array
train_spikes_heldin = train_dict['train_spikes_heldin']
train_spikes_heldout = train_dict['train_spikes_heldout']
train_spikes_heldin_fp = train_dict['train_spikes_heldin_forward']
train_spikes_heldout_fp = train_dict['train_spikes_heldout_forward']
train_spikes = np.concatenate([
    np.concatenate([train_spikes_heldin, train_spikes_heldin_fp], axis=1),
    np.concatenate([train_spikes_heldout, train_spikes_heldout_fp], axis=1),
], axis=2)

# Fill missing test spiking data with zeros and make masks
eval_spikes_heldin = eval_dict['eval_spikes_heldin']
eval_spikes = np.full((eval_spikes_heldin.shape[0],
                      train_spikes.shape[1], train_spikes.shape[2]), 0.0)
masks = np.full((eval_spikes_heldin.shape[0], train_spikes.shape[1], train_spikes.shape[2]), False)
eval_spikes[:, :eval_spikes_heldin.shape[1], :eval_spikes_heldin.shape[2]] = eval_spikes_heldin
masks[:, :eval_spikes_heldin.shape[1], :eval_spikes_heldin.shape[2]] = True

# Make lists of arrays
train_datas = [train_spikes[i, :, :].astype(int) for i in range(len(train_spikes))]
eval_datas = [eval_spikes[i, :, :].astype(int) for i in range(len(eval_spikes))]
eval_masks = [masks[i, :, :].astype(bool) for i in range(len(masks))]

num_heldin = train_spikes_heldin.shape[2]
tlen = train_spikes_heldin.shape[1]
num_train = len(train_datas)
num_eval = len(eval_datas)

# Run SLDS

# Set parameters
T = train_datas[0].shape[0]  # trial length
K = 1  # number of discrete states
D = 3  # dimensionality of latent states
N = train_datas[0].shape[1]  # input dimensionality

slds = ssm.SLDS(N, K, D,
                transitions='standard',
                emissions='poisson',
                emission_kwargs=dict(link="log"),
                dynamics_kwargs={
                    'l2_penalty_A': 3000.0,
                }
                )

# Train
q_elbos_lem_train, q_lem_train = slds.fit(
    datas=train_datas,
    method="laplace_em",
    variational_posterior="structured_meanfield",
    num_init_iters=25, num_iters=25, alpha=0.2,
)

# Pass eval data
q_elbos_lem_eval, q_lem_eval = slds.approximate_posterior(
    datas=eval_datas,
    masks=eval_masks,
    method="laplace_em",
    variational_posterior="structured_meanfield",
    num_iters=25, alpha=0.2,
)

# Generate rate predictions

# Smooth observations using inferred states
train_rates = [slds.smooth(q_lem_train.mean_continuous_states[i], train_datas[i])
               for i in range(num_train)]
eval_rates = [slds.smooth(q_lem_eval.mean_continuous_states[i],
                          eval_datas[i], mask=eval_masks[i]) for i in range(num_eval)]

# Reshape output
train_rates = np.stack(train_rates)
eval_rates = np.stack(eval_rates)

train_rates_heldin = train_rates[:, :tlen, :num_heldin]
train_rates_heldout = train_rates[:, :tlen, num_heldin:]
eval_rates_heldin = eval_rates[:, :tlen, :num_heldin]
eval_rates_heldout = eval_rates[:, :tlen, num_heldin:]
eval_rates_heldin_forward = eval_rates[:, tlen:, :num_heldin]
eval_rates_heldout_forward = eval_rates[:, tlen:, num_heldin:]

# Prepare submission data

output_dict = {
    dataset_name + suffix: {
        'train_rates_heldin': train_rates_heldin,
        'train_rates_heldout': train_rates_heldout,
        'eval_rates_heldin': eval_rates_heldin,
        'eval_rates_heldout': eval_rates_heldout,
        'eval_rates_heldin_forward': eval_rates_heldin_forward,
        'eval_rates_heldout_forward': eval_rates_heldout_forward,
    }
}

if phase == 'val':
    target_dict = make_eval_target_tensors(dataset, dataset_name=dataset_name, train_trial_split='train',
                                           eval_trial_split='val', include_psth=('mc_rtt' not in dataset_name), save_file=False)

    print(evaluate(target_dict, output_dict))
