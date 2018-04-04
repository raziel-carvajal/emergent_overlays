require(omnetpp)
library(igraph)

TOLERANCE <- 1e-8
SENT_RECV_PKG_TOLERANCE <- 1.5e-03

load.datafile <- function(fname, query, extensions=c("sca", "vec")) {
  ds <- loadVectors(loadDataset(paste(fname, sep= ".", extensions), add(type="vector", select=query) ), NULL)
}

# This method replace the column [resultkey] of a dataset with a string
# obtained from the field [module], which refers to the node identifier
replace.resultkey.with.node_id <- function(dataset_file, query){
  dataset <- load.datafile(dataset_file, query)
  # getting node identifier from column [vectors$module]
  tmp <- toString(dataset$vectors$module)
  tmp <- strsplit(unlist(strsplit(tmp, "\\.")), "hostR")
  node_ids <- unlist(lapply(tmp, function(itm){ if(length(itm) == 2) {itm[2]} }))
  # map of node identifier per resultkey
  key_id_mapping <- data.frame(
    key = dataset$vectors$resultkey,
    node_id = as.numeric(node_ids)
  )

  # get column [resultkey]
  keys <- dataset$vectordata$resultkey
  # new values for column [resultkey]
  transf <- unlist(lapply(keys, function(k){
    key_id_mapping[key_id_mapping$key == k, ]$node_id
  }))
  # update column
  dataset$vectordata$resultkey <- transf
  # update headers of dataset
  data.frame(
    node_id = dataset$vectordata$resultkey,
    time = dataset$vectordata$x,
    value = dataset$vectordata$y
  )
}

highest.energy.consumption <- function(v){
  quasi_v <- tail(v, length(v) - 1)
  quasi_v <- c(quasi_v, tail(v,1)[1])
  max(v - quasi_v)
}

energy.consumption.of.sent_recv.messages <- function(results_file,
  exp_duration, sent_packages, recv_packages, nodes){

  energy_consumption <- subset(
    replace.resultkey.with.node_id(results_file, "name(residualCapacity:vector)"),
    time < exp_duration
  )

  e_consump_per_node <- sapply(nodes, function(n){
    n_e_consump <- sort.int( subset(energy_consumption, node_id == n)$value )
    n_e_consump[length(n_e_consump)] - n_e_consump[1]
  })

  e_consump_per_node
}


get.graph <- function(
  xPositions, yPositions, Tx, locationTimestamp,
  msgTimestamp, msgReceivers, msgEmitters, savePlot=F) {

  allPositions <- data.frame(
    nodeId = xPositions$node_id,
    time = xPositions$time,
    x = xPositions$value,
    y = yPositions[yPositions$node_id == xPositions$node_id, ]$value
  )

  nodes <- unique(allPositions$nodeId)

  nodesPositions <-
    allPositions[ abs(allPositions$time - locationTimestamp) < TOLERANCE, ]

  edges <- unlist(lapply(nodes, function(n){

    node <- nodesPositions[nodesPositions$nodeId == n, ]

    nodeNeigs <- subset(
      subset(
        nodesPositions,
        sqrt((node$x - x)*(node$x - x) + (node$y - y)*(node$y - y)) <= Tx
      ),
      node$nodeId != nodeId
    )$nodeId

    sapply(nodeNeigs, function(neig){
      c(node$nodeId, neig)
    })

  }))

  # create graph based on edges
  g <- graph( edges=edges )
  if(savePlot){
    V(g)$size <- 8
    V(g)$frame.color <- 'white'
    E(g)$arrow.mode <- 0
    # use node coordinates as layout
    layout <- cbind(nodesPositions$x, nodesPositions$y)
    # labeled nodes when they aren't rechable, act as pure receivers or as relays
    labelCode <- rep(1, length(nodes))
    labelCode[msgReceivers] <- 2
    labelCode[msgEmitters]  <- 3
    colors <- c('gray50', 'gold', 'tomato')
    V(g)$color <- colors[labelCode]
    # save one graph per broadcast session
    name <- paste("graph_", locationTimestamp, ".pdf", sep="")
    pdf(name)
    plot.igraph(g, layout=layout)
    legend(
      x=0.7, y=1.4, c("Unreachable","Pure-receiver", "Relay"), pch=21,
      col="#777777", pt.bg=colors, pt.cex=2, cex=.8, bty="n", ncol=1
    )
    dev.off()
  }
  # return graph
  g
}
