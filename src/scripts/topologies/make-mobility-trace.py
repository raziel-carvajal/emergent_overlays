#!/usr/bin/python
import sys
import math
import argparse
import networkx as nx
from time import sleep
import itertools as iterT
import matplotlib.pyplot as plt
from pymobility.models.mobility import random_direction
from pymobility.models.mobility import truncated_levy_walk

MIN_LOW_VELOCITY = 0.0
MAX_LOW_VELOCITY = 1.0
MIN_HIG_VELOCITY = 1.5
MAX_HIG_VELOCITY = 2.0
WAITING_TIME = 1.0
FIRST_PLOT_NAME = "Position_"
MOBILITY_FILE= "mobility-trace"
DIST_PER_ZONE= "distribution-per-density"

def getArgs() :
	p = argparse.ArgumentParser(description='Creates a network with N regions '+
		'of density.')
	p.add_argument('--cma-w', dest='cma_w', type=int, default=100,
		help='width of the communication area')
	p.add_argument('--regions', dest='regions', type=int, default=1,
		help='number of regions within the communication area')
	p.add_argument('--nodes-no', dest='nodes_no', type=int, default=100,
		help='number of nodes on each region')
	p.add_argument('--transmission-range', dest='Tx', type=int, default=25,
		help='transmission range of each node')
	p.add_argument('--overlays-no', dest='overlays', type=int, default=50,
		help='number of overlays to create')
	return p.parse_args()

def getDistance(a, b) :
	return math.sqrt(math.pow(a['x'] - b['x'], 2) + math.pow(a['y'] - b['y'], 2))

def getInitialPosition(nodes, denZoneNo, cmaW) :
	denZones = { }
	for i in range(0, denZoneNo) :
		matxLen = 1 + 2 * i
		sqrtsNo = 4 * (matxLen - 1)
		if sqrtsNo == 0 :
			denZones[i] = { 'nodes': nodes, 'zoneId': i }
		else :
			denZones[i] = { 'nodes': int(math.ceil(nodes / sqrtsNo)), 'zoneId': i }
	sqrtLen = float(cmaW / matxLen)
	deltSqrt = float(sqrtLen / 2)
	theCenter = { 'x': float(cmaW / 2), 'y': float(cmaW / 2) }
	centers = {}
	positions = {}
	nodeId = 1
	for i in range(0, matxLen) :
		centers[i] = {}
		for j in range(0, matxLen) :
			centers[i][j] = { 'x': j*sqrtLen + deltSqrt, 'y': i*sqrtLen + deltSqrt }
			d = getDistance(theCenter, centers[i][j])
			if d < deltSqrt :
				centers[i][j]['density'] = denZones[0]['nodes']
				centers[i][j]['zoneId'] = denZones[0]['zoneId']
			else :
				for k in range(1, denZoneNo + 1) :
					if d < (k + 1) * sqrtLen :
						centers[i][j]['density'] = denZones[k]['nodes']
						centers[i][j]['zoneId'] = denZones[k]['zoneId']
						break
			g = nx.Graph()
			nodesRange = range(0, centers[i][j]['density'])
			g.add_nodes_from(nodesRange)
			pos = nx.random_layout(g, scale=sqrtLen,
				center=(centers[i][j]['x'], centers[i][j]['y']))
			for k in nodesRange :
				positions[nodeId] = {'x': pos[k][0], 'y': pos[k][1]}
				nodeId = nodeId + 1
	#XXX latest node is located at the center of the communication area
	positions[nodeId] = {'x': theCenter['x'], 'y': theCenter['y']}
	return positions, centers, deltSqrt

def plotNodesPositions(pos, pltWidth) :
	layout = plt.subplot(111)
	layout.plot(pltWidth, pltWidth, linestyle='', marker='.')
	plt.scatter( [ pos[p]['x'] for p in pos], [ pos[p]['y'] for p in pos] )
	plt.savefig(FIRST_PLOT_NAME)
	plt.clf()

def plotOverlay(iD, graph, positions, xMax, yMax) :
	pTmp = {}
	for k, v in positions.iteritems():
		pTmp[k] = [ v['x'], v['y'] ]
	plt.subplot(111)
	plt.xlim((0, xMax))
	plt.ylim((0, yMax))
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

def getNextOverlay(mobModLowS, mobModHigS, nodes_no, latestP,
	Tx, staticPo, xlim, ylim, halfSqr) :
	# every node is moving once using the mobility model with low speed
	p_iLowS = [ (k[0], k[1]) for k in next(mobModLowS) ]
	p_jLowS = [ (k[0], k[1]) for k in next(mobModLowS) ]
	pDifLowS= [ (p_jLowS[k][0] - p_iLowS[k][0], p_jLowS[k][1] - p_iLowS[k][1]) \
		for k in range(0, nodes_no) ]
	# every node is moving once using the mobility model with high speed
	p_iHigS = [ (k[0], k[1]) for k in next(mobModHigS) ]
	p_jHigS = [ (k[0], k[1]) for k in next(mobModHigS) ]
	pDifHigS= [ (p_jHigS[k][0] - p_iHigS[k][0], p_jHigS[k][1] - p_iHigS[k][1]) \
		for k in range(0, nodes_no) ]
	for k, v in latestP.iteritems() :
		pAtLowS = { 'x': v['x'] + pDifLowS[k-1][0], 'y': v['y'] + pDifLowS[k-1][1] }
		pAtHigS = { 'x': v['x'] + pDifHigS[k-1][0], 'y': v['y'] + pDifHigS[k-1][1] }
		# if one node is positioned at the dense area, the high-speed mobility
		# model is used
		atDensZlow = inSquare(pAtLowS, staticPo, halfSqr)
		atDensZhig = inSquare(pAtHigS, staticPo, halfSqr)
		if atDensZlow and atDensZhig :
			point = pAtLowS
		elif (not atDensZlow) and atDensZhig :
			point = pAtLowS
		elif atDensZlow and (not atDensZhig) :
			point = pAtHigS
		else :
			point = pAtHigS
		# force nodes to respect the "appear to other side" policy (a way to fix
		#	the bug in the mobility model)
		if point['x'] < 0 :
			point['x'] = xlim + point['x']
		else :
			if point['x'] > xlim :
				point['x'] = point['x'] - xlim
		if point['y'] < 0 :
			point['y'] = ylim + point['y']
		else :
			if point['y'] > ylim :
				point['y'] = point['y'] - ylim
		latestP[k] = point
	latestP[len(latestP) + 1] = { 'x': staticPo['x'], 'y': staticPo['y'] }
	return getOverlay(latestP, Tx), latestP

def inSquare(point, center, halfSqr) :
	inAbs = center['x'] - halfSqr <= point['x'] and \
		center['x'] + halfSqr >= point['x']
	inOrd = center['y'] - halfSqr <= point['y'] and \
		center['y'] + halfSqr >= point['y']
	return inAbs and inOrd

def savePosPerZone(positions, centers, halfSqr) :
	for i in range(0, len(centers)) :
		for j in range(0, len(centers[i])) :
			c = { 'x': centers[i][j]['x'], 'y': centers[i][j]['y'] }
			with open(DIST_PER_ZONE, 'a') as f:
				for k, v in positions.iteritems() :
					if inSquare(v, c, halfSqr) :
						zoneId = centers[i][j]['zoneId']
						f.write( "%d %f %f %d\n" % (k, v['x'], v['y'], zoneId) )

if __name__ == '__main__':
	args = getArgs()
	tryNo = 0
	hasPartitions = True
	while hasPartitions :
		latestP, centers, halfSqr = getInitialPosition(args.nodes_no, args.regions,
			args.cma_w)
		latestOv = getOverlay(latestP, args.Tx)
		hasPartitions = not isConnected(latestOv)
		if not hasPartitions :
			plotOverlay(0, latestOv, latestP, args.cma_w, args.cma_w)
			savePosPerZone(latestP, centers, halfSqr)
		tryNo = tryNo + 1
		print("Try number to create P0 [" + str(tryNo) + "]")
	args.nodes_no = len(latestP)
	with open(MOBILITY_FILE, 'a') as f:
		f.write(str(args.nodes_no) + "\n" + str(WAITING_TIME) + "\n")
	savePositions(latestP)
	print("First connected graph was created")
	tryNo = 1
	connectedOvs = 0
	mobModLowS = random_direction(
		args.nodes_no - 1,
		(args.cma_w, args.cma_w),
		wt_max=WAITING_TIME,
		velocity=(MIN_LOW_VELOCITY, MAX_LOW_VELOCITY)
	)
	mobModHigS = random_direction(
		args.nodes_no - 1,
		(args.cma_w, args.cma_w),
		wt_max=WAITING_TIME,
		velocity=(MIN_HIG_VELOCITY, MAX_HIG_VELOCITY)
	)
	# latest node in list of positions is located at the center of
	# the communication area, for the moment, this node acts at the source
	# of every broadcast session
	staticNodeId = args.nodes_no
	staticNodePo = latestP[staticNodeId]
	while connectedOvs <= args.overlays :
		del latestP[staticNodeId]
		latestOv, latestP = getNextOverlay(mobModLowS, mobModHigS,
			args.nodes_no - 1, latestP, args.Tx, staticNodePo,
			args.cma_w, args.cma_w, halfSqr)
		savePositions(latestP)
		savePosPerZone(latestP, centers, halfSqr)
		plotOverlay(connectedOvs, latestOv, latestP, args.cma_w, args.cma_w)
		print("Number of connected overlays [" + str(connectedOvs) + "]")
		connectedOvs = connectedOvs + 1
