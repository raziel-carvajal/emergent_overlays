FROM debian:9
MAINTAINER Raziel Carvajal-Gomez <raziel.carvajal@uclouvain.be>
LABEL Description="Creates mobility traces using a Python implementation of the Lavy walk model"

RUN mkdir -p /usr/emrg-ovrl
WORKDIR /usr/emrg-ovrl

# General dependencies
RUN apt update && \
  apt -y --no-install-recommends install \
  python \
  python-pip \
  python-matplotlib \
  python-setuptools \
  git \
  poppler-utils \
  bc \
  gawk \
  curl

RUN git clone git://github.com/panisson/pymobility.git

RUN cd pymobility && \
  python setup.py install

ADD python_pkgs python_pkgs

RUN pip install -r python_pkgs

RUN echo "backend : Agg" > /etc/matplotlibrc && \
  rm -r /root/.cache

# install nodejs
RUN apt -y install gnupg
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
  apt -y install nodejs
# install deamon to dispatch INI files
ADD ini-f-d ini-f-d
RUN cd ini-f-d && npm install

CMD workdir=`pwd` && cd src/scripts/topologies && \
  ./make-topology.sh && \
  cd ${workdir}/ini-f-d && \
  INI_FILES_LIST=/usr/emrg-ovrl/experiments/configs/built_configs/cfgs_for_workers \
    npm start
