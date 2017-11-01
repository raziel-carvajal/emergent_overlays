#!/usr/bin/python
import sys
import math
import argparse
import networkx as nx
from time import sleep
import itertools as iterT
import matplotlib.pyplot as plt
from pymobility.models.mobility import random_waypoint
from pymobility.models.mobility import heterogeneous_truncated_levy_walk

FIRST_PLOT_NAME = "Position_"
CONNECTED_OVERLAYS = 100
MIN_VELOCITY = 0.1
MAX_VELOCITY = 1.0
WAITING_TIME = 0.1
MOBILITY_FILE= "mobility-trace"
CONEC_DATASET= "connectivity-ds"
CONEC_AT_INI_DS= "connectivity-ini-ds"
CONNECTED = "connected"
NOT_CONNECTED = "partitioned"

def getArgs() :
	p = argparse.ArgumentParser(description='Creates a network with N regions '+
		'of density.')
	p.add_argument('--cma-w', dest='cma_w', type=int, default=100,
		help='width of the communication area')
	p.add_argument('--regions', dest='regions', type=int, default=1,
		help='number of regions within the communication area')
	p.add_argument('--nodes-no', dest='nodes_no', type=int, default=100,
		help='number of nodes on each region')
	p.add_argument('--transmission-range', dest='Tx', type=int, default=15,
		help='transmission range of each node')
	return p.parse_args()

def getDistance(a, b) :
	return math.sqrt(math.pow(a['x'] - b['x'], 2) + math.pow(a['y'] - b['y'], 2))

def getInitialPosition(nodes, denZoneNo, cmaW) :
	denZones = { }
	for i in range(0, denZoneNo) :
		matxLen = 1 + 2 * i
		sqrtsNo = 4 * (matxLen - 1)
		if sqrtsNo == 0 :
			denZones[i] = nodes
		else :
			denZones[i] =  int(math.ceil(nodes / sqrtsNo))
	sqrtLen = float(cmaW / matxLen)
	deltSqrt = float(sqrtLen / 2)
	theCenter = { 'x': float(cmaW / 2), 'y': float(cmaW / 2) }
	centers = {}; positions = {}; nodeId = 1
	for i in range(0, matxLen) :
		centers[i] = {}
		for j in range(0, matxLen) :
			centers[i][j] = { 'x': j*sqrtLen + deltSqrt, 'y': i*sqrtLen + deltSqrt }
			d = getDistance(theCenter, centers[i][j])
			if d < deltSqrt :
				centers[i][j]['density'] = denZones[0]
			else :
				for k in range(1, denZoneNo + 1) :
					if d < (k + 1) * sqrtLen :
						centers[i][j]['density'] = denZones[k]
						break
			g = nx.Graph(); nodesRange = range(0, centers[i][j]['density'])
			g.add_nodes_from(nodesRange)
			pos = nx.random_layout(g, scale=sqrtLen, 
				center=(centers[i][j]['x'], centers[i][j]['y']))
			for k in nodesRange :
				positions[nodeId] = {'x': pos[k][0], 'y': pos[k][1]}
				nodeId = nodeId + 1
	return positions

def plotNodesPositions(pos, pltWidth) :
	layout = plt.subplot(111)
	layout.plot(pltWidth, pltWidth, linestyle='', marker='.')
	plt.scatter( [ pos[p]['x'] for p in pos], [ pos[p]['y'] for p in pos] )
	plt.savefig(FIRST_PLOT_NAME)
	plt.clf()
	
def plotOverlay(iD, graph, positions) :
	pTmp = {}
	for k, v in positions.iteritems():
		pTmp[k] = [ v['x'], v['y'] ]
	plt.subplot(111)
	nx.draw_networkx(graph, pos=pTmp, node_size=10, with_labels=False)
	plt.savefig(FIRST_PLOT_NAME + str(iD) + ".pdf")
	plt.clf()

def getOverlay(positions, transRange) :
	g = nx.Graph()
	nodes = range(1, len(positions) + 1)
	g.add_nodes_from(nodes)
	pairs = iterT.combinations_with_replacement(nodes, 2)
	for p in pairs :
		if getDistance(positions[p[0]], positions[p[1]]) <= transRange :
			g.add_edge(p[0], p[1])
	return g

def isConnected(g) :
	try :
		nx.average_shortest_path_length(g)
		r = True
	except :
		r = False
	return r

def savePositions(positions) :
	with open(MOBILITY_FILE, 'a') as f:
		for k, v in positions.iteritems() :
			f.write(str(v['x']) + " " + str(v['y']) + "\n")

def addConnectEntry(fileName, entry) :
	with open(fileName, 'a') as f :
		f.write(entry + "\n")

if __name__ == '__main__':
	args = getArgs()
	tryNo = 0
	hasPartitions = True
	while hasPartitions :
		latestP = getInitialPosition(args.nodes_no, args.regions, args.cma_w)
		latestOv = getOverlay(latestP, args.Tx)
		hasPartitions = not isConnected(latestOv)
		if hasPartitions :
			addConnectEntry(CONEC_AT_INI_DS, NOT_CONNECTED)
		else :		
			addConnectEntry(CONEC_AT_INI_DS, CONNECTED)			
			plotOverlay(tryNo, latestOv, latestP)
		tryNo = tryNo + 1
		print("Try number to create P0 [" + str(tryNo) + "]")
	args.nodes_no = len(latestP)
	with open(MOBILITY_FILE, 'a') as f:
		f.write(str(args.nodes_no) + "\n" + str(WAITING_TIME) + "\n")
	savePositions(latestP)
	print("First connected graph was created")
	tryNo = 0
	connectedOvs = 0
#	mobMod = random_waypoint(args.nodes_no, dimensions=(args.cma_w, args.cma_w),
#		velocity=(MIN_VELOCITY, MAX_VELOCITY), wt_max=WAITING_TIME)
	mobMod = heterogeneous_truncated_levy_walk(args.nodes_no, 
		dimensions=(args.cma_w, args.cma_w), WT_EXP=-1.8, WT_MAX=WAITING_TIME)
	while connectedOvs <= CONNECTED_OVERLAYS :
		hasPartitions = True
		while hasPartitions :
			p_i = [ (k[0], k[1]) for k in next(mobMod)]
			p_j = [ (k[0], k[1]) for k in next(mobMod)]
			pDif= [ (p_j[k][0] - p_i[k][0], p_j[k][1] - p_i[k][1]) \
				for k in range(0, args.nodes_no) ]
			for k, v in latestP.iteritems() :
				latestP[k] = { 'x': v['x'] + pDif[k-1][0], 'y': v['y'] + pDif[k-1][1] }
			latestOv = getOverlay(latestP, args.Tx)
			hasPartitions = not isConnected(latestOv)
			if hasPartitions :
				addConnectEntry(CONEC_AT_INI_DS, NOT_CONNECTED)
			else :
				addConnectEntry(CONEC_AT_INI_DS, CONNECTED)
				savePositions(latestP)
			tryNo = tryNo + 1
			plotOverlay(tryNo, latestOv, latestP)
			print("Try number to create Pi [" + str(tryNo) + "]")
		connectedOvs = connectedOvs + 1
		print("Number of connected overlays [" + str(connectedOvs) + "]")
