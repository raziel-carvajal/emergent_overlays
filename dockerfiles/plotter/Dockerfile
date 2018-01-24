FROM ubuntu:14.04.5
MAINTAINER Raziel Carvajal-Gomez <raziel.carvajal@uclouvain.be>
LABEL Description="Docker image with Omnet++ (4.6), INET and R"

RUN mkdir -p /usr/emrg-ovrl
WORKDIR /usr/emrg-ovrl

RUN apt-get update
# General dependencies
RUN apt-get -y install \
  bc \
  build-essential \
  gcc \
  g++ \
  git \
  wget \
  python \
  r-base \
  r-cran-digest

COPY r-packages /usr/emrg-ovrl/r-packages
RUN cd r-packages && \
  wget \
    https://cran.r-project.org/src/contrib/Archive/reshape2/reshape2_1.4.2.tar.gz \
    https://cran.r-project.org/src/contrib/Archive/plyr/plyr_1.8.1.tar.gz \
    https://cran.r-project.org/src/contrib/Archive/ggplot2/ggplot2_1.0.1.tar.gz && \
  R CMD BATCH r-plotter-pkgs.R

ADD src/scripts /usr/emrg-ovrl/src/scripts

CMD cd ./src/scripts && ./wait_for_workers.sh && ./run-selected-protocols-all-configs.sh -a abba
