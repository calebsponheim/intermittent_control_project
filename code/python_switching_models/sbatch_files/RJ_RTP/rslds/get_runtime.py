# -*- coding: utf-8 -*-
"""
Created on Tue Nov 15 12:21:24 2022

@author: caleb_work
"""

import sys
import math

dims_in = int(sys.argv[1])
states_in = int(sys.argv[2])

x = dims_in
y = states_in
time_to_run = math.ceil((0.0682*x) + (0.3238*y) + (-0.001494*x**2) + (-0.005368*x*y) +
                        (-0.01862*y**2) + (9.659e-06*x**3) + (0.000114*x**2*y) + (0.0001095*x*y**2) + (0.0003365*y**3))

print(time_to_run)
