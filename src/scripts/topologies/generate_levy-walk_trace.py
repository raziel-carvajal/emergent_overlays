#!/usr/bin/python
from argparse import ArgumentParser
from pymobility.models.mobility import random_direction


def getPositions(args, motionModel):
    return [(p[0], p[1]) for p in next(motionModel)]


def storePositions(positions, walks, nodes, areaLen):
    with open("levy-walk_%d_%d-X-%d.dataset" % (nodes, areaLen, areaLen), 'w') as f:
        f.write('nodeId time x y\n')  # dataset header
        for w in range(0, walks):
            for iD in range(1, len(positions) + 1):
                x = positions[iD][w]['x']
                y = positions[iD][w]['y']
                t = positions[iD][w]['time']
                line = "%d %f %f %f \n" % (iD, t, x, y)
                f.write(line)


def getArgs():
    p = ArgumentParser(
        description='Generates mobility trace where nodes perform Levy walks (BonnMotion format).')
    p.add_argument('--area-len', dest='area', type=float, default=10.0)
    p.add_argument('--nodes-no', dest='nodes', type=int, default=10)
    p.add_argument('--wireless-topologies-no', dest='wtn', type=int, default=10)
    p.add_argument('--min-velocity', dest='minv', type=float, default=0.0)
    p.add_argument('--max-velocity', dest='maxv', type=float, default=1.0)
    p.add_argument('--waiting-time', dest='wtime', type=float, default=0.1)
    return p.parse_args()


if __name__ == '__main__':
    args = getArgs()
    motionModel = random_direction(
        args.nodes, (args.area, args.area), wt_max=args.wtime,
        velocity=(args.minv, args.maxv), border_policy='reflect')
    nodesPositions = {}
    for n in range(1, args.nodes + 1):
        nodesPositions[n] = []
    for i in range(0, args.wtn):
        n = 1
        for p in getPositions(args, motionModel):
            nodesPositions[n].append(
                {'x': p[0], 'y': p[1], 'time': i * args.wtime})
            n = n + 1
    storePositions(nodesPositions, args.wtn, args.nodes, args.area)
