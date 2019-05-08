#!/usr/bin/python
import math
import argparse

NED_HEAD = "package built_topologies;\n\
import inet.physicallayer.idealradio.IdealRadioMedium;\n\
import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;\n\
import inet.common.lifecycle.LifecycleController;\n\
import emergent_overlays.tunned_modules.Cellphone;\n\
"

NED_MIDD = "submodules:\n\
lifecycleController: LifecycleController;\n\
radioMedium: IdealRadioMedium;\n\
configurator: IPv4NetworkConfigurator;\n\
"

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
	p.add_argument('--mobility-trace', dest='mobTrace', type=str,
		default="distribution-per-density", help='file with a mobiliy trace of nodes')
	p.add_argument('--nodes', dest='nodes', type=int,
		help='nodes number in mobility trace')
	return p.parse_args()

def getCoordinate(coorAsStr) :
	return (float(coorAsStr.split(" ")[1]), float(coorAsStr.split(" ")[2]))

if __name__ == '__main__' :
	args = getArgs()
	with open(args.mobTrace, 'r') as f :
		initialPos = [ getCoordinate(f.readline()) for i in range(0, args.nodes)]
	nedFilename = 'n_' + str(args.nodes) + '_d_0_tr_' + str(args.Tx) + '_a_' +\
		str(args.cma_l) + 'x' + str(args.cma_w) + '_idx_0_p_'
	content = NED_HEAD + 'network ' + nedFilename + '{\n' + NED_MIDD
	for i in range(1, args.nodes + 1) :
		content += "host{0}: Cellphone ".format(i) + "{@display(" + '"' +\
			"p={0},{1}".format(initialPos[i - 1][0], initialPos[i - 1][1]) + '"' +\
			");}\n"
	content += "}"
	with open(nedFilename + '.ned', 'a') as f : f.write(content)
