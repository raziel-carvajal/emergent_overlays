#!/usr/bin/python
import os
import math
import argparse
import networkx as nx
import itertools as iterT
import matplotlib.pyplot as plt
from pymobility.models.mobility import random_direction

MIN_LOW_VELOCITY = 0.0
MAX_LOW_VELOCITY = 1.0
MIN_HIG_VELOCITY = 1.5
MAX_HIG_VELOCITY = 2.0
WAITING_TIME = float(os.environ['NODES_MOV_FREQ'])
FIRST_PLOT_NAME = 'Position_'
MOBILITY_FILE= 'mobility-trace'
DIST_PER_ZONE= 'distribution-per-density'

allPositions = {}

def getArgs() :
	p = argparse.ArgumentParser(description='creates a mobility trace of a '+
		'wireless topology with 2 zones (dense and sparse)')
	# options of communication area
	p.add_argument('--cma-length', dest='area_l', type=int, default=100,
		help='communication area length')
	p.add_argument('--cma-width', dest='area_w', type=int, default=100,
		help='communication area width')
	p.add_argument('--dense-area-length', dest='dense_area_l', type=int, default=100,
		help='dense area length')
	p.add_argument('--dense-area-width', dest='dense_area_w', type=int, default=100,
		help='dense area width')
	# number of nodes per area
	p.add_argument('--nodes-at-dense', dest='nodes_at_dense', type=int, default=50,
		help='')
	p.add_argument('--nodes-at-sparse', dest='nodes_at_sparse', type=int, default=50,
		help='')
	# 
	p.add_argument('--transmission-range', dest='tx', type=int, default=10,
		help='transmission range of each node')
	p.add_argument('--trace-size', dest='trace_size', type=int, default=50,
		help='number of wireless topologies formed every time nodes move')
	p.add_argument('--motion-freq', dest='motion_freq', type=float, default=1.0,
		help='frequency (in seconds) at which nodes move; every motion_freq seconds \
		all nodes move following the Levy-walk model')
	return p.parse_args()

class CommunicationArea :
	def __init__(self, nodes, cmaDim, denseAdim, nodesPerArea) :
		print cmaDim
		self.length = cmaDim['len']
		self.width = cmaDim['wid']
		self.center = {
			'x': float( "%.3f"%(cmaDim['len'] / 2) ),
	  		'y': float( "%.3f"%(cmaDim['wid'] / 2) ) }
		self.denseAlen = float( "%.3f"%(denseAdim['len']) )
		self.denseAwid = float( "%.3f"%(denseAdim['wid']) )

		# NOTE REQUIRED AS OUTPUT
		print "CMA_CENTER", self.center['x'], self.center['y']
		print "DENSE_AREA_DIMENSIONS", self.denseAlen, self.denseAwid
		print "FIRST_NODE_AT_DENSE_AREA", nodesPerArea['sparse'] + 1
		print "SOURCE_NODE_ID", nodes + 1

		# sparse area contains four subregions
		self.nodesAtSubA = nodesPerArea['sparse'] / 4
		self.nodesRem = nodesPerArea['sparse'] % 4
		self.nodesAtDenseA = nodesPerArea['dense']

		self.sparseSubAlen = float( "%.3f"%( (self.length - self.denseAlen) / 2.0 ) )
		self.sparseSubAwid = float( "%.3f"%( (self.width - self.denseAwid) / 2.0 ) )
		self.subAreas = [
			{'id': 1, 'x': 0, 'y': 0, 'verSubArea': True, 'isDense': False, \
				'nodesNo': self.nodesAtSubA + self.nodesRem},
			{'id': 2, 'x': self.sparseSubAlen, 'y': 0, 'verSubArea': False, \
				'isDense': False, 'nodesNo': self.nodesAtSubA},
			{'id': 3, 'x': self.sparseSubAlen + self.denseAlen, 'y': 0, \
				'verSubArea': True, 'isDense': False, 'nodesNo': self.nodesAtSubA},
			{'id': 4, 'x': self.sparseSubAlen, 'y': self.sparseSubAwid + self.denseAwid, \
				'verSubArea': False, 'isDense': False, 'nodesNo': self.nodesAtSubA},
			{'id': 5, 'x': self.sparseSubAlen, 'y': self.sparseSubAwid, \
				'verSubArea': False, 'isDense': True, 'nodesNo': self.nodesAtDenseA} ]

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

def generateWirelessTopologies(cma, topNo, Tx, motionIndx):
	mobModels = {}
	# new instance of mobility model per sub area
	for subArea in cma.subAreas :
		if subArea['isDense'] :
			areaDim = (cma.denseAlen, cma.denseAwid)
			velocity = (MIN_LOW_VELOCITY, MAX_LOW_VELOCITY)
		else:
			abscissa = cma.sparseSubAlen if subArea['id'] % 2 == 1 else cma.denseAwid
			ordinate = cma.length if subArea['id'] % 2 == 1 else cma.sparseSubAlen
			areaDim = (abscissa, ordinate)
			velocity = (MIN_HIG_VELOCITY, MAX_HIG_VELOCITY)
		mobModels[ subArea['id'] ] = random_direction( subArea['nodesNo'], areaDim, \
			wt_max=WAITING_TIME, velocity=velocity, border_policy='reflect' )
	t = 0
	# noves move ${topNo} times following the Levy-Walk model in dense and sparse areas
	while t < topNo :
		nodeId = 1; positions = {}
		# iter in order to have every position identified in an unique way
		for i in range(0, len(cma.subAreas)) :
			subArea = cma.subAreas[i]
			mobModel = mobModels[ subArea['id'] ]
			incrAt = { 'x': subArea['x'], 'y': subArea['y'] }
			coords = makeStep(mobModel, incrAt, nodeId, subArea['isDense'])
			nodeId += len(coords)
			positions.update(coords)
		# source node is positioned at the center of communication area
		positions[nodeId] = { 'x': cma.center['x'], 'y': cma.center['y'], 'atDenseZone': True }
		# draw wireles topology
		o = getOverlay(positions, Tx); plotOverlay(o, positions, cma.length, t)
		# keep positions in a global reference
		allPositions[motionIndx] = positions; motionIndx += 1
		t += 1

def makeStep(mobMod, incrAt, lastPosition, atDenseZone) :
	positions = {}
	coords = [ (k[0] + incrAt['x'], k[1] + incrAt['y']) for k in next(mobMod) ]
	for c in coords :
		positions[lastPosition] = {'x': c[0], 'y': c[1], 'atDenseZone': atDenseZone}
		lastPosition += 1
	return positions

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

def savePositions(motion_freq) :
	# keep 1st wireless topology in a separate file
	with open(DIST_PER_ZONE, 'a') as f :
		for i in range(0, len(allPositions[0])) :
			p = allPositions[0][ i + 1 ]
			f.write( "%d %f %f %d\n" % (i + 1, p['x'], p['y'], int(p['atDenseZone'])) )
	allPositionsAsStr = {}
	# keep all positions in the mobility file
	for i in range(0, len(allPositions)) :
		coords = allPositions[i]
		for m in range(1, len(coords) + 1) :
			coord = coords[m]
			trace = "%f %f %f" % (motion_freq * i, coord['x'], coord['y'])
			if m in allPositionsAsStr :
				allPositionsAsStr[m] += " " + trace
			else :
				allPositionsAsStr[m] = trace
	with open(MOBILITY_FILE, 'a') as f:
		f.write("\n")
		for k in range(1, len(allPositionsAsStr) + 1) :
			f.write(allPositionsAsStr[k] + "\n")

if __name__ == '__main__':
	args = getArgs()
	cma = {'len': args.area_l, 'wid': args.area_w}
	densA = {'len': args.dense_area_l, 'wid': args.dense_area_w}
	nodesPerArea = { 'dense': args.nodes_at_dense, 'sparse': args.nodes_at_sparse }
	# initialise details of communication area
	comArea = CommunicationArea( \
		args.nodes_at_dense + args.nodes_at_sparse, cma, densA, nodesPerArea)
	# create ${args.trace_size} wireless topologies, all positions are kept using
	# the BonnMotion format, see more at https://omnetpp.org/doc/inet/api-current/neddoc/inet.mobility.single.BonnMotionMobility.html
	generateWirelessTopologies(comArea, args.trace_size, args.tx, 0)
	savePositions(args.motion_freq)
