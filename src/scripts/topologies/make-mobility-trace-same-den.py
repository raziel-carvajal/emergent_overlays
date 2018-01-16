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
	# the communication area is representend by a NxN matrix where its entries
	# have a unique identifier (zoneId) and nodes are positioned on each entry
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
			# find out the center of each entry in the matrix
			centers[i][j] = {'x': j*sqrtLen + deltSqrt, 'y': i*sqrtLen + deltSqrt}
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
			# position nodes within an entry in a random way
			pos = nx.random_layout(g, scale=sqrtLen,
				center=(centers[i][j]['x'], centers[i][j]['y']))
			for k in nodesRange :
				positions[nodeId] = {'x': pos[k][0], 'y': pos[k][1]}
				nodeId = nodeId + 1
	#XXX latest node is located at the center of the communication area
	positions[nodeId] = {'x': theCenter['x'], 'y': theCenter['y']}
	return positions, centers, deltSqrt

def placedNodesWithUniformDen(latestPos, centers, halfSqrt, staticPo, overlays, Tx, cma_w) :
    overlayNo = 1
    while overlayNo <= overlays :
        for k_i, v_i in centers.iteritems() :
            for k_j, v_j in v_i.iteritems() :
                center = { 'x': v_j['x'], 'y': v_j['y'] }
                nodesAtSqrt = {}
                nodeIds = []
                for n in range(1, len(latestPos) + 1) :
                    if (inSquare(latestPos[n], center, halfSqrt)) :
                        nodesAtSqrt[n] = latestPos[n]
                        nodeIds.append(n)
                if v_j['zoneId'] == 0 :
            	    velocity = (MIN_LOW_VELOCITY, MAX_LOW_VELOCITY)
                else :
		    velocity=(MIN_HIG_VELOCITY, MAX_HIG_VELOCITY)
		mobMod = random_direction(
	            len(nodesAtSqrt),
	            (halfSqrt * 2, halfSqrt * 2),
	            wt_max=WAITING_TIME,
	            velocity=velocity,
	            border_policy='reflect'
		)
                nodesAtSqrt = makeStep(mobMod, nodesAtSqrt, center, halfSqrt)
                savePositions(nodesAtSqrt)
                nodeIdx = 0
                for _, newPos in nodesAtSqrt.iteritems() :
                    latestP[ nodeIds[nodeIdx] ] = newPos
                    nodeIdx = nodeIdx + 1
    	# latest node in list of positions is located at the center of
    	# the communication area, for the moment, this node acts at the source
    	# of every broadcast session
        staticId = len(latestP) + 1
        staticPo = { 'x': staticPo['x'], 'y': staticPo['y'] }
        savePositions({ staticId: staticPo })
        latestP[ staticId ] = staticPo
        savePosPerZone(latestP, centers, halfSqr)
        latestOv = getOverlay(latestP, Tx)
        plotOverlay(overlayNo, latestOv, latestP, cma_w, cma_w)
        print("Number of connected overlays [" + str(overlayNo) + "]")
        del latestP[staticId]
        overlayNo = overlayNo + 1


def makeStep(mobMod, pos, center, halfSqrt) :
    i = 0
    p_i = [ (k[0], k[1]) for k in next(mobMod) ]
    p_j = [ (k[0], k[1]) for k in next(mobMod) ]
    pDif= [ (p_j[k][0] - p_i[k][0], p_j[k][1] - p_i[k][1]) for k in range(0, len(pos)) ]
    for k, v in pos.iteritems() :
        point = { 'x': v['x'] + pDif[i][0], 'y': v['y'] + pDif[i][1] }
        i = i + 1
        pos[k] = point
    return pos

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
    staticNodeId = args.nodes_no
    staticNodePo = latestP[staticNodeId]
    del latestP[staticNodeId]
    placedNodesWithUniformDen(latestP, centers, halfSqr, staticNodePo,
        args.overlays, args.Tx, args.cma_w)
