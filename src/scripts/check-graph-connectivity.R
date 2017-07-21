require(omnetpp)
library(argparse)
library(igraph)

#
# Used to define the arguments of the script
#
parser <- ArgumentParser(description='Determines whether a graph, form with the vector of positions, is connected')

parser$add_argument('-n', '--network_file', type="character",
  help='Name of the network file (NED) of Omnet++')
parser$add_argument('-m', '--measured_time', type="double",
  help='Exact time where position of nodes were taken')
parser$add_argument('-t', '--transmission_range', type="integer",
  help='Tx of nodes')

load.datafile <- function(fname, query, extensions=c("sca", "vec")) {
  ds <- loadVectors(loadDataset(paste(fname, sep= ".", extensions), add(type="vector", select=query) ), NULL)
}

get.graph <- function(file, time, Tx) {
  df_x <- load.datafile(file, "name(node_position_x:vector)" )$vectordata
  df_y <- load.datafile(file, "name(node_position_y:vector)" )$vectordata
  
  allPositions <- data.frame(
    nodeId = df_x$resultkey + 1,
    time = df_x$x,
    x = df_x$y,
    y = df_y$y
  )
  
  nodes <- unique(allPositions$nodeId)
  nodesPositions <- allPositions[allPositions$time == time, ]

  tmp <- unlist(lapply(nodes, function(n){
    node <- nodesPositions[nodesPositions$nodeId == n, ]
    others <- nodesPositions[nodesPositions$nodeId != n, ]
    neigs <- unique(
      subset(others, sqrt(abs(node$x - x)*abs(node$x - x) + abs(node$y - y)*abs(node$y - y)) <= Tx)$nodeId
    )
    unlist(lapply(neigs, function(n){
        c(node$nodeId, n)
    }))
  }))
  
  graph( edges=tmp, n=length(nodes))
}

args <- parser$parse_args()
g <- get.graph(args$network_file, args$measured_time, args$transmission_range)
plot(g)

print(is.connected(g))
