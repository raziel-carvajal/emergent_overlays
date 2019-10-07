#!/usr/bin/python
import argparse
import json
import networkx as nx
import utils_for_traces as utils
import xml.etree.ElementTree as ET
from pymobility.models.mobility import random_waypoint


def getArgs():
  p = argparse.ArgumentParser(
      description='creates a mobility trace of a wireless topology with \
			2 zones (dense and sparse)')
  # options of communication area
  p.add_argument(
      '--cma-length', dest='area_l', type=int, default=100,
      help='communication area length')
  p.add_argument(
      '--cma-width', dest='area_w', type=int, default=100,
      help='communication area width')
  p.add_argument(
      '--dense-area-length', dest='dense_area_l', type=int, default=40,
      help='dense area length')
  p.add_argument(
      '--dense-area-width', dest='dense_area_w', type=int, default=15,
      help='dense area width')
  # number of nodes per area
  p.add_argument(
      '--nodes-at-dense', dest='nodes_at_dense', type=int, default=50,
      help='')
  p.add_argument(
      '--nodes-at-sparse', dest='nodes_at_sparse', type=int, default=50,
      help='')
  #
  p.add_argument(
      '--transmission-range', dest='tx', type=int, default=10,
      help='transmission range of each node')
  p.add_argument(
      '--trace-size', dest='trace_size', type=int, default=50,
      help='number of wireless topologies formed every time nodes move')
  return p.parse_args()


class CommunicationArea:
  def __init__(self, nodes, cmaDim, denseAdim, nodesPerArea):
    self.length = cmaDim['len']
    self.width = cmaDim['wid']
    self.center = {
        'x': float("%.3f" % (cmaDim['len'] / 2.0)),
        'y': float("%.3f" % (cmaDim['wid'] / 2.0))}
    self.denseAlen = float("%.3f" % (denseAdim['len']))
    self.denseAwid = float("%.3f" % (denseAdim['wid']))

    # sparse area contains four subregions
    self.nodesAtSubA = nodesPerArea['sparse'] / 4
    self.nodesRem = nodesPerArea['sparse'] % 4
    self.nodesAtDenseA = nodesPerArea['dense']

    self.sparseSubAlen = float("%.3f" % ((self.length - self.denseAlen) / 2.0))
    self.sparseSubAwid = float("%.3f" % ((self.width - self.denseAwid) / 2.0))
    self.subAreas = [
        {'id': 1, 'x': 0, 'y': 0, 'verSubArea': True, 'isDense': False,
         'nodesNo': self.nodesAtSubA + self.nodesRem},
        {'id': 2, 'x': self.sparseSubAlen, 'y': 0, 'verSubArea': False,
         'isDense': False, 'nodesNo': self.nodesAtSubA},
        {'id': 3, 'x': self.sparseSubAlen + self.denseAlen, 'y': 0,
         'verSubArea': True, 'isDense': False, 'nodesNo': self.nodesAtSubA},
        {'id': 4, 'x': self.sparseSubAlen, 'y': self.sparseSubAwid + self.denseAwid,
         'verSubArea': False, 'isDense': False, 'nodesNo': self.nodesAtSubA},
        {'id': 5, 'x': self.sparseSubAlen, 'y': self.sparseSubAwid,
         'verSubArea': False, 'isDense': True, 'nodesNo': self.nodesAtDenseA}]


def makeStep(mobMod, incrAt, lastPosition, atDenseZone):
  positions = {}
  coords = [(k[0] + incrAt['x'], k[1] + incrAt['y']) for k in next(mobMod)]
  for c in coords:
    positions[lastPosition] = {'x': c[0],
                               'y': c[1], 'atDenseZone': atDenseZone}
    lastPosition += 1
  return positions


def generateWirelessTopologies(cma, topNo, Tx):
  mobModels = {}
  # new instance of mobility model per sub area
  for subArea in cma.subAreas:
    if subArea['isDense']:
      areaDim = (cma.denseAlen, cma.denseAwid)
      velocity = (MIN_LOW_VELOCITY, MAX_LOW_VELOCITY)
    else:
      leng = cma.sparseSubAlen if subArea['verSubArea'] else cma.denseAlen
      widt = cma.width if subArea['verSubArea'] else cma.sparseSubAwid
      areaDim = (leng, widt)
      velocity = (MIN_HIG_VELOCITY, MAX_HIG_VELOCITY)
    mobModels[subArea['id']] = random_waypoint(
        subArea['nodesNo'], areaDim, velocity=velocity)
  #
  for index in range(0, topNo):
    nodeId, positions = 1, {}
    # iter in order to have every position identified in an unique way
    for i in range(0, len(cma.subAreas)):
      subArea = cma.subAreas[i]
      mobModel = mobModels[subArea['id']]
      incrAt = {'x': subArea['x'], 'y': subArea['y']}
      coords = makeStep(mobModel, incrAt, nodeId, subArea['isDense'])
      nodeId += len(coords)
      positions.update(coords)
    # source node is positioned at the center of communication area
    positions[nodeId] = {
        'x': cma.center['x'], 'y': cma.center['y'], 'atDenseZone': True}
    posAsAr = range(0, len(positions))
    inPoi, notInPoi = [], []
    for k in positions.iterkeys():  # keys start at 1
      posAsAr[k - 1] = (positions[k]['x'], positions[k]['y'])
      temp = inPoi if positions[k]['atDenseZone'] else notInPoi
      temp.append(k)
    #
    POI_POS[index]['dense'], POI_POS[index]['sparse'] = inPoi, notInPoi
    utils.updateGraph(G, posAsAr, TX)
    largestCoCom = max(nx.connected_components(G), key=len)
    COMPONENTS[index] = [n for n in largestCoCom]
    # update dictionary of neighbors
    NBRS[index] = {n: G.neighbors(n) for n in largestCoCom}
    # plot snapshots of network
    utils.plotSnapshot(G, index, posAsAr, (ARGS.area_l, ARGS.area_w))
    # update HISTORY of positions
    utils.updateHistory(HISTORY, posAsAr)


MIN_LOW_VELOCITY, MAX_LOW_VELOCITY = 0.1, 1.0
MIN_HIG_VELOCITY, MAX_HIG_VELOCITY = 1.5, 2.0
NBRS, COMPONENTS = {}, {}
ARGS = getArgs()
N = ARGS.nodes_at_dense + ARGS.nodes_at_sparse
HISTORY = {i: [] for i in range(0, N + 1)}
POI_POS = {i: {'dense': [], 'sparse': []} for i in range(0, N + 1)}
TX = ARGS.tx
G = nx.Graph()
SRC_NODES = ET.Element('root')


if __name__ == '__main__':
  cma = {'len': ARGS.area_l, 'wid': ARGS.area_w}
  densA = {'len': ARGS.dense_area_l, 'wid': ARGS.dense_area_w}
  nodesPerArea = {'dense': ARGS.nodes_at_dense, 'sparse': ARGS.nodes_at_sparse}
  #
  comArea = CommunicationArea(N, cma, densA, nodesPerArea)
  generateWirelessTopologies(comArea, ARGS.trace_size, TX)
  # store trace of possition in BonnMotion format
  utils.storeTrace('trace.bm', HISTORY)
  # store attributes of each snapshot
  graphInfo = {}
  for i in range(1, ARGS.trace_size):  # 1st position is ignored in experiments
    graphInfo[i] = {
        'bigestComponent': COMPONENTS[i],
        'componentSize': len(COMPONENTS[i]),
        'neighbors': NBRS[i],
        'nodesAtDense': POI_POS[i]['dense'],
        'nodesAtSparse': POI_POS[i]['sparse'],
        'srcNode': N + 1}
    # unique source node for the whole trace
    ET.SubElement(
        SRC_NODES, 'SourceNode', attrib={'id': str(N + 1), 'time': str(i)})
  with open('network_metadata.json', 'w') as f:
    json.dump(graphInfo, f)
    tree = ET.ElementTree(SRC_NODES)
    tree.write('source_nodes.xml')
