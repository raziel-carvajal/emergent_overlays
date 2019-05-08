FROM r-base
MAINTAINER Raziel Carvajal-Gomez <raziel.carvajal@uclouvain.be>

WORKDIR /usr/emrg-ovrl

#RUN apt-get update && apt-get -y --no-install-recommends install r-base curl wget python
# setting up omnetpp library
#RUN \
#  wget https://github.com/downloads/omnetpp/omnetpp-resultfiles/omnetpp_0.2-1.tar.gz
COPY r-packages/bigdecimal.cc .
COPY services/dist_generator/omnetpp_0.2-1.tar.gz .
RUN tar xof omnetpp_0.2-1.tar.gz && \
  rm -f omnetpp_0.2-1.tar.gz && \
  mv bigdecimal.cc omnetpp/src/common && \
  tar czf omnetpp_0.2-1.tar.gz omnetpp && \
  rm -fr omnetpp

# installing required libraries
COPY r-packages/r-worker-pkgs.R .
RUN R CMD BATCH r-worker-pkgs.R

# cURL compilation
RUN mkdir curl
COPY services/dist_generator/curl-7.64.1.tar.gz .
RUN tar xof curl-7.64.1.tar.gz && cd curl-7.64.1 && \
  ./configure --prefix=/usr/emrg-ovrl/curl && make && make install
# python compilation
RUN mkdir python
COPY services/dist_generator/Python-2.7.16.tgz .
RUN tar xof Python-2.7.16.tgz && cd Python-2.7.16 && \
  ./configure --prefix=/usr/emrg-ovrl/python && make && make install

RUN mkdir -p src/scripts
COPY src/scripts/get-broadcast-metrics.sh ./src/scripts/
COPY src/scripts/get-broadcast-metrics.R ./src/scripts/
ADD src/scripts/R ./src/scripts/R

CMD cd src/scripts ; PATH=${PATH}:/usr/emrg-ovrl/curl/bin:/usr/emrg-ovrl/python/bin ./get-broadcast-metrics.sh
