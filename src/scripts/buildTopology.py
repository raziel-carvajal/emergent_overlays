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


def setArguments(argv):
    for i in range(0, len(initConf)):
        argu = argv[i + 1]
        try:
            isinstance(argu, int)
            initConf[i]['val'] = int(argu)
        except Exception as e:
            print("input argument %d is NIL or isn't an integer" % (i))
            print('parameter %s will be set to its default value' % (initConf[i]['txt']))
            continue


def is_valid_network(pos, tx, density, allowed_error):
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
        print avg_degree, max_degree, min_degree, expected, nx.number_of_nodes(g), nx.number_of_edges(g), density, cond1, cond2
        print h
    return cond1 and cond2


def fillSurface(Tx, tilesWidth, tilesHeight, density):
    result = []
    block_width = 2*Tx
    for i in range(0, tilesWidth):
        x = i * block_width
        for j in range(0, tilesHeight):
            y = j * block_width
            G = nx.Graph()
            G.add_nodes_from(range(1, density + 1 + int(20/100.0*density)))
            pos = nx.random_layout(G)
            for l in pos:
                pos[l][0] = x + block_width*pos[l][0]
                pos[l][1] = y + block_width*pos[l][1]
                result.append(pos[l])
    return result


def fillSurface2(Tx, tilesWidth, tilesHeight, density):
    result = []
    block_width = 2*Tx
    w = tilesWidth * block_width
    h = tilesHeight * block_width
    G = nx.Graph()
    G.add_nodes_from(range(1, (density + 1 + int(20/100.0*density))*w*h))
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

        # f.write('hostR{0} : CenterHost {{ @display("p={1:.3f},{2:.3f}"); isCenter=true; }}\n\n'.format(len(pos), layoutSizeW*0.5, layoutSizeH*0.5))

        f.write("}\n")
    finally:
        f.close()


def cleanTopology(t, count):
    while count > 0:
        idx = random.randint(0, len(t) - 1)
        del t[idx]
        count = count - 1
    return


if __name__ == '__main__':
    setArguments(sys.argv)
    trRan = initConf[0]['val']
    minL = initConf[1]['val']
    maxL = initConf[2]['val']

    index = initConf[3]['val']
    for d in range(5, 45, 5):
        expected = maxL*maxL*d

        print "Building topology with density", d
        topology = fillSurface(trRan, maxL, maxL, d)
        # cleanTopology(topology, seen - expected)
        while not is_valid_network(topology, trRan, d, 20):
            topology = fillSurface(trRan, maxL, maxL, d)
        # cleanTopology(topology, seem - expected)

        print "Writing NED file"
        createNedFile(d, topology, index, maxL*2*trRan, maxL*2*trRan, trRan)
        index = index + 1

    print "Done", index
