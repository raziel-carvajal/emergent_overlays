#!/usr/bin/python
import os
import math
import argparse
import networkx as nx
import matplotlib.pyplot as plt
from pymobility.models.mobility import random_waypoint

# an undirected graph represents every snapshot of the adhoc network
G = nx.Graph()
# nodes transmission range
TX = None
# number of nodes in network
NODES = None


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


def getDistance(a, b):
  return math.sqrt(math.pow(a[0] - b[0], 2) + math.pow(a[1] - b[1], 2))


def plotSnapshot(snapshotId, positions, dimensions):
  posMap = {}
  k = 0
  for p in positions:
    posMap[k] = [p[0], p[1]]
    k = k + 1
  plt.subplot(111)
  plt.xlim((0, dimensions[0]))
  plt.ylim((0, dimensions[1]))
  nx.draw_networkx(G, pos=posMap, node_size=5, with_labels=False)
  plt.savefig('snapshot{}.pdf'.format(snapshotId))
  plt.clf()


def updateGraph(coords):
  edges = []
  for n in range(0, NODES):
    a = coords[n]
    others = range(0, NODES)
    others.remove(n)
    for m in others:
      b = coords[m]
      if getDistance(a, b) <= TX:
        edges.append((n, m))
  G.add_edges_from(edges, attr_dict=None)


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


if __name__ == '__main__':
  args = getArgs()
  NODES = args.nodes
  TX = args.tx
  G.add_nodes_from(range(0, NODES))
  area = CommunicationArea(args.area_l, args.area_w)
  area.updateNodePositions()
  updateGraph(area.coords)
  plotSnapshot('test', area.coords, (area.length, area.width))
