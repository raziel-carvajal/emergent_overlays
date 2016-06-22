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
import subprocess
import networkx as nx

NED_HEADER = ''
NED_HEADER += "import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;\n"
NED_HEADER += "import inet.node.inet.INetworkNode;\n"
NED_HEADER += "import inet.physicallayer.contract.packetlevel.IRadioMedium;\n"

NED_HEADER1 = ''
NED_HEADER1 += "{\n"
NED_HEADER1 += '@display(' + '"' + 'bgb=1908,830' + '"' + ");\n"
NED_HEADER1 += 'string hostType = default(' + '"' + 'WirelessHost' + '"' + ');\n'
NED_HEADER1 += 'string mediumType = default(' + '"' + 'IdealRadioMedium' + '"' + ");\n"
NED_HEADER1 += "submodules:\n"
NED_HEADER1 += 'configurator: IPv4NetworkConfigurator { @display(' + '"' + 'p=0,0' + '"' + "); }\n"
NED_HEADER1 += 'radioMedium: <mediumType> like IRadioMedium { @display(' +'"'+'p=0,0'+'"'+"); }\n"

# default topology
initConf = {}
initConf[0] = {'txt': 'nodes', 'val': 10}
initConf[1] = {'txt': 'transmission range', 'val': 2}
initConf[2] = {'txt': 'layout length', 'val': 5}

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
    try:
        isinstance(argv[4], str)
    except Exception as e:
        print('one name for the topology file must be given, network topology was not built')
        sys.exit(1)

def createNedFile(pos, fileName):
    global NED_HEADER, NED_HEADER1
    NED_HEADER += 'network ' + fileName + '\n' + NED_HEADER1 
    posStr = {}
    iNetConf = ':<hostType> like INetworkNode { @display('
    nodesDes = ''
    for i in pos:
        coor = '"p='
        pos[i][0] += laRan + (laRan*1.0)/2; coor += "{0:.2f}".format(pos[i][0]) + ', '
        pos[i][1] += laRan + (laRan*1.0)/2; coor += "{0:.2f}".format(pos[i][1]) + '"'
        nodesDes += 'hostR' + str(i) + iNetConf + coor + '); }\n'
    NED_HEADER += nodesDes + '}'
    f = open(fileName + '.ned', 'w')
    try:
        f.write(NED_HEADER)
    finally:
        f.close()

if __name__ == '__main__':
    setArguments(sys.argv)
    nodes = initConf[0]['val']
    trRan = initConf[1]['val']
    laRan = initConf[2]['val']
    toFil = sys.argv[4]
    G = nx.Graph()
    G.add_nodes_from(range(1, nodes + 1))
    pos = nx.spring_layout(G, k=trRan, scale=laRan, center=[(laRan*1.0)/2,(laRan*1.0)/2])
    #TODO add node at center AND find a way to represent it at the ned file
    createNedFile(pos, toFil)
