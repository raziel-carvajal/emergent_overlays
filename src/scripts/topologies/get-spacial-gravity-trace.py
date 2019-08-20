#!/usr/bin/python
import os
import math
import argparse
import networkx as nx
import matplotlib.pyplot as plt
from pymobility.models.mobility import reference_point_group
from pymobility.models.mobility import random_waypoint
#
G = nx.Graph()
AGGREGATION = .5
PARTITIONS = 4


def getArgs():
  p = argparse.ArgumentParser(
      description='Creates a mobility trace of an adhoc network with three \
      Points of Interest (PoI) and N nodes. Initially, nodes move in a random \
      way within the communication area. After a while, a quarter of the nodes \
      remain moving randomly and the rest of nodes walk towards every PoI and \
      the remaining nodes follow the second PoI.')
  p.add_argument(
      '--cma-length', dest='area_l', type=int, default=90,
      help='communication area length')
  p.add_argument(
      '--cma-width', dest='area_w', type=int, default=45,
      help='communication area width')
  p.add_argument(
      '--nodes', dest='nodes', type=int, default=100,
      help='number of nodes in the network')
  p.add_argument(
      '--random-steps', dest='rand_steps', type=int, default=10,
      help='number of random walks that all nodes perform')
  p.add_argument(
      '--steps-towards-poi', dest='poi_steps', type=int, default=20,
      help='number of walks towards every PoI')
  return p.parse_args()


def plotSnapshot(snapshotId, positions, dimensions):
  posMap = {}
  k = 1
  for p in positions:
    posMap[k] = [p[0], p[1]]
    k = k + 1
  plt.subplot(111)
  plt.xlim((0, dimensions[0]))
  plt.ylim((0, dimensions[1]))
  nx.draw_networkx(G, pos=posMap, node_size=10, with_labels=False)
  plt.savefig('snapshot{}.pdf'.format(snapshotId))
  plt.clf()


class CommunicationArea(object):
  def __init__(self, length, width, nodes):
    self.length = length
    self.width = width
    self.nodes = nodes
    self.subAreaLen = length / 2.0
    self.subAreaWid = width / 2.0
    self.subAreaOrigins = [(0, 0), (self.subAreaLen, 0),
                           (0, self.subAreaWid)]
    self.partitionsSize = [nodes / PARTITIONS] * PARTITIONS
    self.rand_model = self.getRandomWaypointInstance()

  def setModelsAtSubAreas(self, partitions):
    self.groupModels = [
        random_waypoint(
            len(partitions[0]), (self.length, self.width), initial_position=partitions[0]
        )
    ]
    self.groupModels.extend([
        reference_point_group(
            len(partitions[p]), (self.subAreaLen, self.subAreaWid),
            aggregation=AGGREGATION, initial_position=partitions[p]
        ) for p in range(1, len(partitions) - 1)
    ])
    self.groupModels.extend([
        reference_point_group(
            len(partitions[3]), (self.length, self.subAreaWid),
            aggregation=AGGREGATION, initial_position=partitions[3]
        )
    ])

  def makeStepAtSubareas(self, is1stGroup=True):
    # 25% of nodes move in a random way
    temp = [(p[0], p[1]) for p in next(self.groupModels[0])]
    # the rest of the nodes move within their PoI
    m = 1
    for origin in self.subAreaOrigins:
      temp.extend([
          (p[0] + origin[0], p[1] + origin[1]) for p in next(self.groupModels[m])
      ])
      m = m + 1
    return temp

  def updateNodePositions(self, atWholeNet=True):
    self.positions = [(p[0], p[1]) for p in next(self.rand_model)] if atWholeNet else \
        self.makeStepAtSubareas()

  def getRandomWaypointInstance(self, initial_positions=[]):
    return random_waypoint(self.nodes, (self.length, self.width), initial_position=initial_positions)


if __name__ == '__main__':
  args = getArgs()
  network = CommunicationArea(args.area_l, args.area_w, args.nodes)
  traceSize = args.rand_steps + args.poi_steps
  # create a graph of N nodes
  G.add_nodes_from(range(1, args.nodes + 1))
  history = {}
  for i in range(0, args.nodes):
    history[i] = []
  i = 0
  # plot snapshots of the network where nodes move in a random way
  while i < args.rand_steps:
    network.updateNodePositions(atWholeNet=True)
    plotSnapshot(i, network.positions, (args.area_l, args.area_w))
    # update history of positions
    for j in range(0, len(network.positions)):
      history[j].append((network.positions[j][0], network.positions[j][1]))
    i = i + 1
  # get instances of a mobility model where nodes move towards PoI
  j = 0
  partitions = []
  for p in range(0, PARTITIONS):
    partitions.append([])
    for _ in range(0, network.partitionsSize[p]):
      partitions[p].append(network.positions[j])
      j = j + 1
  network.setModelsAtSubAreas(partitions)
  # plot snapshots of such network
  while i < args.rand_steps + args.poi_steps:
    network.updateNodePositions(atWholeNet=False)
    plotSnapshot(i, network.positions, (args.area_l, args.area_w))
    for j in range(0, len(network.positions)):
      history[j].append((network.positions[j][0], network.positions[j][1]))
    i = i + 1
  # overwrite random model specifiying the latest nodes positions
  network.rand_model = network.getRandomWaypointInstance(
      initial_positions=network.positions)
  # plot snapshots where nodes move (again) in a random way
  while i < 2 * args.rand_steps + args.poi_steps:
    network.updateNodePositions(atWholeNet=True)
    plotSnapshot(i, network.positions, (args.area_l, args.area_w))
    for j in range(0, len(network.positions)):
      history[j].append((network.positions[j][0], network.positions[j][1]))
    i = i + 1
  # store trace of possition in BonnMotion format
  with open('spacial-gravity.bm', 'a') as f:
    f.write('\n')
    for i in range(0, args.nodes):
      l = ''
      for j in range(0, len(history[i])):
        l = '{}{} {} {} '.format(l, j, history[i][j][0], history[i][j][1])
      f.write('{}\n'.format(l))
