FROM ubuntu:latest
MAINTAINER Raziel Carvajal-Gomez <raziel.carvajal@uclouvain.be>
LABEL Description="Python image to create mobility traces"

RUN mkdir -p /usr/emrg-ovrl
WORKDIR /usr/emrg-ovrl

# General dependencies
RUN apt-get update && \
  apt-get -y install \
  python \
  python-pip \
  python-matplotlib \
  git \
  poppler-utils \
  bc

COPY python_pkgs /usr/emrg-ovrl/python_pkgs

RUN pip install -r python_pkgs

RUN git clone git://github.com/panisson/pymobility.git && \
  cd pymobility && \
  python setup.py install

RUN echo "backend : Agg" > /etc/matplotlibrc && \
  rm -r /root/.cache

CMD cd src/scripts/topologies && ./make-topology.sh
