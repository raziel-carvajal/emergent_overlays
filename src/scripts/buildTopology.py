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

import sys
import random
import math
import networkx as nx
import argparse
import genmobility

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
    parser.add_argument("--mobility", help="Generate mobility files")
    args = parser.parse_args()
    return args


class RandomGeometricGraphTopologyGenerator:
    def __init__(self, d):
        self.density = d
        pass


class FixedRadiusTopologyGenerator(RandomGeometricGraphTopologyGenerator):

    def __init__(self, s):
        pass


def build_graph(pos, tx):
    g = nx.Graph()
    for i, v in enumerate(pos):
        x0 = v[0]
        y0 = v[1]
        g.add_node(i)
        c = 0
        for j, v2 in enumerate(pos):
            if i != j:
                x1 = v2[0]
                y1 = v2[1]
                d = (x1-x0)*(x1-x0) + (y1-y0)*(y1-y0)
                if d < tx*tx:
                    g.add_edge(i, j)
                    c = c + 1
    return g

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
    return cond1 and cond2


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


def createNedFile(denType, pos, index, layoutSizeW, layoutSizeH, Tx):
    global NED_HEADER, NED_HEADER1
    fileName = "n_{0}_d_{1}_tr_{2}_a_{3}x{4}_idx_{5}_p_".format(len(pos), denType, Tx, layoutSizeW, layoutSizeH, index)

    f = open(fileName + '.ned', 'w')

    idx_source = random.randint(0, len(pos) - 1)
    try:
        f.write(NED_HEADER)
        f.write('network ' + fileName + '\n{\n')
        f.write('@display("bgb={0}, {1}");\n'.format(layoutSizeW, layoutSizeH))
        f.write(NED_HEADER1)

        for i, p in enumerate(pos):
            if i == idx_source:
                f.write('hostR{0} : CenterHost {{ @display("p={1:.3f},{2:.3f}"); isCenter=true; }}\n\n'.format(i, p[0], p[1]))
            else:
                f.write('hostR{0} : CenterHost {{ @display("p={1:.3f},{2:.3f}"); }}\n\n'.format(i, p[0], p[1]))

        f.write("}\n")
    finally:
        f.close()


def get_still_connected_callback(tx):
    l = lambda pos: nx.is_connected(build_graph(pos, tx))
    return l

if __name__ == '__main__':
    # trRan = initConf[0]['val']
    # minL = initConf[1]['val']
    # maxL = initConf[2]['val']
    #
    # index = initConf[3]['val']
    args = get_arguments()
    trRan = args.tx
    index = args.last_idx
    min_density = args.min_density
    max_density = args.max_density
    nr_nodes = 200
    mobility = args.mobility

    for d in range(min_density, max_density + 5, 5):

        print "Building topology with density %d and transmission range %d" % (d, trRan)
        topology, w, h = fillSurfaceWithFixedNumberOfNodes(trRan, nr_nodes, d)
        while not is_valid_network(topology, trRan, d, 10):
            topology, w, h = fillSurfaceWithFixedNumberOfNodes(trRan, nr_nodes, d)

        print "Writing NED file"
        createNedFile(d, topology, index, int(w), int(w), trRan)
        if mobility:
            print "Generating mobility"
            filename = "n_{0}_d_{1}_tr_{2}_a_{3}x{4}_idx_{5}.mobility".format(nr_nodes, d, trRan, int(w), int(h), index)
            while True:
                b = genmobility.generateMobility(sps=10,nr_nodes=nr_nodes,
                                            map_x=int(w), map_y=int(h),
                                            sim_time=50, positions=topology,
                                            outputFile=filename,
                                            test=get_still_connected_callback(trRan))
                if b:
                    break


        index = index + 1

    print "Done", index
