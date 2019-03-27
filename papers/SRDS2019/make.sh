#!/bin/bash - 
#===============================================================================
#
#          FILE: make.sh
# 
#         USAGE: ./make.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION: 
#       CREATED: 05/15/2018 14:26
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

pdflatex main
bibtex main
pdflatex main 
pdflatex main
