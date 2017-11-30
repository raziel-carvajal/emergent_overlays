#!/bin/bash -
#===============================================================================
#
#          FILE: make-topology.sh
#
#         USAGE: ./make-topology.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION:
#       CREATED: 11/29/2017 18:25
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
cma=150
regions=2
nodes=200
tx=20
overlays=126
rm -f *.pdf mobility-trace mobility-trace *.ned
./make-mobility-trace.py --cma-w ${cma} --regions ${regions} \
  --nodes-no ${nodes} --transmission-range ${tx} --overlays-no ${overlays}
s=""
for f in `ls -t *.pdf`; do
  s="${f} ${s}"
done
pdfunite ${s} all.pdf
rm -f Position_*.pdf
./make-ned-file.py --cma-w ${cma} --transmission-range ${tx}
mobF=`file *.ned | awk -F ".ned" '{ print $1}'`
mv mobility-trace "${mobF}.mobility"
mv all.pdf "${mobF}.pdf"
