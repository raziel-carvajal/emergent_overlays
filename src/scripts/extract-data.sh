#!/bin/bash

if [ ! -f $1 ]; then
   echo "Error: $1 is not a real file we can process"
   echo "Usage: $0 FileName"
fi

if [ $# -lt 3 ]; then
  echo "Error: Wrong number of paramters"
  echo "Usage: $0 VecFileName VectorToRead OutputDirectory"
fi

field=$2
output=$3

VECTORS=`cat $1 | grep $field | grep vector | awk '{print $2, $3}'`

folder=$(basename "$1")
folder="${output}/${folder%.*}"

if [ ! -d "$folder" ]; then
   mkdir "$folder"
fi

echo "$VECTORS" | while read line; do
   id=`echo ${line} | awk '{print $1}'`
   node=`echo ${line} | awk '{print $2}' | awk -F "." '{print $2}'`
   echo "a line : $id => $node"
   file="${folder}/${node}-${field}"
   echo "$file"
   cat "$1" | grep "^${id}\s" | awk '{print $1, $3, $4}' > "${file}"
done
