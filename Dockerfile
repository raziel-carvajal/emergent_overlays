FROM ubuntu:latest



# copy sources
COPY ./experiments /broadcasting/experiments
COPY ./tools /broadcasting/tools
COPY ./src /broadcasting/src

WORKDIR /broadcasting

# install dependencies
RUN apt-get update && \
    apt-get -y install apt-utils gcc g++ byacc bison flex make perl \
    perl-modules python && \
    rm -rf /var/lib/apt/lists/*

# install omnet++ and inet
RUN rm -f /broadcasting/src/scripts/omnet.config
RUN cd /broadcasting/src/scripts && bash install-everything.sh

# compile protocols
