list.of.packages <- c("omnetpp", "argparse", "ggplot2", "reshape2", "grid", "gridExtra")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if (length(new.packages)) {
	print (noquote("fail"))
} else {
 	print (noquote("Ok"))
}
