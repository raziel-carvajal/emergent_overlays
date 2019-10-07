#!/usr/bin/python
import argparse
import json
import networkx as nx
import utils_for_traces as utils
import xml.etree.ElementTree as ET
from pymobility.models.mobility import reference_point_group, random_waypoint


def getArgs():
  p = argparse.ArgumentParser(
      description='Creates a mobility trace of an adhoc network with one \
      Point of Interest (PoI) and N nodes. Initially, nodes move in a random \
      way within the communication area. After a while, half of the nodes \
      remain moving randomly and the rest of nodes walk towards the PoI. \
      Finally, all nodes move (again) in a random way.')
  p.add_argument(
      '--cma-length', dest='area_l', type=int, default=90,
      help='Length of communication area.')
  p.add_argument(
      '--cma-width', dest='area_w', type=int, default=45,
      help='Width of communication area.')
  p.add_argument(
      '--nodes', dest='nodes', type=int, default=500,
      help='Number of nodes in the network.')
  p.add_argument(
      '--transmission-range', dest='tx', type=int, default=5,
      help='node transmission range')
  p.add_argument(
      '--walks', dest='walks', type=int, default=10,
      help='Number of times nodes change their position. If W is this number of \
      walks, the whole trace contains a total of 4W changes of position (2W \
      random walks and 2W walks towards the unique point of interest).')
  return p.parse_args()


class CommunicationArea(object):
  def __init__(self, length, width, nodes):
    self.length = length
    self.width = width
    self.nodes = nodes
    self.models = {'unique': self.getRandomWaypointInstance(), 'combined': []}

  def getRandomWaypointInstance(self, nodesFrac=1.0, initial_positions=[]):
    return random_waypoint(
        int(self.nodes * nodesFrac), (self.length, self.width),
        initial_position=initial_positions)

  def updateNodePositions(self, isUniqueModel=True):
    self.positions = next(self.models['unique']) if isUniqueModel \
        else self.makeStepInCombinedModel()

  def setCombinedModel(self, positions):
    _1stHalf = [(positions[p][0], positions[p][1])
                for p in range(0, len(positions) / 2)]
    _2ndHalf = [(positions[p][0], positions[p][1])
                for p in range(len(positions) / 2, len(positions))]
    self.models['combined'].append(
        self.getRandomWaypointInstance(nodesFrac=0.5, initial_positions=_1stHalf))
    self.models['combined'].append(
        reference_point_group(
            len(_2ndHalf), (self.length, self.width),
            aggregation=AGGREGATION, initial_position=_2ndHalf))

  def makeStepInCombinedModel(self, is1stGroup=True):
    temp = [(p[0], p[1]) for p in next(self.models['combined'][0])]
    temp.extend([(p[0], p[1]) for p in next(self.models['combined'][1])])
    return temp


AGGREGATION = .2
COMPONENTS, NBRS = {}, {}
ARGS = getArgs()
HISTORY = {i: [] for i in range(0, ARGS.nodes)}
TX = ARGS.tx
TRACE_LEN = 4 * ARGS.walks
CM = utils.ComponentMatrix(ARGS.nodes, TRACE_LEN)
G = nx.Graph()
SRC_NODES = ET.Element('root')

if __name__ == '__main__':
  network = CommunicationArea(ARGS.area_l, ARGS.area_w, ARGS.nodes)
  for i in range(0, TRACE_LEN):
    if i >= ARGS.walks and i < 3 * ARGS.walks:
      if i == ARGS.walks:
        network.setCombinedModel(network.positions)
      network.updateNodePositions(isUniqueModel=False)
    else:
      if i == 3 * ARGS.walks:
        # overwrite random model specifiying the latest nodes positions
        network.models['unique'] = network.getRandomWaypointInstance(
            initial_positions=network.positions)
      network.updateNodePositions(isUniqueModel=True)
    # update vertex/edges of graph with the latest set of positions
    utils.updateGraph(G, network.positions, TX)
    # add the largest component in G
    largestCoCom = max(nx.connected_components(G), key=len)
    CM.appendComponent(largestCoCom)
    COMPONENTS[i] = [n for n in largestCoCom]
    # update dictionary of neighbors
    NBRS[i] = {n: G.neighbors(n) for n in largestCoCom}
    # plot snapshots of network
    utils.plotSnapshot(G, i, network.positions, (ARGS.area_l, ARGS.area_w))
    # update HISTORY of positions
    utils.updateHistory(HISTORY, network.positions)
  # store trace of possition in BonnMotion format
  utils.storeTrace('trace.bm', HISTORY)
  # store attributes of each snapshot
  graphInfo = {}
  sources = CM.getSourceNodes()
  for i in range(1, TRACE_LEN):  # 1st position is ignored in experiments
    graphInfo[i] = {
        'bigestComponent': COMPONENTS[i],
        'componentSize': len(COMPONENTS[i]),
        'neighbors': NBRS[i],
        'srcNode': sources[i]}
    ET.SubElement(
        SRC_NODES, 'SourceNode', attrib={'id': str(sources[i]), 'time': str(i)})
  with open('network_metadata.json', 'w') as f:
    json.dump(graphInfo, f)
  tree = ET.ElementTree(SRC_NODES)
  tree.write('source_nodes.xml')
