#!/usr/bin/python

from models.mobility import truncated_levy_walk
import numpy as np
import logging
import sys
import argparse
import math
from pylab import *

nr_nodes = 30

rw = truncated_levy_walk(nr_nodes, dimensions=(100, 100), FL_EXP=-3.9)

path_x = map(lambda i: list(), range(nr_nodes))
path_y = map(lambda i: list(), range(nr_nodes))

for i in range(100):
    for step in range(10):
        p = rw.next()
        for idx, pp in enumerate(p):
            tx, ty = pp[0], pp[1]
            path_x[idx].append(tx)
            path_y[idx].append(ty)


for idx in range(nr_nodes):
    px = path_x[idx]
    py = path_y[idx]
    plot(px, py, linestyle='solid')

show() # or savefig(<filename>)
