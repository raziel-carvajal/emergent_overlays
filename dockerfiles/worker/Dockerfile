FROM debian:9
MAINTAINER Raziel Carvajal-Gomez <raziel.carvajal@uclouvain.be>
LABEL Description="Docker image with OMNeT++ (v4.6), INET (v3.0.0) and R to simulate message dissemination in MANETs via the framework EmergentOverlays."

RUN mkdir /usr/emrg-ovrl && \
  mkdir /usr/emrg-ovrl/tools && \
  mkdir /usr/emrg-ovrl/built && \
  mkdir -p /usr/emrg-ovrl/src/scripts

WORKDIR /usr/emrg-ovrl

RUN apt-get update
RUN apt-get -y install \
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

# Fetch OMNeT++ source file
ADD dockerfiles/worker/omnetpp-4.6-src.tgz ./

# Fetch INET source file
RUN wget \
  https://github.com/inet-framework/inet/releases/download/v3.0.0/inet-3.0.0-src.tgz

# Compilation of OMNeT++
ENV PATH $PATH:/usr/emrg-ovrl/tools/omnetpp-4.6/bin
ENV OMNET_PATH /usr/emrg-ovrl/tools/omnetpp-4.6
RUN mv omnetpp-4.6-src.tgz tools/ && \
  cd tools && \
  tar xof omnetpp-4.6-src.tgz && \
  cd omnetpp-4.6 && \
  NO_TCL=1 ./configure && \
  make -j 4

# Compilation of INET
RUN mv inet-3.0.0-src.tgz tools/ && \
  cd tools && \
  tar xof inet-3.0.0-src.tgz && \
  mv inet omnetpp-4.6/samples/
# Apply patch
COPY dockerfiles/worker/sctphdr.h tools/omnetpp-4.6/samples/inet/src/inet/common/serializer/sctp/headers/sctphdr.h
RUN cd tools/omnetpp-4.6/samples/inet && \
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

COPY src/base ./src/base
COPY src/protocols ./src/protocols
ADD src/scripts/*.sh src/scripts/
ADD src/scripts/*.R src/scripts/

CMD cd /usr/emrg-ovrl/src/scripts && \
  ./compile_protocols.sh ../protocols ../../built && \
  ./pull_task.sh
