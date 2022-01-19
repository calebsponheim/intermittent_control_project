# -*- coding: utf-8 -*-
"""
Created on Tue Nov 16 15:02:56 2021.

@author: calebsponheim
"""
import matplotlib.pyplot as plt


def state_prob_over_time(rslds_lem, xhat_lem, y, nun_state_override, figurepath):
    """ Look I dont know if this is okay.

    Parameters.
    ----------
    hmm_storage : TYPE
        DESCRIPTION.
    bin_sums : TYPE
        DESCRIPTION.
    num_states : TYPE
        DESCRIPTION.
    Returns.
    -------
    None.

    """

    state_probs = rslds_lem.expected_states(xhat_lem, y)
    state_probs = state_probs[0]
    plt.figure(figsize=(20, 5), dpi=80)
    plt.plot((state_probs[0:200, :]))
    plt.xlabel("time (bins)")
    plt.title("State Probability")
    plt.ylabel("Probability")
    plt.savefig(figurepath + "/rslds/state_prob.png")
    plt.show()
