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
import logging
import argparse
import models.mobility as mb

logging.basicConfig(format='%(asctime)-15s - %(message)s', level=logging.INFO)
logger = logging.getLogger("mobility-generator")


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


def generateMobility(positions, outputFile, sps=15, nr_nodes=200, map_x=100, map_y=100, sim_time=6000, mobility_map=None, testValidPosition=None, test=lambda p: True):
    assert mobility_map is None or len(mobility_map) == len(positions)
    # np.random.seed(0xffff)
    # Truncated Levy-Walk model, FL_EXP=-3.9 is way to "force" the fligth
    # length to a value close to 1.4 m/s (prefered human walk speed)

    # rw = mb.tvc(nr_nodes, dimensions=(map_x, map_y), positions=positions)
    # rw = mb.reference_point_group(nr_nodes, dimensions=(map_x, map_y), positions=positions)
    # rw = mb.gauss_markov(nr_nodes, dimensions=(map_x, map_y), positions=positions)
    # rw = mb.random_walk(nr_nodes, dimensions=(map_x, map_y), positions=positions)
    # rw = mb.random_direction(nr_nodes, dimensions=(map_x, map_y), positions=positions)
    # rw = mb.heterogeneous_truncated_levy_walk(nr_nodes, dimensions=(map_x, map_y), positions=positions, FL_EXP=-3.9)

    # rw = mb.truncated_levy_walk(nr_nodes, dimensions=(map_x, map_y), positions=positions, FL_EXP=-3.9)

    rw = mb.HeterogeneousRandomWalk(map_x, map_y, nr_nodes, 3, Variance1_Circle=0.1, Variance2=0.8)
    step_time = 1. / float(sps)

    lastValidxy = [p for p in positions]

    with open(outputFile, 'w') as f:
        f.write('%d\n' % (len(positions)))
        f.write('%f\n' % step_time)
        connected = True
        for (x, y) in lastValidxy:
            f.write('%f %f\n' % (x, y))

        counter = 0
        times = 0.0
        before = 0.0
        for step in range(0, sim_time*sps):
            now = float(step)/float(sps)
            xy = rw.next()
            # keep static nodes in their position
            if mobility_map is not None:
                xy = [ xy[ii] if mobility_map[ii] else positions[ii] for ii in range(0, len(mobility_map)) ]


            for (idx, point) in enumerate(xy):
                if testValidPosition is None or testValidPosition((idx, xy[idx])):
                    lastValidxy[idx] = [e for e in xy[idx]]

            b = test(xy)
            if not b:
                if connected:
                    counter += 1
                    print "black zone => {0}".format(now)
                    before = now
                connected = False
            else:
                if not connected:
                    e = now - before
                    times += e
                    print "entering white zone at {0}s (we are in a blackout for {1}s)".format(now, e)
                connected = True

            if step % (sps*60*10) == 0:
                logger.info('Simulation Time %s minutes' % (step / (sps*60)))


            # connected = True
            if connected:
            # if connected:
                for (x, y) in lastValidxy:
                    f.write('%f %f\n' % (x, y))

        if not connected:
            times += (float(sim_time)) - before
            print "white zone => {0}".format(sim_time)

        if counter > 0:
            print "The time disconnected was {0} s with mean {1}s  and there were {2} disconnections".format(times, times/counter, counter)
        else:
            print "No time disconnected"
    return True

if __name__ == '__main__':
    args = getArguments()
    positions = read_positions(args.positionsFile) if args.positionsFile else None
    generateMobility(args.steps_per_second, args.nr_nodes,
                     args.map_width, args.map_height,
                     args.simtime, positions, args.filename)
