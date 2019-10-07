library(igraph)

get_neighbors <- function(nodeID, positions, tx) {
  node <- subset(positions, nodeId == nodeID)
  neighbors <- subset(positions, abs(node$x - x) < tx & abs(node$y - y) < tx)
	neighbors <- subset(neighbors, nodeId != node$nodeId)
	neighbors <- subset(neighbors, sqrt((node$x - x)^2 + (node$y - y)^2) < tx)
	neighbors$nodeId
}

createGraph <- function(nodesNo, neighbors) {
  edges <- sapply(names(neighbors), function(n) {
    sapply(neighbors[[ n ]], function(m) {
      c(n, m)
    })
  })
  g <- simplify(graph(edges = unlist(edges), directed = F))
	# uncomment to remove all edeges in graph
	# g <- delete_edges(g, E(g))

  E(g)$arrow.mode <- 0
  E(g)$color <- "lightgrey"
  V(g)$size <- 3
  V(g)$label <- ""
  # V(g)$label.cex <- 0.4
  V(g)$frame.color <- "black"

  g
}

plotWirelessTopology <- function(topNo, nodesNo, neighbors, nodesPositions,
  msgReceivers, forward_type_ds, runningAlgoAtTopology) {
  # create graph based on edges
  g <- createGraph(nodesNo, neighbors)

	# colour code for reachability
  #   0 -> SIMPLE
  #   1 -> CDS RELAY
  #   2 -> BORDER
	labelCode <- rep(NA, length(nodes))
	labelCode[msgReceivers] <- 'dimgray'
	labelCode[ subset(forward_type_ds, value == 0)$node_id ] <- 'cyan'
  labelCode[ subset(forward_type_ds, value == 1)$node_id ] <- 'gold'
  labelCode[ subset(forward_type_ds, value == 2)$node_id ] <- 'orangered'
	labelCode[labelCode == NA] <- 'white'

	colors <- c('cyan', 'gold', 'orangered', 'dimgray', 'white')

	# runningAlgoAtTopology <- runningAlgoAtTopology[order(runningAlgoAtTopology$node_id), ]
	# # colour code for running algorithm
	# # 0 -> simple flooding ; 1 -> MPR ; 2 -> controlled flooding
	# labelCode <- sapply(runningAlgoAtTopology$value, function(a){
	# 	ifelse(a == 0, 'dimgray', ifelse(a == 1, 'gold', 'cyan'))
	# })
	# colors <- c('dimgray', 'gold', 'cyan')

	V(g)$color <- labelCode

	# BEGIN attributes values to show experimental scenario
	# V(g)$color = 'white'
	# V(g)$size <- 1.3
	# END

	# colour nodes according to its position at communication area
	# lastAtSparse <- ceiling( (length(nodes) - 1) / 2 )
	# V(g)$color <- c(rep('white', lastAtSparse), rep('lightgrey', length(nodes) - lastAtSparse) )
  # colors <- c('white', 'lightgrey')
  # use node coordinates as layout

	layout <- cbind(nodesPositions$x, nodesPositions$y)

  # save one graph per broadcast session
  name <- paste("graph_", topNo, ".pdf", sep="")

	# pdf(name)
	# plot.igraph(g, layout=layout)

	# BEGIN attributes values to show experimental scenario
	pdf(name, width=10, height=5)
	plot(g, layout=layout*0.01, rescale=F, , xlim=c(0, 1), ylim=c(0, .45), margin=0.1)
	# END

	# legend(
  #   x=0.7, y=1.4, title='Running algorithm',
  #   c('Simple flooding ', 'MPR ', 'Controlled flooding'),
	# 	pch=21, col="#777777", pt.bg=colors, pt.cex=2, cex=.8, bty="n", ncol=1
  # )

	legend(
    x=0.7, y=1.4, title='Type of forward',
    c(
      paste('Simple [', length(labelCode[labelCode == 'cyan']), ']'),
      paste('CDS relay [', length(labelCode[labelCode == 'gold']), ']'),
      paste('Border [', length(labelCode[labelCode == 'orangered']), ']'),
      paste('Receiver [', length(labelCode[labelCode == 'dimgray']), ']'),
      paste('Unreachable [', length(labelCode[labelCode == 'white']), ']')
    ), pch=21, col="#777777", pt.bg=colors, pt.cex=2, cex=.8, bty="n", ncol=1
  )
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
