#===============================================================================
#
#          FILE: buildTopology.py
#
#         USAGE: python buildTopology.py nodes transmissionRange layoutSize topologyFile
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
#===============================================================================
import sys
import math
import networkx as nx

NED_HEADER = ''
NED_HEADER += 'package builtTopologies;\n\n'
NED_HEADER += "import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;\n"
NED_HEADER += "import inet.node.inet.INetworkNode;\n"
NED_HEADER += "import inet.physicallayer.contract.packetlevel.IRadioMedium;\n"
NED_HEADER += "import broadcasting.CenterHost;\n"
#NED_HEADER += "import inet.node.inet.CenterHost;\n"

NED_HEADER1 = ''
NED_HEADER1 += 'string mediumType = default(' + '"' + 'IdealRadioMedium' + '"' + ");\n"
NED_HEADER1 += "submodules:\n"
NED_HEADER1 += 'configurator: IPv4NetworkConfigurator { @display(' + '"' + 'p=0,0' + '"' + "); }\n"
NED_HEADER1 += 'radioMedium: <mediumType> like IRadioMedium { @display(' +'"'+'p=0,0'+'"'+"); }\n"

# default topology
initConf = {}
initConf[0] = {'txt': 'transmission range', 'val': 50}
initConf[1] = {'txt': 'layout length', 'val': 500}

# network density
density = {}
density['sparse'] = 2
density['medium'] = 5
density['dense'] = 10

# this dictionary will be filled based on the topology density
topologies = {}
def inittialize_topologies():
    for deTyp in density:
        topologies[deTyp] = []

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

def is_network_connected(pos, tx, density):
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
#if c > density * 1.5:
# 1.5 means that if a node is connected to 1.5 times other nodes, it is still Ok
#    return False
    return nx.is_connected(g)

def fillSurface(Tx, layoutSize):
    inittialize_topologies()
    block_width = Tx
    nr_sqr = int(math.ceil(layoutSize / block_width))
    for i in range(0, nr_sqr):
        x = i * block_width
        for j in range(0, nr_sqr):
            y = j * block_width
            for k in density:
                G = nx.Graph()
                G.add_nodes_from(range(1, density[k] + 1))
                pos = nx.random_layout(G)
                for l in pos:
                    pos[l][0] = x + block_width*pos[l][0]
                    pos[l][1] = y + block_width*pos[l][1]
                    topologies[k].append(pos[l])

def createNedFile(denType, pos, layoutSize, Tx):
    global NED_HEADER, NED_HEADER1
    fileName = "n_{0}_d_{1}_tr_{2}_a_{3}x{4}_p_".format(len(pos), denType, Tx, layoutSize, layoutSize)

    f = open(fileName + '.ned', 'w')

    try:
        f.write(NED_HEADER)
        f.write('network ' + fileName + '\n{\n')
        f.write('@display("bgb={0}, {0}");\n'.format(layoutSize))
        f.write(NED_HEADER1)

        for i, p in enumerate(pos):
            f.write('hostR{0} : CenterHost {{ @display("p={1:.3f},{2:.3f}"); }}\n\n'.format(i, p[0], p[1]) )

        f.write('hostR{0} : CenterHost {{ @display("p={1:.3f},{2:.3f}"); isCenter=true; }}\n\n'.format( len(pos), layoutSize*0.5, layoutSize*0.5 ) )

        f.write("}\n")
    finally:
        f.close()

if __name__ == '__main__':
    setArguments(sys.argv)
    trRan = initConf[0]['val']
    laRan = initConf[1]['val']

    print "Building topologies for an area of ({0}, {0}) and tx={1}".format(laRan, trRan)
    fillSurface(trRan, laRan)
    while not all(is_network_connected(topologies[k], trRan, density[k]) for k in topologies):
        fillSurface(trRan, laRan)

    print "Writing NED file"
    for i in density:
        createNedFile(i, topologies[i], laRan, trRan)
