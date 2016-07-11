list.of.packages <- c("omnetpp")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if (length(new.packages)) {
	print (noquote("fail"))
} else {
 	print (noquote("Ok"))
}
