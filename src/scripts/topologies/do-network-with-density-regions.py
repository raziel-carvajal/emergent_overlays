import networkx as nx
import matplotlib.pyplot as plt
import argparse
import sys
import math

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
	matrixLen = 3 + (args.regions - 1) * 2
	sqrtLen = float(args.cma_w / matrixLen)
	deltSqrt = float(sqrtLen / 2)
	center = { 'x': float(args.cma_w / 2), 'y': float(args.cma_w / 2) }
	centers = {}; peerId = 1
	with open("output.ned", "a") as f:
		for i in range(1, matrixLen + 1):
			centers[i] = {}
			for j in range(1, matrixLen + 1):
				centers[i][j] = {'x': (j - 1) * sqrtLen + deltSqrt, 'y': (i - 1) * sqrtLen + deltSqrt}
				d = getDistance(center, centers[i][j])
				if d < 1:
					centers[i][j]['density'] = densPerLevel[0]
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
					line = "hostR{0}: CenterHost ".format(peerId) + "{@display(" + '"' + \
						"p={0},{1}".format(pInX, pInY) + '"' + ");}\n"
					peerId = peerId + 1
					f.write(line)
