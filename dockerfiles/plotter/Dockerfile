FROM r-base:latest
MAINTAINER Raziel Carvajal-Gomez <raziel.carvajal@uclouvain.be>
LABEL Description="r-base image to plot datasets of emergent_overlays"

RUN apt update && \
  apt -y --no-install-recommends install python

RUN mkdir -p /usr/emrg-ovrl/src/scripts
WORKDIR /usr/emrg-ovrl

ADD r-packages r-packages
RUN cd r-packages && R CMD BATCH r-plotter-pkgs.R

ADD src/scripts/*.sh ./src/scripts/
ADD src/scripts/*.R ./src/scripts/

CMD cd ./src/scripts && ./plot-all-broadcast-metrics.sh
