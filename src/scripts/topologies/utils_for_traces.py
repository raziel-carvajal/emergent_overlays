import math
import networkx as nx
import matplotlib.pyplot as plt


def plotSnapshot(g, snapshotId, positions, dimensions):
  posMap = {}
  k = 1
  for p in positions:
    posMap[k] = [p[0], p[1]]
    k = k + 1
  plt.subplot(111)
  plt.xticks(range(0, dimensions[0] + 5, 5))
  plt.xlim((0, dimensions[0]))
  plt.yticks(range(0, dimensions[1] + 5, 5))
  plt.ylim((0, dimensions[1]))
  nx.draw_networkx(
      g, pos=posMap, node_size=40, with_labels=True, font_size=6,
      node_shape='s', linewidths=0.5
  )
  plt.savefig('snapshot{}.pdf'.format(snapshotId))
  plt.clf()


def updateHistory(history, positions):
  for j in range(0, len(positions)):
    history[j].append((positions[j][0], positions[j][1]))


def storeTrace(fileName, history):
  with open(fileName, 'w') as f:
    f.write('\n')
    for i in range(0, len(history)):
      l = ''
      for j in range(0, len(history[i])):
        l = '{}{} {} {} '.format(l, j, history[i][j][0], history[i][j][1])
      f.write('{}\n'.format(l))


def storeRoutingInfo(fileName, data):
  with open(fileName, 'w') as f:
    f.write('src, dst, hopsNo, path, topologyID\n')
    for topId, routingInfo in data.iteritems():
      for srcId, destinations in routingInfo.iteritems():
        for dst, path in destinations.iteritems():
          if srcId != dst:
            f.write('{}, {}, {}, {}, {}\n'.format(
                srcId, dst, len(path) - 1, str(path).replace(', ', '-'), topId))


def storeNeigsCardinality(fileName, data, nodesNo):
  with open(fileName, 'w') as f:
    for nodeId in range(nodesNo):
      tmp = []
      for topId in data.keys():
        tmp.append(data[topId][nodeId])
      pathStr = str(tmp).replace('[', '')
      pathStr = pathStr.replace(']', '')
      f.write('{}\n'.format(pathStr))


def getDistance(a, b):
  return math.sqrt(math.pow(a[0] - b[0], 2) + math.pow(a[1] - b[1], 2))


def updateGraph(g, coords, tx):
  nodes = range(1, len(coords) + 1)
  edges = []
  for n in nodes:
    a = coords[n - 1]
    others = range(1, len(nodes) + 1)
    others.remove(n)
    distances = sorted([(getDistance(a, coords[m - 1]), m) for m in others])
    i = 0
    while distances[i][0] <= tx:
      edges.append((n, distances[i][1]))
      i = i + 1
  g.clear()
  g.add_nodes_from(nodes)
  g.add_edges_from(edges, attr_dict=None)


class ComponentMatrix(object):
  def __init__(self, nodes, components):
    self.nodes = nodes
    self.components = components
    self.latestComp = 0
    self.matrix = []
    for _ in range(0, self.nodes):
      self.matrix.append([0] * components)

  def appendComponent(self, component):
    if self.latestComp == self.components:
      return False
    for n in component:
      self.matrix[n - 1][self.latestComp] = 1
    self.latestComp = self.latestComp + 1
    return True

  def getSourceNodes(self):
    actualSrcNo = [(self.matrix[n].count(1), n + 1)
                   for n in range(0, self.nodes)]
    actualSrcNo.sort(reverse=True)
    n = actualSrcNo[0][1]
    if actualSrcNo[0][0] == self.components:
      # best scenario, node ${n} appears on every component
      sources = [n] * self.components
    else:
      sources = [None] * self.components
      allIndex = range(0, self.components)
      i = -1
      for _ in range(0, actualSrcNo[0][0]):
        try:
          i = self.matrix[n - 1].index(1, i + 1)
          allIndex.remove(i)
          sources[i] = n
        except Exception as e:
          pass
      for i in allIndex:
        for n in range(0, self.nodes):
          if self.matrix[n][i] == 1:
            sources[i] = n + 1
            break
    return sources


if __name__ == '__main__':
  c = ComponentMatrix(3, 5)
  c.appendComponent([])
  c.appendComponent([1])
  c.appendComponent([1, 2, 3])
  c.appendComponent([1, 2, 3])
  c.appendComponent([1, 2, 3])
  c.appendComponent([1, 2, 3])
  print c.getSourceNodes()  # unit test
