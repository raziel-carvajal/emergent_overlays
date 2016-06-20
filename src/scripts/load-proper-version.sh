#!/bin/bash

if [ $# -lt 1 ]; then
   echo "Wrong number of parameters"
   echo "Usage: $0 SHA1"
   exit 1
fi

# sha1 of the revision you one to check out
SHA1=$1

git checkout ${SHA1}
