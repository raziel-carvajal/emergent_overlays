FROM ubuntu:latest

# install dependencies
RUN apt-get update && \
    apt-get -y install apt-utils gcc g++ byacc bison flex make perl \
    perl-modules python && \
    rm -rf /var/lib/apt/lists/*

# copy sources
COPY ./experiments /broadcasting/experiments
COPY ./tools /broadcasting/tools
COPY ./src /broadcasting/src

WORKDIR /broadcasting

# install omnet++ and inet
RUN rm -f /broadcasting/src/scripts/omnet.config
RUN cd /broadcasting/src/scripts && bash sanity-check.sh
RUN cd /broadcasting/src/scripts && bash ./compile_protocols.sh "../protocols" "../../built"

# compile protocols
CMD ./run-selected-protocols-all-configs.sh -d 5 -D 15 -a flooding -a cds3 -a mprt2 -a abba2
