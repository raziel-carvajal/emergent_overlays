FROM ubuntu:latest

# copy sources
COPY ./experiments /broadcasting/experiments
COPY ./tools /broadcasting/tools
COPY ./src /broadcasting/src

WORKDIR /broadcasting/src/scripts

# install dependencies
RUN apt-get update && \
    apt-get -y install apt-utils gcc g++ byacc bison flex make perl \
    perl-modules python git r-base parallel sudo python-setuptools \
    python-numpy libxml2 libxml2-dev && \
    rm -rf /var/lib/apt/lists/*

# install omnet++ and inet
RUN rm -f omnet.config
RUN bash install-everything.sh

# compile protocols
