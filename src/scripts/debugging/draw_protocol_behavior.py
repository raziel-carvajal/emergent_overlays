""" This module draws a topology given as a csv files without header. """
""" The first column is the x while the second is y """

import sys
import random
import math
import csv
import numpy as np


import networkx as nx
from collections import defaultdict

import matplotlib.pyplot as plt
import matplotlib.animation as animation


def get_graph(pos, tx):
    print "Positions"
    print pos, "\n"
    g = nx.Graph()
    for i in pos:
        v = pos[i]
        x0 = v[0]
        y0 = v[1]
        g.add_node(i)
        for j in pos:
            if i < j:
                v2 = pos[j]
                x1 = v2[0]
                y1 = v2[1]
                d = (x1-x0)*(x1-x0) + (y1-y0)*(y1-y0)
                if d < tx*tx:
                    g.add_edge(i, j)

    return g


def compute_mpr(g):
    H1 = defaultdict(set)
    for n in g.nodes():
        for e in g.neighbors(n):
            H1[n].add(e)

    H2 = defaultdict(set)
    for n in g.nodes():
        for e in g.neighbors(n):
            H2[n] = H2[n] | H1[e]
        H2[n] = H2[n] - ({n} | H1[n])

    print "", "H1"
    print H1, "\n"
    print "", "H2"
    print H2, "\n"

    # Step 1
    C = defaultdict(set)
    Uncovered = defaultdict(set)
    for v in g.nodes():
        Uncovered[v] = H2[v]
        print "\t", v, " trying to cover ", H2[v]
        covered = {u: Uncovered[v] & H1[u] for u in g.neighbors(v) }

        for h in H2[v]:
            haveIt = [u for u in g.neighbors(v) if h in covered[u]]
            if len(haveIt) == 1 and not (haveIt[0] in C[v]):
                print "\t\tIncluded in step 1: ", haveIt[0]
                Uncovered[v] = Uncovered[v] - covered[haveIt[0]]
                C[v].add(haveIt[0])

        print "\tmissing after step 1: ", (Uncovered[v])

        while len(Uncovered[v]) > 0:
            covered = {u: Uncovered[v] & H1[u] for u in g.neighbors(v) }
            m = max([ len(covered[u]) for u in g.neighbors(v) if not u in C[v] ])
            goods = [ u for u in g.neighbors(v) if not u in C[v] and len(covered[u]) == m ]
            goods.sort()
            C[v].add(goods[0])
            Uncovered[v] = Uncovered[v] - covered[goods[0]]
            print "\t\tIncluded in step 2: ", goods[0]

        print "\tmissing after step 2: ", (Uncovered[v])
        print ""

    return C


def compute_potential_senders(g, C):
    S = set([0])
    Covered = set([0])

    msgs = { u: [0] for u in g.neighbors(0) }
    who_have_msg = { u: [set([0])] for u in g.neighbors(0) }

    while len(msgs) > 0:
        new_msgs = defaultdict(list)
        new_who_have_msg = defaultdict(list)
        for v in msgs:
            Covered.add(v)
            sender = msgs[v][0]
            have_the_msg = who_have_msg[v][0]
            missing_neighbors = { u for u in g.neighbors(v) if not u in have_the_msg }
            # MPR Rules
            if v in C[sender]: # and len(missing_neighbors) > 0:
                S.add(v)
                # send to my neighbors
                for u in g.neighbors(v):
                    if not u in Covered:
                        new_msgs[u].append(v)
                        new_who_have_msg[u].append( have_the_msg | set([v]) | missing_neighbors )
        msgs = new_msgs
        who_have_msg = new_who_have_msg

    print "Covered: ", len(Covered)

    return S


def simulate(g, pos, l, base_filename):
    plt.figure()
    plt.axis('off')
    nx.draw_networkx(g, pos, labels=l, font_size=7, node_size=700)
    plt.savefig(base_filename + " initial")

    C = compute_mpr(g)

    plt.figure()
    plt.axis('off')
    IN_C = 1.0 # yellow
    NOT_IN_C = 0.0 # blue
    colors = map(lambda(u): IN_C if any(u in C[v] for v in C) else NOT_IN_C , g.nodes())

    nx.draw_networkx(g, pos, labels=l, font_size=7, node_size=700, vmin=0, vmax=1, cmap='summer', node_color=colors)
    plt.savefig(base_filename + " members of mpr.png")

    Senders = compute_potential_senders(g, C)

    print Senders, len(Senders)

    plt.figure()
    plt.axis('off')
    SENDERS_COLOR = 1.0 # yellow
    NOT_SENDERS_COLOR = 0.0 # blue
    colors = [ SENDERS_COLOR if u in Senders else NOT_SENDERS_COLOR for u in g.nodes()]
    nx.draw_networkx(g, pos, labels=l, font_size=7, node_size=700, vmin=0, vmax=1, cmap='summer', node_color=colors)
    plt.savefig(base_filename + " after mpr rule.png")

    pass

def distance(u, v, pos):
    return (pos[u][0]-pos[v][0])**2 + (pos[u][1]-pos[v][1])**2

if __name__ == '__main__':
    logFile = sys.argv[1]
    # output_image_file = sys.argv[2]
    # communication_range = int(sys.argv[3])
    #
    # node_id = 0
    # pos = defaultdict(list)
    # l = defaultdict(list)
    #
    # with open(topology_file) as fp:
    #     for line in fp:
    #         pos[node_id] = map(lambda(s): int(s), line.split(','))
    #         l[node_id] = "h" + str(node_id)
    #         node_id = node_id + 1
    #
    # # sent by Raziel
    # g = get_graph(pos, communication_range)
    # simulate(g, pos, l, "raziel")
    #
    # g1, pos1, l1 = generate_topology()
    # print pos1, g1.nodes()
    # simulate(g1, pos1, l1, "paper")
    data = []
    with open(logFile, 'rb') as csvfile:
        logreader = csv.reader(csvfile, delimiter=',')
        for row in logreader:
            data.append({'name': row[1], 'time': float(row[2]), 'x': float(row[3]), 'y': float(row[4]), 'status': row[5]})

    # create dictionary
    d = {}
    for e in data:
        if not e['name'] in d:
            d[e['name']] = {'status': e['status'], 'x': e['x'], 'y': e['y']}

    data = [ e for e in data if e['status'] != 'STANDING']

    # draw initial stuff
    fig, ax = plt.subplots()

    for k1 in d:
        x1 = d[k1]['x']
        y1 = d[k1]['y']
        for k2 in d:
            if k1 < k2:
                x2 = d[k2]['x']
                y2 = d[k2]['y']
                dist = (x1-x2)**2 + (y1-y2)**2
                if dist <= 10**2:
                    # print x1, x2, y1, y2
                    ax.plot([x1, x2] , [y1, y2], c='red', linewidth=1.3)

    px = [ d[k]['x'] for k in d ]
    py = [ d[k]['y'] for k in d ]
    cc = [ 'black' if k == 'hostR54' else 'red' for k in d]

    scatter = ax.scatter(px, py, marker="o", c=cc, s=144)

    def getColor(name, status):
        if name == 'hostR54':
            return 'black'
        if status == 'MARKED':
            return 'green'
        if status == 'UNMARKED1':
            return 'blue'
        if status == 'UNMARKED2':
            return 'yellow'
        if status == 'UNMARKED3':
            return 'gray'
        if status == 'UNMARKED4':
            return 'pink'
        return 'red'

    def animate(i):
        name = data[i]['name']
        status = data[i]['status']
        time = data[i]['time']
        print i, name, time
        if status != 'STANDING':
            d[name]['status'] = status
            colors = [ getColor(k, d[k]['status']) for k in d]
            scatter.set_facecolor(colors)
        return scatter,

    def init():
        return scatter,

    ani = animation.FuncAnimation(fig, animate, np.arange(0, len(data)), init_func=init,
                                  interval=100, blit=False, repeat=False)

    plt.show()

    print "Plotting final graph"
    fig, ax = plt.subplots()

    for k1 in d:
        x1 = d[k1]['x']
        y1 = d[k1]['y']
        status = d[k1]['status']
        if status == "MARKED":
            for k2 in d:
                if k1 != k2:
                    x2 = d[k2]['x']
                    y2 = d[k2]['y']
                    dist = (x1-x2)**2 + (y1-y2)**2
                    if dist <= 10**2:
                        ax.plot([x1, x2] , [y1, y2], c='red', linewidth=1.3)

    px = [ d[k]['x'] for k in d ]
    py = [ d[k]['y'] for k in d ]
    cc = [ 'black' if k == 'hostR54' else 'green' if d[k]['status'] == 'MARKED' else 'red' for k in d]
    scatter = ax.scatter(px, py, marker="o", c=cc, s=144)
    plt.show()

    print "Done"
