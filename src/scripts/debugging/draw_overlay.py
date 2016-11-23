import sys
import networkx as nx
import matplotlib.pyplot as plt

def getNodesAndEdges(fileName):
    nodes = []; edges = []; f = open(fileName, 'r')
    try:
        for l in f:
            ar = l.split()
            peer = ar[1]; pos = (float(ar[4]), float(ar[5]))
            neigs = ar[9].split('_')
            nodes.append( (peer, {'pos': pos}) )
            for n in neigs:
                if n != '':
                    edges.append((peer, n))
    finally: f.close()
    return nodes, edges

def getCollisionsRate(G, fileName, sessionId, dstDi, algo):
    f = open(fileName, 'r'); nodesDegree = {}
    try:
        for l in f:
            ar = l.split(); node = ar[6]; neig = ar[1]
            if not(node in nodesDegree): nodesDegree[node] = 1
            else: nodesDegree[node] = nodesDegree[node] + 1
    finally: f.close()
    f = open(dstDi + 'collisions.dat', 'a')
    try:
        for n in nodesDegree:
            err = 1 - (nodesDegree[n]*1.0) / len(G.neighbors(n))
            line = algo + ', ' + str(sessionId) + ', ' + str(err) + '\n'
            f.write(line)
    finally: f.close()

if __name__ == '__main__':
    loops = int(sys.argv[1])
    dstDi = sys.argv[2]
    algo  = sys.argv[3]
    graphs = {}
    for i in range(1, loops + 1):
        graphs[i] = nx.Graph(); iD = str(i)
        nodes, edges = getNodesAndEdges(dstDi + "graph_" + iD)
        graphs[i].add_nodes_from(nodes)
        graphs[i].add_edges_from(edges)
        #TODO if the protocol bulds an spine, mark relays with a different color
        #TODO mark non connected graphs
        #for r in relays: relayC[r] = 'blue'
        #colors = [relayC.get(node, 'red') for node in graphs[i].nodes()]
        #nx.draw(graphs[i], pos=nx.spring_layout(graphs[i]), node_color=colors)
        nx.draw(graphs[i])
        getCollisionsRate(graphs[i], dstDi + "rcvMsgs_" + iD, iD, dstDi, algo)
        #nx.draw(graphs[i], positions, node_color=colors, with_labels=False)
        #nx.draw_networkx(g)
        plt.savefig(dstDi + "graph" + iD + ".png")
        graphs[i].clear()
        plt.clf()
