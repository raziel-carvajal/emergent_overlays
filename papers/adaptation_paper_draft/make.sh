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
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 07/20/2016 14:25
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
# just in case some transformations are required
#for i in `find . -name *.eps`
#do
#  f_=${i%.eps}
#  if [[ $f_.eps -nt $f_.pdf || ! -e $f_.pdf ]]
#  then
#    epstopdf $i
#  fi
#done

pdflatex main
bibtex main
pdflatex main 
pdflatex main
