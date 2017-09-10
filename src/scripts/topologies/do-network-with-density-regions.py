import networkx as nx
import matplotlib.pyplot as plt
import argparse; import sys; import math

NED_HEADER = "package rand_uniform_topologies;\n\
	import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;\n\
	import inet.node.bgp.BGPRouter;\n\
	import inet.node.inet.AdhocHost;\n\
	import inet.node.inet.INetworkNode;\n\
	import inet.node.mpls.LDP_LSR;\n\
	import inet.physicallayer.contract.packetlevel.IRadioMedium;\n\
	import broadcasting.CenterHost;\n"
NED_MIDDLE = "string mediumType = default(" + '"IdealRadioMedium");\n' +\
  "submodules:\nconfigurator: IPv4NetworkConfigurator {\n@display(" +\
  '"p=0,0");\n}\nradioMedium: <mediumType> like IRadioMedium{\n' +\
	"@display(" + '"p=0,0");}\n'

def getArgs():
	p = argparse.ArgumentParser(description='Creates a network with N regions of density.')
	p.add_argument('--cma-w', dest='cma_w', type=int, default=100,
		help='width of the communication area')
	p.add_argument('--regions', dest='regions', type=int, default=1,
		help='number of regions within the communication area')
	p.add_argument('--nodes-no', dest='nodes_no', type=int, default=100,
		help='number of nodes on each region')
	return p.parse_args()

def getDistance(a, b):
	return math.sqrt(math.pow(a['x'] - b['x'], 2) + math.pow(a['y'] - b['y'], 2))

if __name__ == '__main__':
	args = getArgs()
	densPerLevel = { 0: args.nodes_no }
	for i in range(1, args.regions + 1):
		matrixLen = 3 + 2 * (i - 1)
		sqrtsNo = 4 * (matrixLen - 1)
		densPerLevel[i] =  int(math.ceil(args.nodes_no / sqrtsNo))
	matrixLen = 3 + 2 * (args.regions - 1)
	sqrtLen = float(args.cma_w / matrixLen)
	deltSqrt = float(sqrtLen / 2)
	center = { 'x': float(args.cma_w / 2), 'y': float(args.cma_w / 2) }
	centers = {}; peerId = 1; nodesList = ""
	for i in range(1, matrixLen + 1):
		centers[i] = {}
		for j in range(1, matrixLen + 1):
			centers[i][j] = {'x': (j - 1) * sqrtLen + deltSqrt, 'y': (i - 1) * sqrtLen + deltSqrt}
			d = getDistance(center, centers[i][j])
			if d < deltSqrt:
				centers[i][j]['density'] = densPerLevel[0]
				nodesList += "//Center region with {0} nodes\n".format(densPerLevel[0])
			else:
				for k in range(1, args.regions + 1):
					if d < (k + 1) * sqrtLen:
						centers[i][j]['density'] = densPerLevel[k]
						break
			g = nx.Graph()
			g.add_nodes_from(range(1, centers[i][j]['density'] + 1))
			p = (centers[i][j]['x'], centers[i][j]['y'])
			pos = nx.random_layout(g, scale=sqrtLen, center=p)
			for k in range(1, len(pos) + 1):
				pInX = pos[k][0]; pInY = pos[k][1]
				nodesList += "hostR{0}: CenterHost ".format(peerId) + "{@display(" + '"' + \
					"p={0},{1}".format(pInX, pInY) + '"' + ");}\n"
				peerId += 1
	fileName = "n_{0}_d_0_tr_X_a_{1}x{1}_idx_0_p_".format(peerId - 1, args.cma_w)
	with open(fileName + ".ned", "a") as f:
		f.write(NED_HEADER)
		f.write( "network " + fileName + " {\n@display(" + \
			'"' + "bgb={0}, {0}".format(args.cma_w) + '"' + ");\n" )
		f.write(NED_MIDDLE)
		f.write(nodesList + "}")
