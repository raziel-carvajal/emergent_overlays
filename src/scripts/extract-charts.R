require(omnetpp)
library(argparse)
library(igraph)

TOLERANCE <- 1e-8
SENT_RECV_PKG_TOLERANCE <- 1.5e-03

get.arguments <- function() {
  parser <- ArgumentParser(description='Process omnetpp result files to extract the measurements of our experiment')
  parser$add_argument('file', metavar='file', type="character",
                      help='Full path to the result file (without extension)')
  parser$add_argument('outputPath', metavar='outputPath', type="character",
                      help='Full path to a directory where the output wiil be saved')
  parser$add_argument('simTime', metavar='simTime', type="integer",
                      help='Simulation time in seconds')
  parser$add_argument('configuration', metavar='configuration', type="character",
                      help='Name of the configuration')
  parser$add_argument('step', metavar='step', type="double",
                      help='Every broadcasting metric as function of time will use this value as xtics to be plotted')
  parser$add_argument('-a','--algorithm', dest='algorithm', type="character",
                      help='Algorithm used')
  parser$add_argument('-density-treshold', '--density-treshold', metavar='density_tr',
  	type="integer", help='Maximum value of density within a sparse region')
  parser$add_argument('-ds', '--density-as-string', metavar='density_string', type="character",
                      help='Density of the topology used as string')
  parser$add_argument('--radio-mode', dest='computeRadioMode', action="store_true",
                      help='Computing the time spent in each radio mode (a debug only option)')
  parser$add_argument('--splitted', dest='splitted', action="store_true",
                      help='If used, the script generates data per protocol when there are mnay used in a single scenario')

  parser$add_argument('--show-averages', dest='showAverages', action="store_true",
    help='Show the average of all the metrics')

  parser$add_argument('-b', '--broadcast_msgs', type="integer",
    help='Number of broadcast messages')
  parser$add_argument('-t', '--transmission_range', type="integer",
    help='Tx of nodes')
  parser$add_argument('-f_t', '--first_time_of_measuring_nodes_position', type='double',
    help='First point in time when nodes print out their position')
  parser$add_argument('-f_b', '--time_of_first_broadcast_message', type='double',
    help='Time when the first broadcast message was emitted')
  # parser$print_help()
  parser$parse_args()
}

build.filename <- function(path, filename, id, seP="-") {
  filename <- paste(path, filename, sep="/")
  paste(filename, id, sep=seP)
}

load.datafile <- function(fname, query, extensions=c("sca", "vec")) {
  ds <- loadVectors(loadDataset(paste(fname, sep= ".", extensions), add(type="vector", select=query) ), NULL)
}

broadcastingTime <- function(msgDs, broDs, simulation.time) {

  # create a separate list for each msg_sent vector
  list_of_sent <- lapply(msgDs$vectors$resultkey, function(p) subset(msgDs$vectordata, resultkey == p))
  # print(list_of_sent)


  # recover list of msg id
  id_msgs <- msgDs$vectordata[[4]][!duplicated(msgDs$vectordata[[4]])]

  # create a separate list for each broadcast_msg_received vector
  list_of_received <- lapply(broDs$vectors$resultkey, function(p) subset(broDs$vectordata, resultkey == p))

  sending.time <- sapply(id_msgs, function(id) min( unlist(lapply(list_of_sent, function(d)  subset(d, y == id, select=c(x))[[1]] )) ) )

  l.recp <- lapply(id_msgs, function (id) {
						tmp.list <- lapply(list_of_received, function(d)  d[d$y == id,]$x )
            # print(tmp.list)
						l <- sapply(tmp.list, function(d)  c(d, NA)[[1]] )
            # print(l)
            # print(max(l, na.rm = TRUE))
						data.frame(
							reception.time = max(l, na.rm = TRUE),
							rcv = sum(sapply(l, function(i) if (is.na(i)) 0 else 1)),
							B.i.tmp = sum(sapply(tmp.list, function(d) length(d) ))
						)
			}
  )

  l.recp <- do.call("rbind", l.recp)

  broadcasting.time <- data.frame(
  		id = id_msgs, # session id
  		sending = sending.time,
  		receiving = l.recp$reception.time,
  		time = l.recp$reception.time - sending.time, # broadcasting time per session id
  		n.received = l.recp$rcv, # how many locations received a message in a particular session
  		n.sent = sapply(id_msgs, function(id) { sum( sapply(list_of_sent, function(d) id %in% d$y ) ) } ), # how many locations sent a message in a particular session
  		B.i = l.recp$B.i.tmp # total number of messages received per broadcast session
  )
}

######## [BEGIN] TODO refactor save.* functions. All this functions can be factorized
save.delay.time <- function(broadcast.info, max, outputPath, expeId){
  valid.time <- broadcast.info$time[broadcast.info$time <= max ]
  valid.time <- valid.time[!is.na(valid.time)]
  if (length(valid.time) == 0) { valid.time <- broadcast.info$time }
  broSes <- valid.time * 1000
  broSes <- data.frame( whatever = broSes)
  colnames(broSes) <- c(expeId)
  write.table(
            broSes,
            file = build.filename(outputPath, "broadcastSession", expeId),
            row.names = F, append = F
  )
}

save.coverage <- function(broadcast.info, max, outputPath, expeId,
	expectedCoverage){

  cov <- (broadcast.info$n.received / expectedCoverage) * 100
  broSes <- data.frame( whatever = cov )
  colnames(broSes) <- c(expeId)
  write.table(
            broSes,
            file = build.filename(outputPath, "coverage", expeId),
            row.names = F, append = F
  )
}

save.number.of.relays <- function(broadcast.info, max, outputPath, expeId){
  broSes <- data.frame( whatever = broadcast.info$n.sent)
  colnames(broSes) <- c(expeId)
  write.table(
            broSes,
            file = build.filename(outputPath, "relays", expeId),
            row.names = F, append = F
  )
}

save.distribution <-function(dist_name, data, outputPath, expeId){
  values <- data.frame(value=data)
  colnames(values) <- c(expeId)

  write.table(
            values,
            file = build.filename(outputPath, dist_name, expeId),
            row.names = F, append = F
  )
}
######## [END] TODO refactor save.* functions. All this functions can be factorized

average.values <- function(pl, broadcast.info, max) {

	nr.nodes <- length(pl)
	n <- length(broadcast.info$id) # number of broadcast messages

	c  <- sum(broadcast.info$n.received/nr.nodes*100)/n

	valid.time <- broadcast.info$time[broadcast.info$time <= max ]
	bt <- sum(valid.time, na.rm=TRUE)/length(valid.time)

	pc <- sum(pl)/nr.nodes

	dm <- sum(broadcast.info$B.i / broadcast.info$n.received)/n

	rt <- mean(broadcast.info$n.sent)

	data.frame(
		coverage = mean(c),
		broadcasting.time = mean(bt),
		power_consumption = tail(pc,1),
		duplicated_messages = mean(dm),
		retransmitted_messages = mean(rt)
	)
}

get.density.distribution <- function(overlays){

  density_ground_truth <- lapply(overlays, function(overlay){
    vertices <- getVerticesFromBiggestCluster(overlay)
    lapply(vertices, function(v){
      node_neigs <- overlay[v, ]
      length(node_neigs[node_neigs != 0])
    })
  })

  unlist(density_ground_truth)
}

get.measured.density <- function(results_file, first_measure,
  msg_freq, msgs_ids, node_ids){

  measured_density <- replace.resultkey.with.node_id(
    results_file, "name(density_approximation:vector)"
  )
  # NOTE in case you want to compute the relative error doit here with /!\
  density_approx <- lapply(msgs_ids, function(msg){
    timestamp <- first_measure + msg_freq * (msg - 1)
    desityAtTi<-subset( measured_density, abs(time - timestamp) < TOLERANCE )
    lapply(
      node_ids,
      function(nodeId){
        subset(desityAtTi, node_id == nodeId)$value
      }
    )
  })

  unlist(density_approx)
  # NOTE /!\ compute relative error for vectors
#  absolute_err <- abs(density_approx - density_ground_truth)
#  #relative error with vectors
#  relative_err <- sapply(1:nrow(absolute_err), function(r){
#    max(absolute_err[r, ]) / max( density_ground_truth[r, ] )
#  })
#  print(relative_err)
#  relative_err
}

get.graph <- function(nodes, positions, Tx, locationTimestamp,
  msgTimestamp, msgReceivers, msgEmitters, savePlot=F) {

  nodesPositions <-
    positions[ abs(positions$time - locationTimestamp) < TOLERANCE, ]

  edges <- unlist(
    lapply(
      nodes,
      function(n){
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
      }
    )
  )

  # create graph based on edges
  g <- graph( edges=edges )
  if(savePlot){
    V(g)$size <- 8
    V(g)$label <- ''
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
      x=0.7, y=1.4,
      c(
        paste('Unreachable [', length(labelCode[labelCode == 1]), ']'),
        paste(
          'Pure-receiver [',
          length(nodes) - length(labelCode[labelCode == 1]) - length(labelCode[labelCode == 3]),
          ']'
        ),
        paste('Relay [', length(labelCode[labelCode == 3]), ']')
      ),pch=21, col="#777777", pt.bg=colors, pt.cex=2, cex=.8, bty="n", ncol=1
    )
    dev.off()
  }
  # return graph
  g
}
# TODO figure out if this chunk of code is still required
#      in the new implementation of get.graph (function above)
# get.graph <- function(...) {
#   # gets the biggest connected cluster
#   # XXX we assume that the source node belongs to this cluster
#   #			the biggest cluster
#   biggestCluster <- getVerticesFromBiggestCluster(g)
#
#   d0 <- data.frame(indx=1:length(tmp), v=tmp)
#   matr <- data.frame(
#   	A=subset(d0, indx %% 2 == 1)$v,
#   	B=subset(d0, indx %% 2 == 0)$v
#   )
# 	edgesAtCluster <- unlist(sapply(biggestCluster, function(i){
# 		dsts <- subset(matr, A == i)$B
# 		sapply(dsts, function(j){
# 			c(i, j)
# 		})
# 	}))
# 	graph(edges=edgesAtCluster, directed=F)
# }

getVerticesFromBiggestCluster <- function(g){
  c <- clusters(g)
  d1 <- data.frame(indx=c(1:length(c$csize)), csize=c$csize)
  d2 <- data.frame(indx=c(1:length(c$membership)), membership=c$membership)
  clusterId <- subset(d1, csize == max(c$csize))$indx
	subset(d2, membership == clusterId)$indx
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

energy.consumption.of.sent_recv.messages <- function(results_file,
  exp_duration, sent_packages, recv_packages, nodes){

  energy_consumption <- subset(
    replace.resultkey.with.node_id(results_file, "name(residualCapacity:vector)"),
    time < exp_duration
  )

  e_consump_per_node <- sapply(nodes, function(n){

    n_e_consump <- subset(energy_consumption, node_id == n)

    n_recv_msgs <- subset(recv_packages, node_id == n)

    key_timestamps <- unlist(
      sapply(n_recv_msgs$time, function(t){
        subset(n_e_consump, time == t)$time
      })
    )

    e_consump_recv_msgs <- sapply(key_timestamps, function(t_i){
      consump_before_t <- abs(
        subset(
          subset(n_e_consump, t_i - time >= 0),
          abs(t_i - time) < SENT_RECV_PKG_TOLERANCE
        )
      )
      ifelse(
        length(consump_before_t$node_id) >= 2,
        abs(tail(consump_before_t$value, 1) - tail(consump_before_t$value, 2)[1]),
        0
      )
    })

    key_timestamps <- subset(sent_packages, node_id == n)$time

    e_consump_sent_msgs <- sapply(key_timestamps, function(t_i){

      t_i_consump_vec <- sort(
        abs(
          subset(
            n_e_consump,
            abs(t_i - time) < SENT_RECV_PKG_TOLERANCE
          )$value
        )
      , decreasing = T)

      ifelse(
        length(t_i_consump_vec) >= 2,
        highest.energy.consumption(t_i_consump_vec),
        0
      )

    })

    # this vector is multiplied by 1K to have milli Joules
    sum( unlist(e_consump_sent_msgs), unlist(e_consump_recv_msgs) ) * 1000
  })

  e_consump_per_node
}

highest.energy.consumption <- function(v){
  quasi_v <- tail(v, length(v) - 1)
  quasi_v <- c(quasi_v, tail(v,1)[1])
  max(v - quasi_v)
}

get.node.roles <- function(overlays, msgs_ids) {
  node_roles <- sapply(msgs_ids,
    function(msg){
      overlay <- overlays[[msg]]
      roles_by_color <- V(overlay)$color
      relays <- sapply(1:length(roles_by_color),
        function(i){ ifelse(roles_by_color[i] == 'tomato', i, NA) }
      )
      relays <- relays[ !is.na(relays) ]
      receivers <- sapply(1:length(roles_by_color),
        function(i){ ifelse(roles_by_color[i] == 'gold', i, NA) }
      )
      receivers <- receivers[ !is.na(receivers) ]
      non_reachable <- sapply(1:length(roles_by_color),
        function(i){ ifelse(roles_by_color[i] == 'gray50', i, NA) }
      )
      non_reachable <- non_reachable[ !is.na(non_reachable) ]
      data.frame(
        relays=length(relays),
        receivers=length(receivers),
        non_reachable=length(non_reachable)
      )
    }
  )

  relays_perc <- sum( unlist( node_roles['relays', ] ) )
  receiv_perc <- sum( unlist( node_roles['receivers', ] ) )
  n_reac_perc <- sum( unlist( node_roles['non_reachable', ] ) )

  nodes_no <- node_roles[, 1]$relays + node_roles[, 1]$receivers +
    node_roles[, 1]$non_reachable
  ds_length <- nodes_no * length(node_roles['relays', ])

  data.frame(
    relays=       ceiling((relays_perc * 100) / ds_length),
    receivers=    ceiling((receiv_perc * 100) / ds_length),
    non_reachable=ceiling((n_reac_perc * 100) / ds_length)
  )
}

collisions.relative.error <- function(sent_msgs, recv_msgs, msgs_ids, overlays,
  nodes){
  groundTruth <- lapply(msgs_ids,
    function(msg){
      overlay <- overlays[[msg]]
      senders <- sort.int(unique( subset(sent_msgs, value == msg)$node_id ))
      receptions <- lapply(senders,
        function(s){
          counter <- rep(0, length(nodes))
          edges <- overlay[s, ]
          neigs <- sapply(1:length(edges),
            function(indx){
              ifelse(edges[indx] == 1, indx, NA)
            }
          )
          neigs <- neigs[ !is.na(neigs) ]
          counter[neigs] <- 1
          # NOTE when a sender S forwards a message, S is labed as a receiver too
          counter[s] <- 1
          counter
        }
      )
      receptions <- matrix(
        unlist(receptions), nrow=length(senders), ncol=length(nodes), byrow=T
      )
      t<-colSums(receptions)
    }
  )
  groundTruth <- rowSums(
    matrix(
      unlist(groundTruth), nrow=length(nodes), ncol=length(msgs_ids)
    )
  )
  measuredRcvMsgs <- lapply(nodes,
    function(node){
      recvMsgIds <- subset(recv_msgs, node_id == node)$value
      sapply(msgs_ids,
        function(msg){
          length(recvMsgIds[recvMsgIds == msg])
        }
      )
    }
  )
  measuredRcvMsgs <- rowSums(
    matrix(
      unlist(measuredRcvMsgs), nrow=length(nodes), ncol=length(msgs_ids), byrow=T
    )
  )
  relative_err <- sapply(nodes,
    function(n){
      abs(1 - measuredRcvMsgs[n] / groundTruth[n])
    }
  )
  relative_err[!is.na(relative_err)]
}

count.events.per.node <- function(nodes, ds){
  sapply(nodes, function(n_i){
    length( subset(ds, node_id == n_i)$node_id )
  })
}

count.events_compl.per.node <- function(nodes, A, B){
  sapply(nodes, function(n_i){
    abs(
      length(subset(A, node_id == n_i)$node_id) -
      length(subset(B, node_id == n_i)$node_id)
    )
  })
}

distribution.sent_recv.broadcast_control.messages <- function(sent_bro_msgs,
  recv_bro_msgs, sent_pkgs, recv_pkgs, nodes){
  result <- list()
  result[["sent_bro_msgs"]] <- count.events.per.node(nodes, sent_bro_msgs)
  result[["recv_bro_msgs"]] <- count.events.per.node(nodes, recv_bro_msgs)
  result[["sent_ctrl_msgs"]] <- count.events_compl.per.node(
    nodes, sent_pkgs, sent_bro_msgs
  )
  result[["recv_ctrl_msgs"]] <- count.events_compl.per.node(
    nodes, recv_pkgs, recv_bro_msgs
  )
  result
}

getExpectedCoverage <- function(overlays){
  sapply(overlays, function(overlay) {
    length( getVerticesFromBiggestCluster(overlay) )
  })
}

main <- function(args) {
  print(paste("Simulation time", args$simTime, "seconds"))
  exp_duration <-
	  args$time_of_first_broadcast_message + args$broadcast_msgs * args$step

  xPositions <- replace.resultkey.with.node_id(
    args$file, "name(node_position_x:vector)"
  )
  yPositions <- replace.resultkey.with.node_id(
    args$file, "name(node_position_y:vector)"
  )
  # merge nodes positions in one dataframe
  positions <- data.frame(
    nodeId = xPositions$node_id,
    time = xPositions$time,
    x = xPositions$value,
    y = yPositions[yPositions$node_id == xPositions$node_id, ]$value
  )

  all_nodes <- unique(
		replace.resultkey.with.node_id(
      args$file, "name(density_approximation:vector)"
    )$node_id
	)

  sent_broadcast_msgs <- replace.resultkey.with.node_id(
  	args$file, "name(msg_sent:vector)")
  recv_broadcast_msgs <- replace.resultkey.with.node_id(
  	args$file, "name(broadcast_msg_received:vector)")

  msgs_ids <- sort.int(unique(sent_broadcast_msgs$value))
  # store in a list one graph per broadcast session
  overlays <- lapply(msgs_ids, function(msg) {
    # point in time where node
    locationTimestamp <-
      args$first_time_of_measuring_nodes_position + args$step * (msg - 1)
    msgTimestamp <-
      args$time_of_first_broadcast_message + args$step * (msg - 1)
    msgEmitters <- unique( subset(sent_broadcast_msgs, value == msg)$node_id )
    msgReceivers <-unique( subset(recv_broadcast_msgs, value == msg)$node_id )
    # create the graph with the position of each node
    get.graph(
      all_nodes,
      positions,
      args$transmission_range,
      locationTimestamp,
      msgTimestamp,
      msgReceivers,
      msgEmitters, savePlot=TRUE
    )
  })

  # INFO: save proportion of nodes that act as relays, pure receivers or
  #       those nodes that do not receive broadcast messages
  write.table(
    get.node.roles(overlays, msgs_ids),
    file = build.filename(args$outputPath, "noderoles", args$configuration),
    row.names=F, append=F
  )

  sent_packages <- subset(
      replace.resultkey.with.node_id(args$file, "name(sentPk:vector*)"),
      time < exp_duration)
  recv_packages <- subset(
      replace.resultkey.with.node_id(args$file, "name(rcvdPk:vector*)"),
      time < exp_duration)
  # expected number of nodes that must receive a broadcast message
  # over all sessions of dissemination
	expectedCoverage <- getExpectedCoverage(overlays)

	datasetExists <- list.files(args$outputPath)
	if(! "groundTruthDensityDist-" %in% datasetExists) {
		print("Save ground truth of density")
		groundTruthD <- get.density.distribution(overlays)
		save.distribution(
      "groundTruthDensityDist", groundTruthD, args$outputPath, ""
  	)
    ##### BEGIN: naming dataset #####
		strV <- unlist(strsplit(args$configuration, "_"))
		strV <- strV[ 1:length(strV)-1 ]
		undV <- rep("_", length(strV))
		resu <- sapply(
      1:length(strV),
      function(i){
			     paste(strV[i], undV[i], sep="")
		  }
    )
		resu <- c(resu, "Ground-Truth")
		newName <- paste(resu, collapse="")
		save.distribution(
		  "groundTruthDensityDist", groundTruthD, args$outputPath, newName
  	)
    ##### END: naming dataset #####
  	print("DONE!")
  }

  print("Calculating distribution of sent and received broadcast/control messages")
  sent_recv_msgs <- distribution.sent_recv.broadcast_control.messages(
    sent_broadcast_msgs, recv_broadcast_msgs,
    sent_packages, recv_packages, all_nodes
  )
  print("DONE!")

  print("Calculating energy consumption")
  energy_consumption <- energy.consumption.of.sent_recv.messages(
    args$file, exp_duration,
    sent_packages, recv_packages, all_nodes
  )
  print("DONE!")

  print("Calculating approximation of nodes' density")
  density.relative.errors <- get.measured.density(
    args$file,
    args$first_time_of_measuring_nodes_position,
    args$step,
    msgs_ids,
    all_nodes
  )
  print("DONE!")

  print("Calculating relative error of collisions")
  collisions_re <- collisions.relative.error(
    sent_broadcast_msgs,
    recv_broadcast_msgs,
    msgs_ids,
    overlays,
    all_nodes
  )
  print("DONE!")

  print('Get distribution of broadcast session time')
  sent_msgs <- load.datafile(args$file, "name(msg_sent:vector)" )
  recv_msgs <- load.datafile(args$file, "name(broadcast_msg_received:vector)" )
  bs <- broadcastingTime(sent_msgs, recv_msgs, simulation.time = args$simTime)
  print("DONE!")

  print("Exporting data")
  save.distribution(
    "sentBroadcastMsgsDistribution", sent_recv_msgs$sent_bro_msgs,
    args$outputPath, args$configuration
  )
  save.distribution(
    "recvBroadcastMsgsDistribution", sent_recv_msgs$recv_bro_msgs,
    args$outputPath, args$configuration
  )
  save.distribution(
    "sentCtrlMsgsDistribution", sent_recv_msgs$sent_ctrl_msgs,
    args$outputPath, args$configuration
  )
  save.distribution(
    "recvCtrlMsgsDistribution", sent_recv_msgs$recv_ctrl_msgs,
    args$outputPath, args$configuration
  )
  save.distribution(
    "batteryConsumptionDistribution", energy_consumption,
    args$outputPath, args$configuration
  )
  save.distribution(
    "densityRelativeError", density.relative.errors,
    args$outputPath, args$configuration
  )
  save.distribution(
    "collisionsRelativeError", collisions_re,
    args$outputPath, args$configuration
  )

  save.delay.time(bs, args$simTime, args$outputPath, args$configuration)
  save.number.of.relays(bs, args$simTime, args$outputPath, args$configuration)
  save.coverage(
  	bs, args$simTime, args$outputPath, args$configuration, expectedCoverage
  )
  if (args$showAverages) {
    print("Printing average values")
    averages <- average.values(energy_consumption, bs, max=args$simTime)
    print(noquote(paste("average_values",
    				averages$coverage,
    				averages$broadcasting.time,
    				averages$power_consumption,
    				averages$duplicated_messages,
    				averages$retransmitted_messages)))
  }
  print("END")
}

main(get.arguments())
