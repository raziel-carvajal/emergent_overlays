list.of.packages <- c("omnetpp")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) {
  install.packages("../../tools/omnetpp_0.7-1.tar.gz", repos = NULL, type="source")
  install.packages("ggplot2", repos='http://cran.us.r-project.org')
  install.packages("argparse", repos='http://cran.us.r-project.org')
}
print ("omnetpp for R is installed")
