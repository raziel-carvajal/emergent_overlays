FROM r-base
MAINTAINER Raziel Carvajal-Gomez <raziel.carvajal@uclouvain.be>

WORKDIR dist_generator
RUN apt update && apt -y --no-install-recommends curl

# setting up omnetpp library
RUN \
  wget https://github.com/downloads/omnetpp/omnetpp-resultfiles/omnetpp_0.2-1.tar.gz
COPY r-packages/bigdecimal.cc .
RUN tar xof omnetpp_0.2-1.tar.gz && \
  rm -f omnetpp_0.2-1.tar.gz && \
  mv bigdecimal.cc omnetpp/src/common && \
  tar czf omnetpp_0.2-1.tar.gz omnetpp && \
  rm -fr omnetpp

# installing required libraries
COPY r-packages/r-worker-pkgs.R .
RUN R CMD BATCH r-worker-pkgs.R && \
  if [ ${?} != 0 ] ; then echo 'Error: during installation of R libraries'; exit 1; fi

COPY src/scripts/get-broadcast-metrics.sh .
COPY src/scripts/get-broadcast-metrics.R .
CMD ./get-broadcast-metrics.sh
