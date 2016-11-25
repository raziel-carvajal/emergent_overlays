import sys
import networkx as nx
import matplotlib.pyplot as plt

def getNodesAndPos(dstDir, sessionId):
    nodes = []; pos = {}; f = open(dstDir + "nodes_" + sessionId, 'r')
    try:
        for l in f:
            ar = l.split()
            peer = ar[1]
            p = (float(ar[6]), float(ar[7]))
            pos[peer] = p
            nodes.append(peer)
    finally: f.close()
    return nodes, pos

def getEdgesAndRelays(dstDir, sessionId):
    relays = {}; edges = []
    f = open(dstDir + "senders_" + sessionId, 'r')
    try:
        for l in f:
            ar = l.split()
            peer = ar[1]
            neigs = ar[6].split('_')
            for n in neigs:
                if n != '':
                    edges.append((peer, n))
            relays[peer] = 'blue'
    finally: f.close()
    return edges, relays

def getCollisionsRate(G, fileName, sessionId, dstDi, algo, relays):
    f = open(fileName, 'r'); nodesDegree = {}
    try:
        for l in f:
            ar = l.split(); node = ar[6]; neig = ar[1]
            if not(node in nodesDegree): nodesDegree[node] = 1
            else: nodesDegree[node] = nodesDegree[node] + 1
    finally: f.close()
    f = open(dstDi + 'collisions.dat', 'a')
    try:
        for n in relays:
            if n in nodesDegree:
                err = 1 - (nodesDegree[n]*1.0) / len(G.neighbors(n))
            else:
                err = 1
            line = algo + ', ' + sessionId + ', ' + str(err) + ', ' + n + '\n'
            f.write(line)
    finally: f.close()


def isGraphConnected(G, algo, sessionId, fileName):
    f = open(fileName, 'a')
    try:
        try:
            nx.average_shortest_path_length(G)
            connected = '1'
        except NetworkXError:
            connected = '0'
        line = algo + ', ' + sessionId + ', ' + connected + '\n'
        f.write(line)
    finally: f.close()

if __name__ == '__main__':
    loops = int(sys.argv[1])
    dstDi = sys.argv[2]
    algo  = sys.argv[3]
    graphs = {}
    for i in range(1, loops + 1):
        graphs[i] = nx.Graph(); iD = str(i)
        nodes, positions = getNodesAndPos(dstDi, iD)
        graphs[i].add_nodes_from(nodes)
        edges, relays = getEdgesAndRelays(dstDi, iD)
        graphs[i].add_edges_from(edges)
        # option for nx.draw :: labels=False
        colors = [relays.get(node, 'red') for node in graphs[i].nodes()]
        nx.draw(graphs[i], positions, node_color=colors)
        print('plotting graph_' + iD)
        plt.savefig(dstDi + "graph" + iD + ".png")
        print('computing porportion of collisions for graph_' + iD)
        getCollisionsRate(graphs[i], dstDi + "receivers_" + iD, iD, dstDi, algo, relays)
        print('computing connectivity of graph_' + iD)
        isGraphConnected(graphs[i], algo, iD, dstDi + "graphConnectivity.dat")
        graphs[i].clear()
        plt.clf()
