FROM r-base:latest
MAINTAINER Raziel Carvajal-Gomez <raziel.carvajal@uclouvain.be>
LABEL Description="r-base image to plot datasets of emergent_overlays"

RUN mkdir -p /usr/emrg-ovrl
WORKDIR /usr/emrg-ovrl

COPY r-packages /usr/emrg-ovrl/r-packages

RUN cd r-packages && R CMD BATCH r-plotter-pkgs.R

ADD src/scripts /usr/emrg-ovrl/src/scripts

RUN apt-get update && \
  apt-get install -y python

CMD cd ./src/scripts && ./wait_for_workers.sh && ./run-selected-protocols-all-configs.sh -a abba
