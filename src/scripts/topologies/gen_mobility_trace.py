#!/usr/bin/python
import os
# import sys
import math
import argparse
import networkx as nx
# from time import sleep
import itertools as iterT
import matplotlib.pyplot as plt
from pymobility.models.mobility import random_direction
from pymobility.models.mobility import truncated_levy_walk

MIN_LOW_VELOCITY = 0.0
MAX_LOW_VELOCITY = 1.0
MIN_HIG_VELOCITY = 1.5
MAX_HIG_VELOCITY = 2.0
# WAITING_TIME = int(os.environ['NODES_MOV_FREQ'])
FIRST_PLOT_NAME = 'Position_'
MOBILITY_FILE= 'mobility-trace'
DIST_PER_ZONE= 'distribution-per-density'

def getArgs() :
	p = argparse.ArgumentParser(description='creates a mobility trace of a '+
		'wireless topology with 2 zones (dense and sparse)')
	p.add_argument('--area-length', dest='area_l', type=int, default=100,
		help='communication area length')
	p.add_argument('--nodes-no', dest='nodes_no', type=int, default=50,
		help='number of nodes on each zone')
	p.add_argument('--transmission-range', dest='tx', type=int, default=10,
		help='transmission range of each node')
	p.add_argument('--trace-size', dest='trace_size', type=int, default=50,
		help='number of wireless topologies formed when nodes move')
	return p.parse_args()

class CommunicationArea :
    def __init__(self, length=100) :
        self.length = length
        self.center = {'x': length / 2, 'y': length / 2}
        self.denseAlen = length / math.sqrt(2)
        self.sparseSubAwidth = self.center['x'] - (self.denseAlen / 2)
        self.sqrtNoVer = int( math.floor(self.length / self.sparseSubAwidth) )
        self.sqrtNoHor = int( math.floor(self.denseAlen / self.sparseSubAwidth) )
        print "Total number of cells:", 2 * (self.sqrtNoHor + self.sqrtNoVer)
        self.sparseRegions = [
            # initial position of vertical rectangles
            {'x': 0, 'y': 0}, {'x': self.sparseSubAwidth + self.denseAlen, 'y': 0},
            # initial position of horizontal rectangles
            {'x': self.sparseSubAwidth, 'y': 0},
            {'x': self.sparseSubAwidth, 'y': self.sparseSubAwidth + self.denseAlen}
        ]

    def setNodesPerSqrt(self, nodes) :
        self.nodesPerSubSqrt = int( math.ceil( nodes / ( (self.sqrtNoHor + self.sqrtNoVer) * 2 ) ) )
        print "Nodes number per cell:", self.nodesPerSubSqrt

    def inDenseArea(self, x, y) :
    	atAbs = self.center['x'] - (self.denseAlen / 2) <= x and \
            self.center['x'] + (self.denseAlen / 2) >= x
    	atOrd = self.center['y'] - (self.denseAlen / 2) <= y and \
    		self.center['y'] + (self.denseAlen / 2) >= y
    	return atAbs and atOrd

def getRandCoorAt(x, y, n, sqrtLen) :
    g = nx.Graph()
    g.add_nodes_from( range(0, n) )
    return nx.random_layout( g, scale=sqrtLen, center=(x, y) )

def appendPositions(coords, positions):
    for c in range(0, len(coords)) :
        positions[ len(positions) + 1 ] = {'x': coords[c][0], 'y': coords[c][1]}
    return positions

def getWirelessTopology(comArea, nodes) :
    positions = {}
    # create wireless topology at sparse area
    for k in range(0, len(comArea.sparseRegions)) :
        rec = comArea.sparseRegions[k]
        if rec['x'] ==  self.sparseSubAwidth: # vertical rectangle
            center_x += comArea.sparseSubAwidth / 2
            for j in range(0, comArea.sqrtNoVer) :
                center_y += center_x + (j * comArea.sparseSubAwidth)
                coords = getRandCoorAt( center_x, center_y,
                   comArea.nodesPerSubSqrt, comArea.sparseSubAwidth )
                positions = appendPositions(coords, positions)
    #     else : # horizontal rectangle
    #         center_y += comArea.sparseSubAwidth / 2
    #         for j in range(0, comArea.sqrtNoHor) :
    #             center_x += center_y + (j * comArea.sparseSubAwidth)
    #             coords = getRandCoorAt( center_x, center_y,
    #                 comArea.nodesPerSubSqrt, comArea.sparseSubAwidth )
    #             positions = appendPositions(coords, positions)
    # # create wireles topology at dense area
    # coords = getRandCoorAt( comArea.center['x'], comArea.center['y'],
    #    nodes, comArea.denseAlen )
    # positions = appendPositions(coords, positions)
    # #XXX latest node is located at the center of the communication area
    # positions[ len(positions) + 1 ] = {
    #     'x': comArea.center['x'], 'y': comArea.center['y']
    # }
    return positions

def getDistance(a, b) :
    return math.sqrt(math.pow(a['x'] - b['x'], 2) + math.pow(a['y'] - b['y'], 2))

def getOverlay(positions, transRange) :
	g = nx.Graph()
	nodes = range(1, len(positions) + 1)
	g.add_nodes_from(nodes)
	pairs = iterT.combinations_with_replacement(nodes, 2)
	for p in pairs :
		if getDistance(positions[p[0]], positions[p[1]]) <= transRange :
			g.add_edge(p[0], p[1])
	return g

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
                    # nodes at dense zone move slowly
            	    velocity = (MIN_LOW_VELOCITY, MAX_LOW_VELOCITY)
                else :
                    # nodes at sparse zone move rapidly
                    velocity=(MIN_HIG_VELOCITY, MAX_HIG_VELOCITY)
                mobMod = random_direction( \
    	            len(nodesAtSqrt), \
    	            (halfSqrt * 2, halfSqrt * 2), \
    	            wt_max=WAITING_TIME, \
    	            velocity=velocity, \
    	            border_policy='reflect' )
                # print(center)
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
    sqrtLeftInfCorner = {
        'x': center['x'] - halfSqrt, 'y': center['y'] - halfSqrt }
    i = 0
    p_i = [ (k[0], k[1]) for k in next(mobMod) ]
    p_j = [ (k[0], k[1]) for k in next(mobMod) ]
    pDif = [( abs( p_i[k][0] - p_j[k][0] ), abs( p_i[k][1] - p_j[k][1] ) ) \
        for k in range(0, len(pos)) ]
    for k, v in pos.iteritems() :
        point = { 'x': v['x'] + pDif[i][0], 'y': v['y'] + pDif[i][1] }
        # implementation of reflect policy of points within square of size:
        # [ sqrtLeftInfCorner[x] , sqrtLeftInfCorner[y] ] &&
        # [ sqrtLeftInfCorner[x] + 2 * halfSqrt,
        #   sqrtLeftInfCorner[y] + 2 * halfSqrt ]
        if point['x'] < sqrtLeftInfCorner['x'] :
            point['x'] = point['x'] + 2 * halfSqrt
        if point['x'] > sqrtLeftInfCorner['x'] + 2 * halfSqrt :
            point['x'] = point['x'] - 2 * halfSqrt
        if point['y'] < sqrtLeftInfCorner['y'] :
            point['y'] = point['y'] + 2 * halfSqrt
        if point['y'] > sqrtLeftInfCorner['y'] + 2 * halfSqrt :
            point['y'] = point['y'] - 2 * halfSqrt
        i = i + 1
        pos[k] = point
    return pos

def plotNodesPositions(pos, pltWidth) :
	layout = plt.subplot(111)
	layout.plot(pltWidth, pltWidth, linestyle='', marker='.')
	plt.scatter( [ pos[p]['x'] for p in pos], [ pos[p]['y'] for p in pos] )
	plt.savefig(FIRST_PLOT_NAME)
	plt.clf()

def plotOverlay(graph, positions, maxLen, iD) :
	pTmp = {}
	for k, v in positions.iteritems():
		pTmp[k] = [ v['x'], v['y'] ]
	plt.subplot(111)
	plt.xlim((0, maxLen))
	plt.ylim((0, maxLen))
	nx.draw_networkx(graph, pos=pTmp, node_size=10, with_labels=False)
	plt.savefig(FIRST_PLOT_NAME + str(iD) + ".pdf")
	plt.clf()

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


def savePosPerZone(positions, comArea) :
    with open(DIST_PER_ZONE, 'a') as f :
        for k, v in positions.iteritems() :
            if comArea.inDenseArea( v['x'], v['y'] ) :
                f.write( "%d %f %f %d\n" % (k, v['x'], v['y'], 1) )
            else:
                f.write( "%d %f %f %d\n" % (k, v['x'], v['y'], 0) )

if __name__ == '__main__':
    args = getArgs()
    comArea = CommunicationArea(args.area_l)
    comArea.setNodesPerSqrt(args.nodes_no)
    tryNo = 0; hasPartitions = True
    while hasPartitions :
        print "Wireless topology number:", tryNo
    	p = getWirelessTopology(comArea, args.nodes_no)
    	o = getOverlay(p, args.tx)
    	hasPartitions = not isConnected(o)
        plotOverlay(o, p, args.area_l, 0)
        savePosPerZone(p, comArea)
        exit()
    # 	if not hasPartitions :
    # 	tryNo = tryNo + 1
    # args.nodes_no = len(latestP)
    # with open(MOBILITY_FILE, 'a') as f:
    # 	f.write(str(args.nodes_no) + "\n" + str(WAITING_TIME) + "\n")
    # savePositions(latestP)
    # print("First connected graph was created")
    #
    # # source node remains fixed within the communication area, that's why
    # # the source node is removed to create mobility traces from the rest of nodes
    # staticNodeId = args.nodes_no
    # staticNodePo = latestP[staticNodeId]
    # del latestP[staticNodeId]
    #
    # placedNodesWithUniformDen(latestP, centers, halfSqr, staticNodePo,
    #     args.overlays, args.Tx, args.cma_w)
