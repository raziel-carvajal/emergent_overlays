FROM debian:9
MAINTAINER Raziel Carvajal-Gomez <raziel.carvajal@uclouvain.be>
LABEL Description="Docker image with OMNeT++ (v4.6), INET (v3.0.0) and R to simulate message dissemination in MANETs via the framework EmergentOverlays."

WORKDIR /usr/emrg-ovrl

RUN apt update
RUN apt -y --no-install-recommends install \
# OMNeT++ dependencies
  bc \
  build-essential \
  gcc \
  g++ \
  bison \
  flex \
  perl \
  tcl-dev \
  tk-dev \
  libxml2-dev \
  zlib1g-dev \
  default-jre \
  doxygen \
  graphviz \
  libwebkitgtk-1.0-0 \
  openmpi-bin \
  libopenmpi-dev \
  libpcap-dev \
# INET dependencies
  libavcodec-dev \
  libavformat-dev \
# Others
  git \
  wget \
  python \
  r-base

# Compilation of OMNeT++
ADD dockerfiles/worker/omnetpp-4.6-src.tgz .
RUN cd omnetpp-4.6 && \
  export PATH="`pwd`/bin:${PATH}" && \
  export LD_LIBRARY_PATH="`pwd`/lib:${LD_LIBRARY_PATH}" && \
  echo "PATH = ${PATH}" && \
  NO_TCL=1 ./configure && \
  make -j 4

# Fetch INET source file
RUN wget \
  https://github.com/inet-framework/inet/releases/download/v3.0.0/inet-3.0.0-src.tgz

# Compilation of INET
ADD dockerfiles/worker/sctphdr.h .
RUN tar xof inet-3.0.0-src.tgz && \
  mv inet omnetpp-4.6/samples/ && \
  mv sctphdr.h omnetpp-4.6/samples/inet/src/inet/common/serializer/sctp/headers/ && \
  cd omnetpp-4.6 && \
  export PATH="`pwd`/bin:${PATH}" && \
  cd samples/inet && \
  make makefiles && \
  make -j 4

# List of R packages to create a data-set of experimental results per dissemination protocol
ADD r-packages r-packages
# Installation of R packages
RUN cd r-packages && \
  wget https://github.com/downloads/omnetpp/omnetpp-resultfiles/omnetpp_0.2-1.tar.gz && \
  tar xof omnetpp_0.2-1.tar.gz && \
  rm -f omnetpp_0.2-1.tar.gz && \
  mv bigdecimal.cc omnetpp/src/common && \
  tar czf omnetpp_0.2-1.tar.gz omnetpp && \
  rm -fr omnetpp && \
  R CMD BATCH r-worker-pkgs.R

ADD ../../src/emergent_overlays src/emergent_overlays
ADD ../../src/scripts src/scripts

CMD cd src/scripts && \
 ./compile_protocols.sh ../../omnetpp-4.6 ../emergent_overlays && \
 ./pull_task.sh
