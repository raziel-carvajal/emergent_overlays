library(argparse)
source("wireless-topology.R")
source("omnet-datasets.R")

get_args <- function() {
  p <- ArgumentParser(description = "Draw wireless topologies from an Omnet++ dataset. Such dataset is the output of running an experiment with the class emergent_overlays/src/utils/Densitycoefss.h ; the output of this  set of PDF files.")
  p$add_argument("omnet_dataset", type = "character")
  p$add_argument("--transmission-range", dest = "tx", type = "double", default = "1.0")
  p$add_argument("--with-closure-coefficient", dest = "wclo", action = "store_true")
  p$add_argument("--with-clustering-coefficient", dest = "wclu", action = "store_true")
	p$add_argument("--with-plotting", dest = "plot", action = "store_true")
  p$parse_args()
}

### MAIN ###
args <- get_args()
if (!args$wclo & !args$wclu) {
  print("Any coefs was chosen. Run again with the option --with-closure-coefs OR --with-clustering-coefs")
  stop()
}

posAtX <- get_omnet_vector_as_dataset(args$omnet_dataset, "positionAtX:vector")
posAtY <- get_omnet_vector_as_dataset(args$omnet_dataset, "positionAtY:vector")

# NOTE both positions are recorded within the same event
positions <- data.frame(
	nodeId = posAtX$nodeId,
	time = posAtX$time,
	x = posAtX$data,
  y = posAtY[posAtY$nodeId == posAtX$nodeId, ]$data )
positions <- positions[order(positions$time), ]

# chose only one coefficient to draw
if(args$wclo){
	coefs <- get_omnet_vector_as_dataset(args$omnet_dataset, "closureCoef:vector")
	graphPrefix <- "ClosureCoef_"
} else {
	coefs <- get_omnet_vector_as_dataset(args$omnet_dataset, "clusteringCoef:vector")
	graphPrefix <- "ClusteringCoef_"
}
coefs <- coefs[order(coefs$time), ]

nodesNo <- length(unique(coefs$nodeId))
overlaysNo <- floor(length(coefs$nodeId)/nodesNo)
# get the wireless topology based on nodes positions
sapply(c(1:overlaysNo), function(i) {
	# datasets per overlay
	posAt_i <- tail(head(positions, i * nodesNo), nodesNo)
	coefAt_i <- tail(head(coefs, i * nodesNo), nodesNo)
	g <- get_wireless_topology(posAt_i, args$tx, plot = T)
  if (args$plot) {
		# in this way, the index of this vector refers to the node identifier
		coefAt_i <- coefAt_i[order(coefAt_i$nodeId), ]$data
		# in the resulting graph nodes have a colour based on their local closure/clustering coefficients:
		# yellow -> coefficient at [0, 1/3]
		# orange -> coefficient at (1/3, 2/3]
		# red 	 ->	coefficient at (2/3, 1]
		color <- sapply( c(1:length(coefAt_i)), function(j) {
			ifelse(coefAt_i[j] <= 1/3, 'yellow', ifelse(coefAt_i[j] <= 2/3, 'orange', 'red'))
		})
		V(g)$color <- color
    layout <- cbind(posAt_i$x, posAt_i$y)
    pdf(paste(graphPrefix, i, ".pdf", sep = ""))
    plot.igraph(g, layout = layout)
  }
})
