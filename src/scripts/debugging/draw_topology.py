""" This module draws a topology given as a csv files without header. """
""" The first column is the x while the second is y """

import sys
import random
import math


import networkx as nx
from collections import defaultdict

import matplotlib.pyplot as plt


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
    return (pos[u][0]-pos[v][0])*(pos[u][0]-pos[v][0]) + (pos[u][1]-pos[v][1])*(pos[u][1]-pos[v][1])

def generate_topology():
    g = nx.Graph()
    pos = defaultdict(list)

    # center
    pos[0] = [0, 0]
    g.add_node(0)

    count = 1

    # inner circle
    angles = [  (-idx) * (2*math.pi/8) + math.pi/2 for idx in range(0, 8) ]
    nodes = [ [20*math.cos(a), 20*math.sin(a)] for a in angles ]
    for i in range(0, len(nodes)):
        pos[i+count] = nodes[i]
        g.add_node(i+count)
        g.add_edge(0, i + count) # these edges are easy

    last_circle = range(count, count + len(nodes))

    count = count + len(nodes)

    # medium circle
    angles = [(-idx) * (2*math.pi/16) + math.pi/2 for idx in range(0, 16)]
    nodes = [[40*math.cos(a), 40*math.sin(a)] for a in angles]
    for i in range(0, len(nodes)):
        pos[i+count] = nodes[i]
        g.add_node(i+count)

    # adding edges
    g.add_edges_from([(1, 9), (1, 10), (1, 11), (1, 24)])
    g.add_edges_from([(2, 10), (2, 11), (2, 12), (2, 13)])
    g.add_edges_from([(3, 12), (3, 13), (3, 14), (3, 15)])
    g.add_edges_from([(4, 14), (4, 15), (4, 15), (4, 17)])
    g.add_edges_from([(5, 16), (5, 17), (5, 18), (5, 19)])
    g.add_edges_from([(6, 18), (6, 19), (6, 20), (6, 21)])
    g.add_edges_from([(7, 20), (7, 21), (7, 22), (7, 23)])
    g.add_edges_from([(8, 22), (8, 23), (8, 24), (8, 9)])


    last_circle = range(count, count + len(nodes))
    count = count + len(nodes)

    # outer circle
    angles = [(-idx) * (2*math.pi/25) + math.pi/2 for idx in range(0, 25) ]
    nodes = [ [60*math.cos(a), 60*math.sin(a)] for a in angles ]
    for i in range(0, len(nodes)):
        pos[i+count] = nodes[i]
        g.add_node(i+count)

    # adding edges
    g.add_edges_from([(9, 25), (9, 26), (9, 48), (9, 49)])
    g.add_edges_from([(10, 25), (10, 26), (10, 27)])
    g.add_edges_from([(11, 26), (11, 27), (11, 28)])
    g.add_edges_from([(12, 27), (12, 28), (12, 29), (12, 30)])
    g.add_edges_from([(13, 29), (13, 30), (13, 31)])
    g.add_edges_from([(14, 30), (14, 31), (14, 32), (14, 33)])
    g.add_edges_from([(15, 32), (15, 33), (15, 34)])
    g.add_edges_from([(16, 33), (16, 34), (16, 35), (16, 36)])
    g.add_edges_from([(17, 35), (17, 36), (17, 37), (17, 38)])
    g.add_edges_from([(18, 37), (18, 38), (18, 39), (18, 40)])
    g.add_edges_from([(19, 39), (19, 40), (19, 41)])
    g.add_edges_from([(20, 40), (20, 41), (20, 42), (20, 43)])
    g.add_edges_from([(21, 42), (21, 43), (21, 44), (21, 45)])
    g.add_edges_from([(22, 44), (22, 45), (22, 46)])
    g.add_edges_from([(23, 45), (23, 46), (23, 47), (23, 48)])
    g.add_edges_from([(24, 47), (24, 48), (24, 49)])

    l = { v:"h"+str(v) for v in g.nodes() }
    return g, pos, l

if __name__ == '__main__':
    topology_file = sys.argv[1]
    output_image_file = sys.argv[2]
    communication_range = int(sys.argv[3])

    node_id = 0
    pos = defaultdict(list)
    l = defaultdict(list)

    with open(topology_file) as fp:
        for line in fp:
            pos[node_id] = map(lambda(s): int(s), line.split(','))
            l[node_id] = "h" + str(node_id)
            node_id = node_id + 1

    # sent by Raziel
    g = get_graph(pos, communication_range)
    simulate(g, pos, l, "raziel")

    g1, pos1, l1 = generate_topology()
    print pos1, g1.nodes()
    simulate(g1, pos1, l1, "paper")

    print "Done"
