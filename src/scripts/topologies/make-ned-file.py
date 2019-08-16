#!/usr/bin/python
import math
import argparse

NED_HEAD = "package built_topologies;\n\
import inet.physicallayer.idealradio.IdealRadioMedium;\n\
import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;\n\
import inet.common.lifecycle.LifecycleController;\n\
import emergent_overlays.tunned_modules.Cellphone;\n"

NED_MIDD = "submodules:\nlifecycleController: LifecycleController;\n\
radioMedium: IdealRadioMedium;\nconfigurator: IPv4NetworkConfigurator;\n"

def getArgs() :
	p = argparse.ArgumentParser(description='Creates a NED file from the initial'+
		' positions of nodes within a trace of mobility. Omnet++ requires NED ' +
		'to represent a network topology.')
	p.add_argument('--cma-len', dest='cma_l', type=int, default=100,
		help='length of the communication area')
	p.add_argument('--cma-width', dest='cma_w', type=int, default=100,
		help='width of the communication area')
	p.add_argument('--transmission-range', dest='Tx', type=int, default=15,
		help='transmission range of each node')
	p.add_argument('--nodes', dest='nodes', type=int,
		help='nodes number in mobility trace')
	p.add_argument('--scenario-id', dest='scenario', type=int, default=1,
		help='identifier of scenario')
	return p.parse_args()

def getNedFileName():
	return 'n_' + str(ARGS.nodes) + '_d_0_tr_' + str(ARGS.Tx) + '_a_' +\
		str(ARGS.cma_l) + 'x' + str(ARGS.cma_w) + '_idx_0_p_'

def getCoordinate(coorAsStr) :
	return (float(coorAsStr.split(" ")[1]), float(coorAsStr.split(" ")[2]))

def getNedForOnePoIscenario():
	with open(TRACE, 'r') as f :
		initialPos = [ getCoordinate(f.readline()) for i in range(0, ARGS.nodes)]
	c = CONTENT
	for i in range(1, ARGS.nodes + 1) :
		c += "host{0}: Cellphone ".format(i) + "{@display(" + '"' +\
			"p={0},{1}".format(initialPos[i - 1][0], initialPos[i - 1][1]) + '"' +\
			");}\n"
	c += "}"
	with open(NED_FILE + '.ned', 'a') as f : f.write(c)

def getNedForBipartiteScenario():
	with open(TRACE, 'r') as f:
		coords = (f.readline()).split(' ')
	c = CONTENT
	for n in range(0, ARGS.nodes):
		xy = coords[n].split(',')
		c += "host{0}: Cellphone ".format(n + 1) + "{@display(" + '"' +\
			"p={0},{1}".format(xy[0], xy[1]) + '"' + ");}\n"
	c += "}"
	with open(NED_FILE + '.ned', 'a') as f : f.write(c)

ARGS = getArgs()
NED_FILE = getNedFileName()
CONTENT = NED_HEAD + 'network ' + NED_FILE + '{\n' + NED_MIDD
TRACE = None

if __name__ == '__main__' :
	if ARGS.scenario == 1:
		TRACE = 'distribution-per-density'
		getNedForOnePoIscenario();
	if ARGS.scenario == 2:
		TRACE = 'bipartite-scenario-1st-position'
		getNedForBipartiteScenario()

