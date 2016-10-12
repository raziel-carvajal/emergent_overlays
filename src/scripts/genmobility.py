# coding: utf-8
#
#  Copyright (C) 2008-2010 Istituto per l'Interscambio Scientifico I.S.I.
#  You can contact us by email (isi@isi.it) or write to:
#  ISI Foundation, Viale S. Severo 65, 10133 Torino, Italy.
#
#  This program was written by André Panisson <panisson@gmail.com>
#

'''
Created on Jan 24, 2012

@author: André Panisson
@contact: panisson@gmail.com
@organization: ISI Foundation, Torino, Italy
'''
from models.mobility import truncated_levy_walk, truncated_levy_walk_with_fix_initial_positions
import numpy as np
import logging
import sys
import argparse


logging.basicConfig(format='%(asctime)-15s - %(message)s', level=logging.INFO)
logger = logging.getLogger("simulation")


def getArguments():
    '''
    Return the arguments paased to the file


    Required arguments:

    keyword arguments:

    '''
    parser = argparse.ArgumentParser(description='Generate a mobility file using the Truncated-Levy-Walk model.')
    parser.add_argument('--steps', dest='steps_per_second', type=int, default=15,
                        help='Steps per second (default: 15)')
    parser.add_argument('--width', dest='map_width', type=int, default=100,
                        help='Map Width (default: 100)')
    parser.add_argument('--height', dest='map_height', type=int, default=100,
                        help='Map Height (default: 100)')
    parser.add_argument('--nodes', dest='nr_nodes', type=int, default=200,
                        help='Number Of Nodes (default: 200)')
    parser.add_argument('--time', dest='simtime', type=int, default=60*100,
                        help='Simulation Time in Seconds (default: 100 minutes)')
    parser.add_argument('--out', dest='filename', type=str, default="output.txt",
                        help='Output file')
    parser.add_argument('--positions', dest='positionsFile', type=str, help="Initia node positions")

    args = parser.parse_args()
    return args


def read_positions(positionsFile):
    pass


def generateMobility(positions, outputFile, sps=15, nr_nodes=200, map_x=100, map_y=100, sim_time=6000):
    np.random.seed(0xffff)
    # Truncated Levy-Walk model, FL_EXP=-3.9 is way to "force" the fligth
    # length to a value close to 1.4 m/s (prefered human walk speed)
    if positions:
        rw = truncated_levy_walk_with_fix_initial_positions(nr_nodes,
                                                            dimensions=(map_x, map_y),
                                                            positions=positions, FL_EXP=-3.9)
    else:
        rw = truncated_levy_walk(nr_nodes, dimensions=(map_x, map_y), FL_EXP=-3.9)
    step_time = 1. / float(sps)

    with open(outputFile, 'w') as f:
        f.write('%d\n' % nr_nodes)
        f.write('%f\n' % step_time)
        for step in range(0, sim_time*sps):
            xy = rw.next()
            if step % (sps*60*10) == 0:
                logger.info('Simulation Time %s minutes' % (step / (sps*60)))

            for idx, (x, y) in enumerate(xy):
                f.write('%f %f\n' % (x, y))
                # f.write('%d,%f,%f,%f\n' % (idx, step_time*step, x, y))

    pass

if __name__ == '__main__':
    args = getArguments()
    positions = read_positions(args.positionsFile) if args.positionsFile else None
    generateMobility(args.steps_per_second, args.nr_nodes,
                     args.map_width, args.map_height,
                     args.simtime, positions, args.filename)
