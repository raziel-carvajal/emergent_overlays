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
NED_HEADER += 'package builtTopologies;'
NED_HEADER += "import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;\n"
NED_HEADER += "import inet.node.inet.INetworkNode;\n"
NED_HEADER += "import inet.physicallayer.contract.packetlevel.IRadioMedium;\n"
#NED_HEADER += "import broadcasting.CenterHost;\n"
NED_HEADER += "import inet.node.inet.CenterHost;\n"

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

def fillSurface(Tx, layoutLen):
    sqrLen = int(math.ceil(layoutLen / Tx))
    for i in range(1, sqrLen + 1):
        x = i * Tx
        for j in range(1, sqrLen + 1):
            y = j * Tx
            for k in density:
                G = nx.Graph()
                G.add_nodes_from(range(1, density[k] + 1))
                pos = nx.random_layout(G)
                for l in pos:
                    pos[l][0] *= x; pos[l][1] *= y
                    pos[l][0] = "{0:.2f}".format(pos[l][0])
                    pos[l][1] = "{0:.2f}".format(pos[l][1])
                    topologies[k].append(pos[l])

def createNedFile(denType, pos, layoutSize, Tx):
    global NED_HEADER, NED_HEADER1
    fileName = 'n-' + str(len(pos)) + '-d-' + denType + '-tr-' + str(Tx) + '-a-' + str(layoutSize) +\
            'x' + str(layoutSize) + '-p-'
    header = NED_HEADER + 'network ' + fileName + '\n{\n' + '@display(' + '"' + 'bgb=' +\
            str(layoutSize) + ',' + str(layoutSize)+ '"' + ");\n" + NED_HEADER1
    posStr = {}
    iNetConf = ':CenterHost { @display('
    nodesDes = ''
    for i in range(0, len(pos)):
        coor = '"p='
        coor += str(pos[i][0]) + ', '
        coor += str(pos[i][1]) + '"'
        nodesDes += 'hostR' + str(i) + iNetConf + coor + '); }\n'
    header += nodesDes
    # adding node at the layout center
    header += 'hostR' + str(len(pos)) + iNetConf + '"p=' + "{0:.2f}".format(0.5 * layoutSize) + \
            ', ' + "{0:.2f}".format(0.5 * layoutSize) + '"); isCenter=true; }\n}'
    f = open(fileName + '.ned', 'w')
    try:
        f.write(header)
    finally:
        f.close()

if __name__ == '__main__':
    setArguments(sys.argv)
    trRan = initConf[0]['val']; laRan = initConf[1]['val']
    fillSurface(trRan, laRan)
    for i in density:
        createNedFile(i, topologies[i], laRan, trRan)
