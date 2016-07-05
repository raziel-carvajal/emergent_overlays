list.of.packages <- c("omnetpp")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) {
  install.packages("../../tools/omnetpp_0.7-1.tar.gz", repos = NULL, type="source")
}
print ("omnetpp for R is installed")
