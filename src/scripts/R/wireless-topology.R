library(igraph)

get_neighbors <- function(nodeID, positions, tx) {
  node <- subset(positions, nodeId == nodeID)
  others <- subset(positions, nodeId != nodeID)
  neighbors <- sapply(others$nodeId, function(i) {
    n <- subset(others, nodeId == i)
    ifelse(sqrt((node$x - n$x) * (node$x - n$x) + (node$y - n$y) * (node$y -
      n$y)) <= tx, n$nodeId, NA)
  })
  neighbors[!is.na(neighbors)]
}

get_wireless_topology <- function(positions, tx, plot = FALSE, graphName = "graph") {
  # we order to have the node identifier as index of every list that follows
  positions <- positions[order(positions$nodeId), ]
  # get edges of graph using transmission range of nodes store one-hop neighbors in
  # a list (to speed up process)
  oneHopNeigs <- lapply(c(1:length(positions$nodeId)), function(i) {
    get_neighbors(i, positions, tx)
  })
  edges <- sapply(c(1:length(positions$nodeId)), function(i) {
    sapply(oneHopNeigs[[i]], function(neig) {
      c(i, neig)
    })
  })
  g <- simplify(graph(edges = unlist(edges), directed = F))

  E(g)$arrow.mode <- 0
  E(g)$color <- "lightgrey"
  V(g)$size <- 5
  V(g)$label <- ""
  V(g)$label.cex <- 0.4
  V(g)$frame.color <- "black"
 
  g
}
