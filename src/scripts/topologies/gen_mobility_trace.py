#!/usr/bin/python
import os
import math
import argparse
import networkx as nx
import itertools as iterT
import matplotlib.pyplot as plt
from pymobility.models.mobility import random_direction
from pymobility.models.mobility import truncated_levy_walk

MIN_LOW_VELOCITY = 0.0
MAX_LOW_VELOCITY = 1.0
MIN_HIG_VELOCITY = 1.5
MAX_HIG_VELOCITY = 2.0
WAITING_TIME = int(os.environ['NODES_MOV_FREQ'])
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
	# proportion of denze zone (in sqrt meters) to take into account
	p.add_argument('--dense-zone-f', dest='dense_zone_f', type=float, default=,
		help='Proportion of dense zone to take into consideration. Values varies \
		within interval [0, 1]; for instance, set this value to 0.5 means that \
		the dense zone will have half of its designed numbero of square meters.')
	return p.parse_args()

class CommunicationArea :
    def __init__(self, length=100, dense_zone_prop=0.80) :
        self.length = length
        self.center = {
            'x': float( "%.3f"%(length / 2) ),
            'y': float( "%.3f"%(length / 2) ) }
        # NOTE REQUIRED AS OUTPUT
        print "X_POSITION_OF_CMA_CENTER", self.center['x']
        self.denseAlen = float( "%.3f"%(length / math.sqrt(2)) ) * dense_zone_prop
        # NOTE REQUIRED AS OUTPUT
        print "WIDTH_OF_DENSE_REGION", self.denseAlen
        self.sparseSubAwidth = float(
            "%.3f"%( (length - self.denseAlen) / 2 ) )
        # print "sqrt length ::", self.sparseSubAwidth
        self.sqrtNoVer = int( math.floor(self.length / self.sparseSubAwidth) )
        self.sqrtNoHor = int( math.floor(self.denseAlen / self.sparseSubAwidth) )
        # print "# of vertical sqrts ::", self.sqrtNoVer, "\n# of horizontal sqrts ::",\
        #     self.sqrtNoHor
        self.sparseRegions = [
            # initial position of vertical rectangles
            {'x': 0, 'y': 0}, {'x': self.sparseSubAwidth + self.denseAlen, 'y': 0},
            # initial position of horizontal rectangles
            {'x': self.sparseSubAwidth, 'y': 0},
            {'x': self.sparseSubAwidth, 'y': self.sparseSubAwidth + self.denseAlen}
        ]

    def setNodesPerSqrt(self, nodes) :
        self.nodesPerSubSqrt = int( math.ceil(
            nodes / ( (self.sqrtNoHor + self.sqrtNoVer) * 2 ) ) )
        # NOTE REQUIRED AS OUTPUT
        print 'FIRST_NODE_AT_DENSE_AREA', \
            (self.sqrtNoHor + self.sqrtNoVer) * 2 * self.nodesPerSubSqrt + 1

def appendPositions(coords, positions, inDenseZone):
    for c in range(0, len(coords)) :
        positions[ len(positions) + 1 ] = {
            'x': coords[c][0], 'y': coords[c][1], 'inDenseZone': inDenseZone }
    return positions

def getRandCoorAt(x, y, n, sqrtLen) :
    g = nx.Graph()
    g.add_nodes_from( range(0, n) )
    return nx.random_layout( g, scale=sqrtLen, center=(x, y) )

def getWirelessTopology(comArea, nodes) :
    positions = {}
    # create wireless topology at sparse area
    for k in range(0, len(comArea.sparseRegions)) :
        rec = comArea.sparseRegions[k]
        sqrtAtX = rec['x'] + comArea.sparseSubAwidth / 2
        sqrtAtY = rec['y'] + comArea.sparseSubAwidth / 2
        # horizontal rectangle
        if rec['x'] ==  comArea.sparseSubAwidth:
            for _ in range(0, comArea.sqrtNoHor) :
                # print "horizontal center", sqrtAtX, sqrtAtY
                coords = getRandCoorAt( sqrtAtX, sqrtAtY,
                    comArea.nodesPerSubSqrt, comArea.sparseSubAwidth )
                positions = appendPositions(coords, positions, False)
                sqrtAtX += comArea.sparseSubAwidth
                # print "center (", sqrtAtX, ",", sqrtAtY, ")"
                # print positions
        # vertical rectangle
        else :
            for _ in range(0, comArea.sqrtNoVer) :
                # print "vertical center", sqrtAtX, sqrtAtY
                coords = getRandCoorAt( sqrtAtX, sqrtAtY,
                    comArea.nodesPerSubSqrt, comArea.sparseSubAwidth )
                positions = appendPositions(coords, positions, False)
                sqrtAtY += comArea.sparseSubAwidth
                # print "center (", sqrtAtX, ",", sqrtAtY, ")"
                # print positions
    # create wireles topology at dense area
    coords = getRandCoorAt( comArea.center['x'], comArea.center['y'],
       nodes, comArea.denseAlen )
    positions = appendPositions(coords, positions, True)
    # latest node is located at the center of the communication area
    positions[ len(positions) + 1 ] = \
        {'x': comArea.center['x'], 'y': comArea.center['y'], 'inDenseZone': True}
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

def getCoordsAt(center, width, length, coords) :
    result = {}
    halfWid = float( "%.3f"%(width  / 2) )
    halfLen = float( "%.3f"%(length / 2) )
    limInfAtX = center['x'] - halfWid ; limSupAtX = center['x'] + halfWid
    limInfAtY = center['y'] - halfLen ; limSupAtY = center['y'] + halfLen
    for k, v in coords.iteritems() :
        if ( v['x'] >= limInfAtX and v['x'] <= limSupAtX ) and \
           ( v['y'] >= limInfAtY and v['y'] <= limSupAtY ) : result[k] = v
    return result

def makeMobilityTrace(coords, traceLen, Tx, cma, srcNodePo, srcNodeId) :
    t = 1
    while t < traceLen :
        newCoords = {}
        # update coordinates within the sparse zone
        for r in range(0, len(cma.sparseRegions)) :
            region = cma.sparseRegions[r]
            if region['x'] == cma.sparseSubAwidth : # horizontal rectangle
                centerOfR = {
                    'x': region['x'] + ( cma.denseAlen / 2 ),
                    'y': region['y'] + ( cma.sparseSubAwidth / 2 ) }
                coordsAtR = getCoordsAt(centerOfR, cma.denseAlen, cma.sparseSubAwidth, coords)
                dimOfR = { 'width': cma.denseAlen, 'length': cma.sparseSubAwidth }
            else : # vertical rectangle
                centerOfR = {
                    'x': region['x'] + ( cma.sparseSubAwidth / 2 ),
                    'y': region['y'] + ( cma.length / 2 ) }
                coordsAtR = getCoordsAt(centerOfR, cma.sparseSubAwidth, cma.length, coords)
                dimOfR = { 'width': cma.sparseSubAwidth, 'length': cma.length }
            # nodes at sparse zone move faster
            velocity = (MIN_HIG_VELOCITY, MAX_HIG_VELOCITY)
            # initialise an instance of the Levy-Walk model
            mobMod = random_direction( len(coordsAtR), (dimOfR['width'], dimOfR['length']),
	            wt_max=WAITING_TIME, velocity=velocity, border_policy='reflect' )
            # each node moves ONLY once according to the mobility model
            coordsAtR = makeStep(mobMod, coordsAtR, centerOfR, dimOfR)
            # append coordinates
            newCoords.update(coordsAtR)

        # update coordinates within the dense zone
        coordsAtR = getCoordsAt(cma.center, cma.denseAlen, cma.denseAlen, coords)
        dimOfR = { 'width': cma.denseAlen, 'length': cma.denseAlen }
        # nodes at dense zone move slower
        velocity = (MIN_LOW_VELOCITY, MAX_LOW_VELOCITY)
        # initialise instance of mobility model
        mobMod = random_direction( len(coordsAtR), (dimOfR['width'], dimOfR['length']),
            wt_max=WAITING_TIME, velocity=velocity, border_policy='reflect' )
        coordsAtR = makeStep(mobMod, coordsAtR, cma.center, dimOfR)
        # append coordinates and add position of source node
        newCoords.update(coordsAtR); newCoords[ srcNodeId ] = srcNodePo
        # create and plot new wireless topology
        o = getOverlay(newCoords, Tx); plotOverlay(o, newCoords, cma.length, t)
        # add a new stet in the mobility trace
        savePositions(newCoords) ; t += 1

def makeStep(mobMod, coords, centeredAt, dimension) :
    p_i = [ (k[0], k[1]) for k in next(mobMod) ]
    p_j = [ (k[0], k[1]) for k in next(mobMod) ]
    pDif = [( abs( p_i[k][0] - p_j[k][0] ), abs( p_i[k][1] - p_j[k][1] ) ) \
        for k in range(0, len(p_i)) ]
    i = 0
    halfWid = float( "%.3f"%(dimension['width']  / 2) )
    halfLen = float( "%.3f"%(dimension['length'] / 2) )
    for k, v in coords.iteritems() :
        point = { 'x': v['x'] + pDif[i][0], 'y': v['y'] + pDif[i][1] }
        # reflect policy at abscise when a new point is out of the region
        if point['x'] < centeredAt['x'] - halfWid :
            point['x'] = point['x'] + 2 * halfWid
        if point['x'] > centeredAt['x'] + halfWid :
            point['x'] = point['x'] - 2 * halfWid
        # reflect policy at oordinate when a new point is out of the region
        if point['y'] < centeredAt['y'] - halfLen :
            point['y'] = point['y'] + 2 * halfLen
        if point['y'] > centeredAt['y'] + halfLen :
            point['y'] = point['y'] - 2 * halfLen
        coords[k] = point ; i += 1
    return coords

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

def withPartitions(g) :
	try :
		nx.average_shortest_path_length(g)
		r = True
	except :
		r = False
	return r

def savePositions(positions) :
    sortedKeys = sorted( positions.keys() )
    with open(MOBILITY_FILE, 'a') as f:
    	for i in range(0, len(sortedKeys)) :
            v = positions[ sortedKeys[i] ]
            f.write(str(v['x']) + " " + str(v['y']) + "\n")

def addConnectEntry(fileName, entry) :
	with open(fileName, 'a') as f :
		f.write(entry + "\n")

def savePosPerZone(positions, comArea) :
    sortedKeys = sorted( positions.keys() )
    with open(DIST_PER_ZONE, 'a') as f :
        for i in range(0, len(sortedKeys)) :
            k = sortedKeys[i] ; v = positions[k]
            f.write( "%d %f %f %d\n" % (k, v['x'], v['y'], int(v['inDenseZone'])) )

if __name__ == '__main__':
    args = getArgs()
    # initialise details of communication area
    comArea = CommunicationArea(length=args.area_l)
    comArea.setNodesPerSqrt(args.nodes_no)
    tryNo = 1; partitioned = True
    # create an initial wireless topology with no partitions
    while partitioned :
        print "new entry at mobility trace, try:", tryNo, "..."
    	coords = getWirelessTopology(comArea, args.nodes_no)
    	o = getOverlay(coords, args.tx)
        partitioned = withPartitions(o)
    	if not partitioned :
            plotOverlay(o, coords, comArea.length, 0)
            savePosPerZone(coords, comArea)
    	tryNo = tryNo + 1
    args.nodes_no = len(coords)
    # header of mobility trace
    with open(MOBILITY_FILE, 'a') as f:
    	f.write(str(args.nodes_no) + "\n" + str(WAITING_TIME) + "\n")
    # store first entry in the mobility trace
    savePositions(coords)
    print("First connected graph was created")
    # source node remains fixed within the center of the dense area
    srcNodeId = args.nodes_no ; srcNodePo = coords[srcNodeId]
    del coords[srcNodeId]
    # NOTE REQUIRED AS OUTPUT
    print 'SOURCE_NODE_ID', srcNodeId
    # store the rest of entries of the mobility trace
    makeMobilityTrace(coords, args.trace_size, args.tx, comArea, srcNodePo, srcNodeId)
