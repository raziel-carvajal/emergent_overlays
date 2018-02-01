FROM ubuntu:14.04.5
MAINTAINER Raziel Carvajal-Gomez <raziel.carvajal@uclouvain.be>
LABEL Description="Docker image with OMNeT++ (v4.6), INET (v3.0.0) and R to simulate message dissemination in MANETs via the framework EmergentOverlays."

RUN mkdir /usr/emrg-ovrl && \
  mkdir /usr/emrg-ovrl/tools && \
  mkdir /usr/emrg-ovrl/built
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
RUN wget \
  --header="Accept: text/html" \
  --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:21.0) Gecko/20100101 Firefox/21.0" \
  --referer="https://omnetpp.org" \
  --output-document=omnetpp-4.6-src.tgz \
  https://omnetpp.org/component/jdownloads/send/32-release-older-versions/2290-omnet-4-6-source-ide-tgz

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
  make MODE=release -j 4

# Compilation of INET
RUN mv inet-3.0.0-src.tgz tools/ && \
  cd tools && \
  tar xof inet-3.0.0-src.tgz && \
  mv inet omnetpp-4.6/samples/ && \
  cd omnetpp-4.6/samples/inet && \
  make makefiles && \
  make MODE=release -j 4

# List of R packages to create a data-set of experimental results per dissemination protocol
COPY r-packages /usr/emrg-ovrl/r-packages
# Installation of R packages
RUN cd r-packages && \
  wget https://github.com/downloads/omnetpp/omnetpp-resultfiles/omnetpp_0.2-1.tar.gz && \
  R CMD BATCH r-worker-pkgs.R

ADD src/base /usr/emrg-ovrl/src/base
ADD src/scripts /usr/emrg-ovrl/src/scripts
ADD src/protocols /usr/emrg-ovrl/src/protocols

CMD cd /usr/emrg-ovrl/src/scripts && \
  ./compile_protocols.sh ../protocols ../../built && \
  ./pull_task.sh
