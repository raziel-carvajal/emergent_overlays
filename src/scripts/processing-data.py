#/bin/python

import csv
import sys


results = {}

def main(argv):

	path_to_results=argv[0] + "/" + argv[1] + "-0/"
	source= argv[2]
	nr_nodes = int(argv[3])

	nodes = map(lambda x: 'hostR' + str(x),  range(nr_nodes))
	for n in nodes:
		results[n] = {}

	with open(path_to_results + source + '-msg_sent', 'rb') as csvfile:
		spamreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
		i = 0
		for row in spamreader:
			m_id = int(row[2])
			m_time = float(row[1])
			print m_id, m_time
			for n in nodes:
				with open(path_to_results + n + '-broadcast_msg_received', 'rb') as received:
					r2 = csv.reader(received, delimiter=' ', quotechar='|')
					for msg in r2:
						if int(msg[2]) == m_id:
							results[n][m_id] = float(msg[1]) - m_time
							break
				

	print "\n"

if __name__ == "__main__":
   main(sys.argv[1:])
