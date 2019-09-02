#!/usr/bin/python
import os
import math
import argparse
import networkx as nx
import matplotlib.pyplot as plt
from pymobility.models.mobility import random_waypoint
from utils_for_traces import plotSnapshot, updateGraph


def getArgs():
  p = argparse.ArgumentParser(
      description='Adhoc network where the communication area contains two regions \
      with the same area and same number of nodes. Nodes move within each region in \
      a random way (following random waypoint model).')
  p.add_argument('--cma-length', dest='area_l', type=int, default=90,
                 help='communication area length')
  p.add_argument('--cma-width', dest='area_w', type=int, default=45,
                 help='communication area width')
  p.add_argument('--nodes', dest='nodes', type=int, default=500,
                 help='number of nodes in the network')
  p.add_argument('--trace-size', dest='tz', type=int, default=10,
                 help='number of network snapshots')
  p.add_argument('--transmission-range', dest='tx', type=int, default=5,
                 help='node transmission range')
  return p.parse_args()


class CommunicationArea(object):
  def __init__(self, length, width):
    self.length = length
    self.width = width
    dimensions = (length / 2., width)
    self._1stRegion = random_waypoint(NODES / 2, dimensions)
    self._2ndRegion = random_waypoint(NODES / 2, dimensions)

  def updateNodePositions(self):
    self.coords = []
    self.coords.extend([(p[0], p[1]) for p in next(self._1stRegion)])
    self.coords.extend([(p[0] + (self.length / 2.),  p[1])
                        for p in next(self._2ndRegion)])


# get inputs
ARGS = getArgs()
# nodes transmission range
TX = ARGS.tx
# number of nodes in network
NODES = ARGS.nodes
# an undirected graph represents every snapshot of the adhoc network
G = nx.Graph()
if __name__ == '__main__':
  history = {}
  area = CommunicationArea(ARGS.area_l, ARGS.area_w)
  traceNo = 0
  # create ${ARGS.tz} snapshots of the netowk
  while traceNo < ARGS.tz:
    area.updateNodePositions()
    updateGraph(G, area.coords, TX)
    if nx.is_connected(G):  # keep only connected components
      history[traceNo] = [(p[0], p[1]) for p in area.coords]
      plotSnapshot(traceNo, area.coords, (area.length, area.width))
      traceNo = traceNo + 1
  # store nodes 1st position
  with open('bipartite-scenario-1st-position', mode='a') as f:
    l = ''
    for p in history[0]:
      l = '{}{},{} '.format(l, p[0], p[1])
    f.write('{}\n'.format(l))
  # store trace in BonnMotion format
  with open('bipartite-scenario.bm', 'a') as f:
    f.write('\n')
    for n in range(0, NODES):
      l = ''
      for t in range(0, traceNo):
        l = '{}{} {} {} '.format(l, t, history[t][n][0], history[t][n][1])
      f.write('{}\n'.format(l))
