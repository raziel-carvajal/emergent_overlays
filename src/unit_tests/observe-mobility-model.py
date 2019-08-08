#!/usr/bin/python
import os
import math
import argparse
import networkx as nx
# import itertools as iterT
import matplotlib.pyplot as plt
from pymobility.models.mobility import reference_point_group as mobility_model


def getArgs():
  p = argparse.ArgumentParser(
      description='Plot snapshots of a dynamic system where nodes follow a \
      unique mobility model')
  p.add_argument(
      '--cma-length', dest='area_l', type=int, default=100,
      help='communication area length')
  p.add_argument(
      '--cma-width', dest='area_w', type=int, default=100,
      help='communication area width')
  p.add_argument(
      '--nodes', dest='nodes', type=int, default=100,
      help='number of nodes in the system')
  p.add_argument(
      '--trace-size', dest='trace_size', type=int, default=100,
      help='number of snapshots')
  return p.parse_args()


def plotSnapshot(snapshotId, graph, positions, xlim, ylim):
  posMap = {}
  k = 1
  for p in positions:
    posMap[k] = [p[0], p[1]]
    k = k + 1
  plt.subplot(111)
  plt.xlim((0, xlim))
  plt.ylim((0, ylim))
  nx.draw_networkx(graph, pos=posMap, node_size=10, with_labels=False)
  plt.savefig('snapshot{}.pdf'.format(snapshotId))
  plt.clf()


if __name__ == '__main__':
  args = getArgs()
  l = [(p, p) for p in range(0, args.nodes)]
  m = mobility_model(args.nodes, (args.area_l, args.area_w),
                     aggregation=1.0)
  s = 1
  # plot ${args.trace_size} snapshots
  g = nx.Graph()
  # create a graph of N nodes
  g.add_nodes_from(range(1, args.nodes + 1))
  while s < args.trace_size:
    # every node perform one step
    pos = [(p[0], p[1]) for p in next(m)]
    # plot snapshot
    plotSnapshot(s, g, pos, args.area_l, args.area_w)
    s = s + 1
