FROM ubuntu:14.04.5
MAINTAINER Raziel Carvajal-Gomez <raziel.carvajal@uclouvain.be>
LABEL Description="Python image to create mobility traces"

RUN mkdir -p /usr/emrg-ovrl
WORKDIR /usr/emrg-ovrl

RUN apt-get update
# General dependencies
RUN apt-get -y install python python-pip python-tk git

COPY python_pkgs /usr/emrg-ovrl/python_pkgs

RUN pip install -r python_pkgs && \
  git clone git://github.com/panisson/pymobility.git && \
  cd pymobility && \
  python setup.py install
