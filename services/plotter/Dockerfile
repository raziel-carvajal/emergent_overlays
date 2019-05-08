FROM r-base:latest
MAINTAINER Raziel Carvajal-Gomez <raziel.carvajal@uclouvain.be>

WORKDIR /usr/emrg-ovrl

RUN apt update && apt -y --no-install-recommends install r-base python curl

RUN mkdir -p src/scripts

COPY r-packages/r-plotter-pkgs.R .
RUN R CMD BATCH r-plotter-pkgs.R

COPY src/scripts/plot-all-broadcast-metrics.sh src/scripts/
COPY src/scripts/plot-broadcast-metrics.R src/scripts/

CMD cd src/scripts && ./plot-all-broadcast-metrics.sh
