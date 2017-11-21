#!/usr/bin/python
import math
import argparse

NED_HEAD = "package rand_uniform_topologies;\n\
  import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;\n\
  import inet.node.inet.INetworkNode;\n\
  import inet.physicallayer.contract.packetlevel.IRadioMedium;\n\
  import broadcasting.CenterHost;\n"
NED_MIDD = "string mediumType = default(" + '"IdealRadioMedium");\n' +\
  "submodules:\nconfigurator: IPv4NetworkConfigurator {\n@display(" +\
  '"p=0,0");\n}\nradioMedium: <mediumType> like IRadioMedium{\n' +\
  "@display(" + '"p=0,0");}\n'

def getArgs() :
	p = argparse.ArgumentParser(description='Creates a NED file from the initial'+
		' positions of nodes within a trace of mobility. Omnet++ requires NED ' +
		'to represent a network topology.')
	p.add_argument('--cma-w', dest='cma_w', type=int, default=100,
		help='width of the communication area')
	p.add_argument('--transmission-range', dest='Tx', type=int, default=15,
		help='transmission range of each node')
	p.add_argument('--mobility-trace', dest='mobTrace', type=str,
		default="mobility-trace", help='file with a mobiliy trace of nodes')
	return p.parse_args()

def getCoordinate(coorAsStr) :
	return (float(coorAsStr.split(" ")[0]), float(coorAsStr.split(" ")[1]))

if __name__ == '__main__' :
	args = getArgs()
	with open(args.mobTrace, 'r') as f :
		nodes_no = int(f.readline()); f.readline()
		initialPos = [ getCoordinate(f.readline()) for i in range(0, nodes_no)]
	nedFilename = 'n_' + str(nodes_no) + '_d_0_tr_' + str(args.Tx) + '_a_' +\
		str(args.cma_w) + 'x' + str(args.cma_w) + '_idx_0_p_'
	content = NED_HEAD + 'network ' + nedFilename + '{\n@display("bgb=' +\
		str(args.cma_w) + ', ' + str(args.cma_w) + '");\n' + NED_MIDD
	for i in range(1, nodes_no + 1) :
		content += "hostR{0}: CenterHost ".format(i) + "{@display(" + '"' +\
			"p={0},{1}".format(initialPos[i - 1][0], initialPos[i - 1][1]) + '"' +\
			");}\n"
	content += "}"
	with open(nedFilename + '.ned', 'a') as f : f.write(content)
