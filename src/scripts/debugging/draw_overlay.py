import os
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

def getCollisionsRate(G, fileName, relays):
    f = open(fileName, 'r'); nodesDegree = {}
    try:
        for l in f:
            ar = l.split(); node = ar[6]; neig = ar[1]
            if not(node in nodesDegree): nodesDegree[node] = 1
            else: nodesDegree[node] = nodesDegree[node] + 1
    finally: f.close()
    datP = {}
    for n in relays:
        if n in nodesDegree:
            err = 1 - (nodesDegree[n]*1.0) / len(G.neighbors(n))
        else:
            err = 1
        datP[n] = round(err, 2)
    return datP

def isGraphConnected(G):
    try:
        nx.average_shortest_path_length(G)
        connected = '1'
    except Exception: connected = '0'
    return connected

def saveCollRateAndCon(fileName, algo, maP, dataSi, sesN, wKey):
    line = '"Algorithm",'; firstLine = False
    if not os.path.isfile(fileName):
        firstLine = True
        for j in range(1, sesN + 1):
            if j < sesN:
                line = line + '"B' + str(j) + '"' + ','
            else:
                line = line + '"B' + str(j) + '"' + '\n'

    f = open(fileName, 'a')
    try:
        if firstLine:
            f.write(line)
        for i in range(0, dataSi):
            line = '"' + algo + '"' + ','
            for j in range(1, sesN + 1):
                if wKey:
                    key = 'hostR' + str(i)
                    if key in maP[j]:
                        value = str(maP[j][key])
                    else:
                        value = 'NA'
                else:
                    value = str(maP[j][i])
                if j < sesN:
                    line = line + '"' + value + '"' + ','
                else:
                    line = line + '"' + value + '"' + '\n'
            f.write(line)
    finally: f.close()

if __name__ == '__main__':
    loops = int(sys.argv[1])
    dstDi = sys.argv[2]
    algo  = sys.argv[3]
    colM = {}; conM = {}
    graphs= {}; bigst = []
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
        colM[i] = getCollisionsRate(graphs[i], dstDi + "receivers_" + iD, relays)
        bigst.append(len(colM[i]))
        print('computing connectivity of graph_' + iD)
        conM[i] = [ isGraphConnected(graphs[i]) ]
        graphs[i].clear()
        plt.clf()
    density = dstDi.split('_')[4]
    saveCollRateAndCon('../../../results/collisions_' + density, algo, colM, max(bigst), loops, True)
    saveCollRateAndCon('../../../results/graphConnectivity_' + density, algo, conM, 1, loops, False)
    #f = open('../../../results/collisions_' + density, 'a')
    #f = open( + density, 'a')
