library(argparse)
library(igraph)

get_args <- function() {
  p <- ArgumentParser(description = "get clustering coefficient and density of vertex in a graph")
  p$add_argument("dataset", type = "character")
  p$add_argument("--transmission-range", dest = "tx", type = "double", default = "1.0")
  p$parse_args()
}

get_triangles <- function(n, g, oneHopNeigs) {
  t <- sapply(oneHopNeigs, function(n_1) {
    twoHopNeigs <- setdiff(neighbors(g, n_1), n)
    sapply(twoHopNeigs, function(n_2) {
      ifelse(n_2 %in% oneHopNeigs, 1, 0)
    })
  })
  sum(unlist(t))
}

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

get_density_coefficients <- function(positions, tx, graphId) {
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
  
  # get denominator of local clustering coefficient
  clusCoefDenom <- lapply(c(1:length(positions$nodeId)), function(i) {
    length(oneHopNeigs[[i]]) * (length(oneHopNeigs[[i]]) - 1)
  })
  # get denominator of local closure coefficient
  closCoefDenom <- lapply(c(1:length(positions$nodeId)), function(i) {
    temp <- sapply(oneHopNeigs[[i]], function(n_1) {
      length(neighbors(g, n_1)) - 1
    })
    sum(unlist(temp))
  })
  # get numerator of both coefficients
  trianglesNo <- lapply(c(1:length(positions$nodeId)), function(i) {
    get_triangles(i, g, oneHopNeigs[[i]])
  })
  # get local clustering coefficient of each node; in case the denominator is zero
  # the clustering coefficient is undetermined, instead, we report zero
  clusteringCoef <- sapply(c(1:length(positions$nodeId)), function(i) {
    ifelse(clusCoefDenom[[i]] != 0, trianglesNo[[i]]/clusCoefDenom[[i]], 0)
  })
  # get local closure coefficient of each node; in case the denominator is zero the
  # closure coefficient is undetermined, instead, we report zero
  closureCoef <- sapply(c(1:length(positions$nodeId)), function(i) {
    ifelse(closCoefDenom[[i]] != 0, trianglesNo[[i]]/closCoefDenom[[i]], 0)
  })
  # 
  E(g)$arrow.mode <- 0
  E(g)$color <- "lightgrey"
  V(g)$size <- 5
  V(g)$label <- ""
  V(g)$label.cex <- 0.4
  V(g)$frame.color <- "black"
  # get colour code for clustering/closure coefficient
  cloCoefColours <- sapply(c(1:length(positions$nodeId)), function(i) {
    ifelse(closureCoef[i] <= 1/3, "yellow", ifelse(closureCoef[i] <= 2/3, "orange", 
      "red"))
  })
  cluCoefColours <- sapply(c(1:length(positions$nodeId)), function(i) {
    ifelse(clusteringCoef[i] <= 1/3, "yellow", ifelse(clusteringCoef[i] <= 2/3, 
      "orange", "red"))
  })
  # use node coordinates as layout
  layout <- cbind(positions$x, positions$y)
  pdf(paste("graphAtWalk_", graphId, "_cloCoef.pdf", sep = ""))
  V(g)$color <- cloCoefColours
  plot.igraph(g, layout = layout)
  
  pdf(paste("graphAtWalk_", graphId, "_cluCoef.pdf", sep = ""))
  V(g)$color <- cluCoefColours
  plot.igraph(g, layout = layout)
  
  # get number of neighbors per node
  density <- sapply(positions$nodeId, function(i) {
    length(oneHopNeigs[[i]])
  })
  data.frame(clu_c = clusteringCoef, clo_c = closureCoef, density = density)
}

#### main ####
args <- get_args()
positions <- read.table(args$dataset, header = T)
timestamps <- unique(positions$time)
timestampsIndx <- c(1:length(timestamps))

densityCoefs <- lapply(timestampsIndx, function(i) {
  # return a data frame with 2 distributions of a wireless topology: local
  # clustering coeffient and density per node
  get_density_coefficients(subset(positions, time == timestamps[i]), args$tx, i)
})
densityCoefs <- do.call("rbind", densityCoefs)

expeId <- paste(length(unique(positions$nodeId)), "_nodes", sep = "")
expeIdColumn <- rep(expeId, length(densityCoefs$density))

dd <- densityCoefs
densityCoefs <- data.frame(clustering_coef = dd$clu_c, closure_coef = dd$clo_c, density = dd$density, 
  expe_id = expeIdColumn)
# save dataset
write.table(densityCoefs, file = paste(expeId, "_cluCoef_density.dataset", sep = ""), 
  row.names = F, col.names = F)
