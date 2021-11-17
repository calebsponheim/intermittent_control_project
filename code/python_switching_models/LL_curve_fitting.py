# -*- coding: utf-8 -*-
"""
Created on Wed Oct 20 14:45:00 2021.

@author: calebsponheim
"""

from scipy.optimize import curve_fit
import numpy as np
import matplotlib.pyplot as plt


def func(x, a, b, c):
    """It's just a exponential function."""
    return a * np.exp(b * x) - c


def LL_curve_fitting(select_ll, state_range):
    """It's just fitting a exponential function."""
    popt, pcov = curve_fit(
        func, state_range, np.transpose(select_ll), p0=(-35000, -0.13, 319000)
    )

    plt.plot(state_range, np.transpose(select_ll), linestyle=" ", marker="o")

    plt.plot(
        state_range,
        func(state_range, *popt),
        linestyle="--",
        linewidth=2,
        color="black",
    )

    # plt.plot(
    #     state_range,
    #     func(state_range, *[-35000, -0.13, 319000]),
    #     linestyle="--",
    #     linewidth=2,
    #     color="blue",
    # )

    plt.axhline(y=-popt[2], color="r", linestyle="-")
    # plt.axhline(y=ninety_percent_threshold, color="b", linestyle="-")
    plt.xlabel("state number")
    plt.title("Model-Select Log Likelihood over state number")
    plt.ylabel("Log Probability")
    plt.show()
