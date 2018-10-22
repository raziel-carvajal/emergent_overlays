FROM debian:9
MAINTAINER Raziel Carvajal-Gomez <raziel.carvajal@uclouvain.be>
LABEL Description="Docker image with OMNeT++ (v4.6), INET (v3.0.0) and R to simulate message dissemination in MANETs via the framework EmergentOverlays."

WORKDIR /usr/emrg-ovrl

ENV PATH=/usr/emrg-ovrl/omnetpp-4.6/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/emrg-ovrl/omnetpp-4.6/lib:${LD_LIBRARY_PATH}

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
  wget \
  curl

ADD services/worker/omnetpp-4.6-src.tgz .
# in case the docker-compose version is lower than 3.0
RUN if [ ! -d omnetpp-4.6 ] ; then tar xof omnetpp-4.6-src.tgz ; fi
# Compilation of OMNeT++
RUN cd omnetpp-4.6 && NO_TCL=1 ./configure && make -j 4

# Fetch INET source file
RUN wget \
  https://github.com/inet-framework/inet/releases/download/v3.3.0/inet-3.3.0-src.tgz
# Compilation of INET
ADD services/worker/sctphdr.h .
RUN tar xof inet-3.3.0-src.tgz && \
  mv inet omnetpp-4.6/samples/ && \
  mv sctphdr.h omnetpp-4.6/samples/inet/src/inet/common/serializer/sctp/headers/ && \
  cd omnetpp-4.6 && \
  cd samples/inet && \
  make makefiles && \
  make -j 4

ADD src/emergent_overlays src/emergent_overlays
ADD src/scripts/compile_protocols.sh src/scripts/
RUN workdir=`pwd` && cd src/scripts && \
  ./compile_protocols.sh ${workdir}/omnetpp-4.6 ${workdir}/src/emergent_overlays

ADD src/scripts/pull_task.sh src/scripts/
ADD src/scripts/run-one-configuration.sh src/scripts/

CMD cd src/scripts && ./pull_task.sh
