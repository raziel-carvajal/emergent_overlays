library(igraph)

createGraph <- function(nodesNo, neighbors) {
  edges <- sapply(names(neighbors), function(n) {
    sapply(neighbors[[ n ]], function(m) {
      c(strtoi(n), m)
    })
  })

  g <- simplify(graph(edges = unlist(edges), directed = F))
  E(g)$width <- 0.1
  E(g)$color <- "lightgrey"
  V(g)$size <- 10
  # V(g)$label <- ""
  V(g)$label.cex <- 0.3

  g
}

plotWirelessTopology <- function(topNo, nodesNo, neighbors, nodesPositions,
  msgReceivers, forward_type_ds, runningAlgoAtTopology) {
  # create graph based on edges
  g <- createGraph(nodesNo, neighbors)

  labelCode <- rep('white', nodesNo)
	labelCode[msgReceivers] <- 'dimgray'
  # forward type codes: simple (0), overlay relay (1), border node (2)
  labelCode[ subset(forward_type_ds, value == 0)$node_id ] <- 'cyan'
  labelCode[ subset(forward_type_ds, value == 2)$node_id ] <- 'orangered'
  labelCode[ subset(forward_type_ds, value == 1)$node_id ] <- 'gold'
	V(g)$color <- labelCode

  nodesShape <- rep('circle', nodesNo)
  nodesShape[ subset(runningAlgoAtTopology, value == 1)$node_id ] <- 'square'
  V(g)$shape <- nodesShape

	# colour nodes according to its position at communication area
	# lastAtSparse <- ceiling( (length(nodes) - 1) / 2 )
	# V(g)$color <- c(rep('white', lastAtSparse), rep('lightgrey', length(nodes) - lastAtSparse) )
  # colors <- c('white', 'lightgrey')
  # use node coordinates as layout

  # NOTE this code shows a cluster of nodes based on a certain label
  # c <- cluster_label_prop(g, initial=c(rep(1*(-1), 20), rep(0, 41)) )
  # plot(c, g, layout = layout*0.1, rescale = F, xlim = c(0, 9.0), ylim = c(0, 4.5))
  # plot.igraph(g, add=T, layout = layout*0.1, rescale = F, xlim = c(0, 9.0), ylim = c(0, 4.5))

  # NOTE this code sets a pie as form of nodes
  # values <- lapply(1:61, function(x) c(5, 5))
  # vertex.shape=c(rep("pie", 30), rep("rectangle", 31)),
  # vertex.pie=values,
  # vertex.pie.color=list(heat.colors(5))

  pdf( paste("graph_", topNo, ".pdf", sep="") )
  layout <- cbind(nodesPositions$x, nodesPositions$y)
  plot.igraph(
    g, layout = layout*0.1, rescale = F, xlim = c(0, 9.0), ylim = c(0, 4.5),
  )
  rect(0, 0, 9, 4.5, lwd=1.5)
  dev.off()

  g
}
#
getVerticesFromBiggestCluster <- function(g){
  c <- components(g)
  d1 <- data.frame(indx=c(1:length(c$csize)), csize=c$csize)
  d2 <- data.frame(indx=c(1:length(c$membership)), membership=c$membership)
  clusterId <- subset(d1, csize == max(c$csize))$indx
	subset(d2, membership == clusterId)$indx
}
#
# this code is followed IN DATASET to label nodes that forward messages:
#   0 => SIMPLE
#   1 => CDS RELAY
#   2 => BORDER
#   3 => RECEIVER
#   4 => UNREACHABLE
get.node.roles <- function(overlays, msgs_ids, algorithmN) {
  fw_code_str<- c('Simple', 'CDS relay', 'Border', 'Receiver', 'Unreachable')
  node_roles <- lapply( msgs_ids,
    function(msg){
      overlay <- overlays[[msg]]
      connected_nodes <- getVerticesFromBiggestCluster(overlay)
      nodes_location <- sapply(
        1 : length( V(overlay)$location ),
        function(e){
          ifelse(e %in% connected_nodes, V(overlay)$location[e], NA)
        }
      )
      zones <- c('SPARSE', 'DENSE')
      nodes_per_location <- sapply(
        zones,
        function(z){
          nodes_at_z <- sapply(
            1 : length(nodes_location),
            function(i){ ifelse(nodes_location[i] == z, i, NA) }
          )
          nodes_at_z[ !is.na(nodes_at_z) ]
        }
      )
      nodes_fw_type <- V(overlay)$colorCode
      fw_codes <- unique(nodes_fw_type)
      lapply(
        nodes_per_location,
        function(nodes){
          fw_types <- nodes_fw_type[nodes]
          fw_codes_no <- lapply( fw_codes,
            function(code){
              data.frame(
                count=length(fw_types[fw_types == code]),
                fw_code=fw_code_str[code],
                stringsAsFactors=F
              )
            }
          )
          do.call('rbind', fw_codes_no)
        }
      )
    }
  )
  dsPerZone <- list(
    do.call( 'rbind', lapply(node_roles, function(df){ df$SPARSE }) ),
    do.call( 'rbind', lapply(node_roles, function(df){ df$DENSE }) )
  )
  zones <- c('SPARSE', 'DENSE')
  merged_ds <- lapply(
    1 : 2,
    function(i){
      ds <- dsPerZone[[i]]
      fw_codes <- unique(ds$fw_code)
      # we have now total number of nodes per FW code
      dsAsMatrix <- sapply(
        fw_codes,
        function(code){ sum(subset(ds, fw_code == code)$count) }
      )
      # we get a percentage over all nodes per broadcast session
      dsLen <- sum(ds$count)
      data.frame(
        count=as.vector( (dsAsMatrix * 100) / dsLen ),
        fw_code=names(dsAsMatrix),
        zone=rep(zones[[i]], length(dsAsMatrix)),
        algorithm=rep(algorithmN, length(dsAsMatrix)),
        stringsAsFactors=F
      )
    }
  )
  do.call('rbind', merged_ds)
}
