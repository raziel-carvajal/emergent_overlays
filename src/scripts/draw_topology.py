""" This module draws a topology given as a csv files without header. """
""" The first column is the x while the second is y """

import sys
import random
import math
import networkx as nx
from collections import defaultdict

import matplotlib.pyplot as plt

def get_graph(pos, tx):
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
            l[node_id] = "hostR" + str(node_id)
            node_id = node_id + 1

    print pos

    g = get_graph(pos, communication_range)
    plt.axis('off')

    nx.draw_networkx(g, pos, labels=l, font_size=7, node_size=700)

    plt.savefig(output_image_file)

    print "Done"
