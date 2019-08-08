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


def getArgs():
  p = argparse.ArgumentParser(
      description='Adhoc network with two Points of Interest (PoI) and N nodes. \
      Initially, nodes move in a random way within the communication area. \
      After a while, N/2 nodes walk towards one PoI and the remaining nodes \
      follow the second PoI.')
  p.add_argument(
      '--cma-length', dest='area_l', type=int, default=100,
      help='communication area length')
  p.add_argument(
      '--cma-width', dest='area_w', type=int, default=100,
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
    self.rand_model = self.getRandomWaypointInstance()

  def setModelsOfAttraction(self, nodesAt1stPoI, posAt1stPoI, nodesAt2ndPoI, posAt2ndPoI):
    self.first_model = reference_point_group(
        nodesAt1stPoI, (self.length / 2, self.width), aggregation=AGGREGATION, initial_position=posAt1stPoI)
    self.second_model = reference_point_group(
        nodesAt2ndPoI, (self.length / 2, self.width), aggregation=AGGREGATION, initial_position=posAt2ndPoI)

  def getStepTowardsPoI(self, is1stGroup=True):
    return [(p[0], p[1]) for p in next(self.first_model)] if is1stGroup else \
        [(p[0] + (self.length / 2.), p[1]) for p in next(self.second_model)]

  def updateNodePositions(self, atWholeNet=True):
    self.positions = next(self.rand_model) if atWholeNet else \
        self.getStepTowardsPoI() + self.getStepTowardsPoI(is1stGroup=False)

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
  # intialise models towards 2 PoI
  posAt1stGroup, posAt2ndGroup = [], []
  for p in network.positions:
    l = posAt1stGroup if p[0] <= (network.length / 2.) else posAt2ndGroup
    l.append((p[0], p[1]))
    network.setModelsOfAttraction(
        len(posAt1stGroup), posAt1stGroup, len(posAt2ndGroup), posAt2ndGroup)
  # plot snapshots where nodes move towards PoI
  while i < args.rand_steps + args.poi_steps:
    network.updateNodePositions(atWholeNet=False)
    plotSnapshot(i, network.positions, (args.area_l, args.area_w))
    for j in range(0, len(network.positions)):
      history[j].append((network.positions[j][0], network.positions[j][1]))
    i = i + 1
  # overwrite random model specifiying nodes poisitions
  network.rand_model = network.getRandomWaypointInstance(
      initial_positions=network.positions)
  # plot snapshots where nodes move (again) in a random way
  while i < 2 * args.rand_steps + args.poi_steps:
    network.updateNodePositions(atWholeNet=True)
    plotSnapshot(i, network.positions, (args.area_l, args.area_w))
    for j in range(0, len(network.positions)):
      history[j].append((network.positions[j][0], network.positions[j][1]))
    i = i + 1
  # create trace of positions and store them in a file
  with open('spacial-gravity.bm', 'a') as f:
    f.write('\n')
    for i in range(0, args.nodes):
      l = ''
      for j in range(0, len(history[i])):
        l = '{}{} {} {} '.format(l, j, history[i][j][0], history[i][j][1])
      f.write('{}\n'.format(l))
