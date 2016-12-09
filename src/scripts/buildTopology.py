"""This module builds a set of topologies with given densities."""

# =============================================================================
#
#          FILE: buildTopology.py
#
#         USAGE: python buildTopology.py nodes transmissionRange layoutSize
#                topologyFile
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION:
#       CREATED: 06/22/16 19:37
#      REVISION:  ---
# =============================================================================

import random
import math
import networkx as nx
import argparse
import logging
import genmobility
import matplotlib.pyplot as plt

NED_HEADER = ''
NED_HEADER += 'package builtTopologies;\n\n'
NED_HEADER += "import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;\n"
NED_HEADER += "import inet.node.inet.INetworkNode;\n"
NED_HEADER += "import inet.physicallayer.contract.packetlevel.IRadioMedium;\n"
NED_HEADER += "import broadcasting.CenterHost;\n"

NED_HEADER1 = ''
NED_HEADER1 += 'string mediumType = default(' + '"' + 'IdealRadioMedium' + '"' + ");\n"
NED_HEADER1 += "submodules:\n"
NED_HEADER1 += 'configurator: IPv4NetworkConfigurator { @display(' + '"' + 'p=0,0' + '"' + "); }\n"
NED_HEADER1 += 'radioMedium: <mediumType> like IRadioMedium { @display(' +'"'+'p=0,0'+'"'+"); }\n"

# default topology
initConf = {}
initConf[0] = {'txt': 'transmission range', 'val': 50}
initConf[1] = {'txt': 'minimum layout length in tiles', 'val': 2}
initConf[2] = {'txt': 'maximum layout length in tiles', 'val': 6}
initConf[3] = {'txt': 'last id number used to identify topologies', 'val': 0}

# network density
density = {}
density['sparse'] = 2
density['medium'] = 5
density['dense'] = 10

logger = logging.getLogger("mobility-generator")


def get_arguments():
    parser = argparse.ArgumentParser(description='Generate a topology using random geometric graphs.')
    parser.add_argument('--tx', dest='tx', type=int, default=10,
                        help='Transmission Range (default: 10)')
    parser.add_argument('--min_d', dest='min_density', type=int, default=5,
                        help='Minimum density (default: 5)')
    parser.add_argument('--max_d', dest='max_density', type=int, default=65,
                        help='Maximum density (default: 65)')
    parser.add_argument('--idx', dest='last_idx', type=int, default=0,
                        help='last id number used to identify topologies (default: 0)')
    parser.add_argument('--nodes', dest='nr_nodes', type=int, default=200,
                        help='Number of nodes (default: 200)')
    parser.add_argument("--mobility", dest="mobility", action='store_true',
                        help="Generate mobility files")

    parser.add_argument("--distributed", dest="distributed", action='store_true',
                        help="Should generate broadcasts from many nodes.")

    parser.add_argument("--save-fig", dest="savedfigure", type=str,
                        help="Save an image of the topology at.")


    args = parser.parse_args()
    return args


def build_graph(pos, tx):
    g = nx.Graph()
    for i, v in enumerate(pos):
        n = g.add_node(i)

    for i, v in enumerate(pos):
        x0 = v[0]
        y0 = v[1]
        c = 0
        for j in range(i+1, len(pos)):
            v2 = pos[j]
            x1 = v2[0]
            y1 = v2[1]
            d = (x1-x0)*(x1-x0) + (y1-y0)*(y1-y0)
            if d < tx*tx:
                g.add_edge(i, j)
                c = c + 1
    return g


def find_closest(pos, components, node_idx, component_idx):
    x0 = pos[node_idx][0]
    y0 = pos[node_idx][1]
    dm = 100000000
    idx_min = -1
    for i, c in enumerate(components):
        if i != component_idx:
            indexes = c[1]
            for i in indexes:
                x1 = pos[i][0]
                y1 = pos[i][1]
                d = math.sqrt((x1 - x0)**2 + (y1- y0)**2)
                if d < dm:
                    dm = d
                    idx_min = i
    return (dm, idx_min, node_idx)


def fix_connectivity_of_network(initial_g, pos, tx, threshold=80.0):
    g = initial_g
    x = [(len(c), c) for c in nx.connected_components(g)]
    maximum = max(c[0] for c in x)
    if maximum < len(pos)*threshold/100:
        return False
    while len(x) > 1:
        x.sort(lambda a, b: -1 if a[0] < b[0] else 1)
        sizes = [c[0] for c in x]
        # print len(x), " components with sizes: ", sizes
        idx_c = 0
        c = x[0]
        # print "\thola: ", c[1]
        ttt = [ find_closest(pos, x, idx, idx_c) for idx in c[1] ]
        ttt.sort(lambda a, b: -1 if a[0] < b[0] else 1)
        pair = ttt[0]
        # print "\t\tminimum distance : ", pair[0] - tx, ", to node:", pair[1]
        toward = pair[1]
        x0 = pos[pair[2]][0]
        y0 = pos[pair[2]][1]
        x1 = pos[toward][0]
        y1 = pos[toward][1]
        d = pair[0] - tx + 1
        px = (x1 - x0)/d
        py = (y1 - y0)/d
        # move all nodes in this component
        for idx in c[1]:
            pos[idx][0] += px
            pos[idx][1] += py
        g = build_graph(pos, tx)
        x = [(len(c), c) for c in nx.connected_components(g)]
    return True

def is_valid_network(pos, tx, density, allowed_error):
    g = build_graph(pos, tx)
    degrees = map(lambda(k, v): v, nx.degree(g).iteritems())
    sum_degree = sum(degrees)
    avg_degree = sum_degree/float(nx.number_of_nodes(g))
    expected = density-density*allowed_error/100.0
    cond2 = abs(avg_degree - density) <= density*allowed_error/100.0
    cond1 = nx.is_connected(g)
    if cond1 and cond2:
        min_degree = min(degrees)
        max_degree = max(degrees)
        u = set(degrees)
        h = {d: len(filter(lambda(x): x == d,  degrees)) for d in u}
        print avg_degree, max_degree, min_degree, expected, "Nr Nodes", nx.number_of_nodes(g), "Nr Edges", nx.number_of_edges(g), density, cond1, cond2
        print h
    if cond2 and not cond1:
        b = fix_connectivity_of_network(g, pos, tx)
        if b:
            g = build_graph(pos, tx)
            cond1 = nx.is_connected(g)
    return cond1 and cond2
    return cond2


def fillSurfaceWithFixedRadio(tx, tilesWidth, tilesHeight, density):
    r = float(tx)/(tilesWidth*2*tx)
    n = int(math.ceil(float(density)/(math.pi*r*r)))
    print n, density, r
    block_width = 2*tx
    w = tilesWidth * block_width
    h = tilesHeight * block_width
    return fillSurfaceBase(r, n, density, w, h), w, h


def fillSurfaceWithFixedNumberOfNodes(tx, n, density):
    # n*pi*r^2 = d
    r = math.sqrt(density/(n*math.pi))
    h = w = math.floor(tx/r)
    return fillSurfaceBase(r, n, density, w, h), w, h


def fillSurfaceBase(r, n, density, w, h):
    assert w == h
    # print r, n, density, w
    result = []
    G = nx.Graph()
    G.add_nodes_from(range(1, n+1))
    pos = nx.random_layout(G)
    for l in pos:
        pos[l][0] = w*pos[l][0]
        pos[l][1] = h*pos[l][1]
        result.append(pos[l])
    return result


def get_callback_single_source_code(idx_source):
    def tmp(i, p):
        return "isCenter=true;" if (i == idx_source) else ""

    return tmp


def get_callback_multiple_source_code(nr_nodes, nr_max_msgs, idx_source):
    d = { i:[] for i in range(0, nr_nodes) }
    for i in range(1, nr_max_msgs+1):
        idx = random.randint(0, nr_nodes - 1)
        d[idx].append(i)

    f2 = get_callback_single_source_code(idx_source)

    def tmp(i, p):
        if len(d[i]) == 0:
            return f2(i, p)
        return "id_messages_to_send=\"" + reduce(lambda s, v: s+" "+str(v), d[i], "") + "\";" + f2(i, p)

    return tmp


def createNedFile(denType, pos, index, layoutSizeW, layoutSizeH, Tx, callback_source):
    global NED_HEADER, NED_HEADER1
    fileName = "n_{0}_d_{1}_tr_{2}_a_{3}x{4}_idx_{5}_p_".format(len(pos), denType, Tx, layoutSizeW, layoutSizeH, index)

    f = open(fileName + '.ned', 'w')

    try:
        f.write(NED_HEADER)
        f.write('network ' + fileName + '\n{\n')
        f.write('@display("bgb={0}, {1}");\n'.format(layoutSizeW, layoutSizeH))
        f.write(NED_HEADER1)

        for i, p in enumerate(pos):
            f.write('hostR{0} : CenterHost {{ @display("p={1:.3f},{2:.3f}"); {3} }}\n\n'.format(i, p[0], p[1], callback_source(i, p)))

        f.write("}\n")
    finally:
        f.close()


def get_still_connected_callback(tx, idx_source):
    def l(p):
        # G = build_graph(p, tx)
        # b = nx.is_connected(G)
        # if not b:
        #     x = [len(c) for c in nx.connected_components(G) if idx_source in c]
        #     logger.info("Node {0} is in a component with {1} out of {2} members".format(idx_source, x[0], len(p)))
        return True
        # return b
    return l


def draw(pos, tx, filename):
    g = build_graph(pos, tx)
    plt.figure()
    plt.axis('off')
    nx.draw_networkx(g, pos, font_size=7, node_size=10)
    plt.savefig(filename)

    pass



if __name__ == '__main__':
    args = get_arguments()
    trRan = args.tx
    index = args.last_idx
    min_density = args.min_density
    max_density = args.max_density
    nr_nodes = args.nr_nodes
    mobility = args.mobility

    step = 5
    threshold = 10

    for d in range(min_density, max_density + step, step):

        print "Building topology with density %d and transmission range %d" % (d, trRan)
        topology, w, h = fillSurfaceWithFixedNumberOfNodes(trRan, nr_nodes, d)
        while not is_valid_network(topology, trRan, d, threshold):
            topology, w, h = fillSurfaceWithFixedNumberOfNodes(trRan, nr_nodes, d)

        print "Selecting source of broadcasting"


        print "Writing NED file"
        idx_source = random.randint(0, len(topology) - 1)
        if (args.distributed):
            fn_create_sources = get_callback_multiple_source_code(nr_nodes, 3000, idx_source)
        else:
            fn_create_sources = get_callback_single_source_code(idx_source)
        createNedFile(d, topology, index, int(w), int(w), trRan, fn_create_sources)

        if args.savedfigure:
            draw(topology, trRan, args.savedfigure)


        if mobility:
            print "Generating mobility"
            filename = "n_{0}_d_{1}_tr_{2}_a_{3}x{4}_idx_{5}.mobility".format(nr_nodes, d, trRan, int(w), int(h), index)
            while True:
                b = genmobility.generateMobility(sps=10, nr_nodes=nr_nodes,
                                                 map_x=int(w), map_y=int(h),
                                                 sim_time=100, positions=topology,
                                                 outputFile=filename,
                                                 test=get_still_connected_callback(trRan, idx_source))
                if b:
                    break

        index = index + 1

    print "Done", index
