FROM debian:9
MAINTAINER Raziel Carvajal-Gomez <raziel.carvajal@uclouvain.be>
LABEL Description="Creates mobility traces using a Python implementation of the Lavy walk model"

RUN mkdir -p /usr/emrg-ovrl
WORKDIR /usr/emrg-ovrl

# General dependencies
RUN apt-get update && \
  apt-get -y --no-install-recommends install \
  python \
  python-pip \
  python-matplotlib \
  python-setuptools \
  git \
  poppler-utils \
  bc

RUN git clone git://github.com/panisson/pymobility.git

RUN cd pymobility && \
  python setup.py install

ADD python_pkgs python_pkgs

RUN pip install -r python_pkgs

RUN echo "backend : Agg" > /etc/matplotlibrc && \
  rm -r /root/.cache

CMD cd src/scripts/topologies && ./make-topology.sh
