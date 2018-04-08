require(omnetpp)
library(argparse)
library(igraph)

TOLERANCE <- 1e-8
BROADCAST_SESSION_TOLERANCE <- 1000e-03 # 1000 ms = 0.1 s
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

  parser$add_argument('-d_x', type='double',
    help='Abscissa of dense zone center')
  parser$add_argument('-d_y', type='double',
    help='Ordinate of dense zone center')
  parser$add_argument('-d_h_x', type='double',
    help='Half of the widht dense zone')
  parser$add_argument('-d_h_y', type='double',
    help='Half of the height dense zone')

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
  ground_truth <- lapply( overlays,
    function(overlay){
      nodes <- getVerticesFromBiggestCluster(overlay)
      neigs <- sapply( nodes,
        function(n){
          neigs <- overlay[n, ]
          length(neigs[neigs != 0])
        }
      )
      at_zone <- V(overlay)$location
      data.frame( neigsNo=neigs, zoneLocation=at_zone[nodes],
        algorithm=rep('GroundTruth', length(neigs)), stringsAsFactors=F
      )
    }
  )
  do.call('rbind', ground_truth)
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
}

get.graph <- function(nodes, positions, Tx, locationTimestamp,
  msgTimestamp, msgReceivers, msgEmitters, denseZone, forward_type_ds, savePlot=F) {

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

  xlim <- data.frame(
    infe=denseZone$atX - denseZone$halfLenAtX,
    supe=denseZone$atX + denseZone$halfLenAtX
  )
  ylim <- data.frame(
    infe=denseZone$atY - denseZone$halfLenAtY,
    supe=denseZone$atY + denseZone$halfLenAtY
  )

  nodesLocation <- sapply(nodes,
    function(n){
      nPos <- nodesPositions[nodesPositions$nodeId == n, ]
      ifelse(
        nPos$x >= xlim$infe && nPos$x <= xlim$supe &&
        nPos$y >= ylim$infe && nPos$y <= ylim$supe,
        'DENSE',
        'SPARSE'
      )
    }
  )
  # create graph based on edges
  forward_type <- subset( forward_type_ds,
    abs(time - msgTimestamp) <= BROADCAST_SESSION_TOLERANCE
  )
  g <- graph( edges=edges )
  # label whether nodes are located at the dense zone
  V(g)$location <- nodesLocation
  # this code is followed IN DATASET to label nodes that forward messages:
  #   0 => SIMPLE
  #   1 => CDS RELAY
  #   2 => BORDER
  #   3 => RECEIVER
  #   4 => UNREACHABLE
  labelCode <- rep(5, length(nodes))
  labelCode[msgReceivers] <- 4
  labelCode[ subset(forward_type, value == 0)$node_id ] <- 1
  labelCode[ subset(forward_type, value == 1)$node_id ] <- 2
  labelCode[ subset(forward_type, value == 2)$node_id ] <- 3
  V(g)$colorCode <- labelCode
  if(savePlot){
    E(g)$arrow.mode <- 0
    E(g)$color <- 'lightgrey'
    V(g)$size <- 4
    V(g)$label <- ''
    V(g)$frame.color <- 'black'
    colors <- c('cyan', 'gold', 'orangered', 'dimgray', 'white')
    V(g)$color <- colors[labelCode]
    # use node coordinates as layout
    layout <- cbind(nodesPositions$x, nodesPositions$y)
    # save one graph per broadcast session
    name <- paste("graph_", locationTimestamp, ".pdf", sep="")
    pdf(name)
    plot.igraph(g, layout=layout)
    legend(
      x=0.7, y=1.4, title='Type of forward',
      c(
        paste('Simple [', length(labelCode[labelCode == 1]), ']'),
        paste('CDS relay [', length(labelCode[labelCode == 2]), ']'),
        paste('Border [', length(labelCode[labelCode == 3]), ']'),
        paste('Receiver [', length(labelCode[labelCode == 4]), ']'),
        paste('Unreachable [', length(labelCode[labelCode == 5]), ']')
      ), pch=21, col="#777777", pt.bg=colors, pt.cex=2, cex=.8, bty="n", ncol=1
    )
    dev.off()
  }
  # return graph
  g
}

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
      # connected_nodes <- getVerticesFromBiggestCluster(overlay)
      # nodes_location <- V(overlay)$location[connected_nodes]
      nodes_location <- V(overlay)$location
      zones <- unique(nodes_location)
      nodes_per_location <- sapply( zones,
        function(z){
          nodes_at_z <- sapply( 1:length(nodes_location),
            function(i){
              ifelse(nodes_location[i] == z, i, NA)
            }
          )
          nodes_at_z[ !is.na(nodes_at_z) ]
        }
      )
      nodes_fw_type <- V(overlay)$colorCode
      fw_codes <- unique(nodes_fw_type)
      lapply( nodes_per_location,
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
  # XXX find a way to to this with a lapply
  dsPerZone <- list(
    do.call( 'rbind', lapply(node_roles, function(df){ df$SPARSE }) ),
    do.call( 'rbind', lapply(node_roles, function(df){ df$DENSE }) )
  )
  zones <- c('SPARSE', 'DENSE')
  merged_ds <- lapply(1:2,
    function(i){
      ds <- dsPerZone[[i]]
      fw_codes <- unique(ds$fw_code)

      # INFO we have now total number of nodes per FW code
      dsAsMatrix <- sapply( fw_codes,
        function(code){ sum(subset(ds, fw_code == code)$count) }
      )
      # INFO we get the percentage over all broadcast messages and nodes
      dsLen <- sum(ds$count)
      data.frame(
        count=as.vector(floor((dsAsMatrix * 100) / dsLen)),
        fw_code=names(dsAsMatrix),
        zone=rep(zones[[i]], length(dsAsMatrix)),
        algorithm=rep(algorithmN, length(dsAsMatrix)),
        stringsAsFactors=F
      )
    }
  )
  do.call('rbind', merged_ds)
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

distribution.sent_recv.broadcast_control.messages <- function(
  sent_bro_msgs, recv_bro_msgs, sent_pkgs, recv_pkgs, nodes,
  overlays, msgs_ids, algorithmN){
# INFO get distribution of sent broadcast messages, adding the type of zone
#      (dense or sparse) where the sender was positioned
  sentMsgDist <- lapply( msgs_ids,
    function(msg){
      overlay <- overlays[[msg]]
      senders <- unique( subset(sent_bro_msgs, value == msg)$node_id )
      data.frame(
        msgsNo=count.events.per.node(senders, sent_bro_msgs),
        zone=V(overlay)$location[ senders ],
        algorithm=rep(algorithmN, length(senders)), stringsAsFactors=F
      )
    }
  )
  sentMsgDist <- do.call('rbind', sentMsgDist)
# INFO get distribution of received broadcast messages, adding the type of zone
#      (dense or sparse) where the receiver was positioned
  recvMsgDist <- lapply( msgs_ids,
    function(msg){
      overlay <- overlays[[msg]]
      receivers <- unique( subset(recv_bro_msgs, value == msg)$node_id )
      data.frame(
        msgsNo=count.events.per.node(receivers, recv_bro_msgs),
        zone=V(overlay)$location[ receivers ],
        algorithm=rep(algorithmN, length(receivers)), stringsAsFactors=F
      )
    }
  )
  recvMsgDist <- do.call('rbind', recvMsgDist)

  sentCtrlMsgDist <- count.events_compl.per.node(nodes, sent_pkgs, sent_bro_msgs)
  sentCtrlMsgDist <- data.frame(
    msgsNo=sentCtrlMsgDist, algorithm=rep(algorithmN, length(sentCtrlMsgDist)), stringsAsFactors=F
  )
  recvCtrlMsgDist <- count.events_compl.per.node(nodes, recv_pkgs, recv_bro_msgs)
  recvCtrlMsgDist <- data.frame(
    masgsNo=recvCtrlMsgDist, algorithm=rep(algorithmN, length(recvCtrlMsgDist)), stringsAsFactors=F
  )
  result <- list( sentMsgDist, recvMsgDist, sentCtrlMsgDist, recvCtrlMsgDist )
  names(result) <- c('sentBroMsgDist', 'recvBroMsgDist', 'sentCtrlMsgDist', 'recvCtrlMsgDist')
  result
}

getExpectedCoverage <- function(overlays){
  sapply(overlays, function(overlay) {
    length( getVerticesFromBiggestCluster(overlay) )
  })
}

saveDataFrame <- function(df, dstPath, fileName, expeConfig){
  write.table(
    df, file = build.filename(dstPath, fileName, expeConfig),
    row.names=F, col.names=F
  )
}

main <- function(args) {
  print(paste("Simulation time", args$simTime, "seconds"))
  expeConfig <- unlist(strsplit(args$configuration, '_'))
  algorithmN <- toupper(expeConfig[ length(expeConfig) ])
  # INFO metadate of dense zone
  # NOTE ATM we consider that there is only one dense zone and one sparse zone
  denseZone <- data.frame(
    atX=args$d_x, atY=args$d_y, halfLenAtX=args$d_h_x, halfLenAtY=args$d_h_y
  )
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

  forward_type_ds <- replace.resultkey.with.node_id(
  	args$file, "name(forward_type:vector)")

  msgs_ids <- sort.int(unique(sent_broadcast_msgs$value))
  # creates a list of virtual overlays per broadcast session, where each
  # overlay refers to the graph form by the message dissemination
  overlays <- lapply(msgs_ids, function(msg) {
    # point in time where node
    locationTimestamp <-
      args$first_time_of_measuring_nodes_position + args$step * (msg - 1)
    msgTimestamp <-
      args$time_of_first_broadcast_message + args$step * (msg - 1)
    msgEmitters <- unique( subset(sent_broadcast_msgs, value == msg)$node_id )
    msgReceivers <-unique( subset(recv_broadcast_msgs, value == msg)$node_id )
    # create the graph with the position of each node
    # TODO denseZone$atY - denseZone$halfLen
    get.graph(
      all_nodes, positions, args$transmission_range, locationTimestamp,
      msgTimestamp, msgReceivers, msgEmitters, denseZone, forward_type_ds,
      savePlot=TRUE
    )
  })
  # INFO save distribution of nodes per FW type
  saveDataFrame(
    get.node.roles(overlays, msgs_ids, algorithmN),
    args$outputPath, 'noderoles', args$configuration
  )

  sent_packages <- subset(
    replace.resultkey.with.node_id(args$file, "name(sentPk:vector*)"),
    time < exp_duration
  )
  recv_packages <- subset(
    replace.resultkey.with.node_id(args$file, "name(rcvdPk:vector*)"),
    time < exp_duration
  )
  # expected number of nodes that must receive a broadcast message
  # over all sessions of dissemination
	expectedCoverage <- getExpectedCoverage(overlays)

	datasetExists <- list.files(args$outputPath)
	if(! "groundTruthDensityDist-" %in% datasetExists) {
		print('Compute ground truth of nodes neighbors')
		saveDataFrame(
      get.density.distribution(overlays),
      args$outputPath, 'groundTruthDensityDist', ''
  	)
  	print('DONE')
  }
  print("Calculating distribution of sent and received broadcast/control messages")
  sent_recv_msgs <- distribution.sent_recv.broadcast_control.messages(
    sent_broadcast_msgs, recv_broadcast_msgs,
    sent_packages, recv_packages, all_nodes,
    overlays, msgs_ids, algorithmN
  )
  # save distributions of sent/received messages (ctrl and broadcast)
  saveDataFrame(
    sent_recv_msgs$sentBroMsgDist, args$outputPath,
    'sentBroadcastMsgsDistribution', args$configuration
  )
  saveDataFrame(
    sent_recv_msgs$recvBroMsgDist, args$outputPath,
    'recvBroadcastMsgsDistribution', args$configuration
  )
  saveDataFrame(
    sent_recv_msgs$sentCtrlMsgDist, args$outputPath,
    'sentCtrlMsgsDistribution', args$configuration
  )
  saveDataFrame(
    sent_recv_msgs$recvCtrlMsgDist, args$outputPath,
    'recvCtrlMsgsDistribution', args$configuration
  )
  print("DONE!")
  print("Calculating energy consumption")
  energy_consumption <- energy.consumption.of.sent_recv.messages(
    args$file, exp_duration,
    sent_packages, recv_packages, all_nodes
  )
  saveDataFrame(
    data.frame(
      data=energy_consumption,
      algo=rep(algorithmN, length(energy_consumption)), stringsAsFactors=F
    ),
    args$outputPath, 'batteryConsumptionDistribution', args$configuration
  )
  print("DONE!")

  print("Calculating approximation of nodes' density")
  density.relative.errors <- get.measured.density(
    args$file, args$first_time_of_measuring_nodes_position,
    args$step, msgs_ids, all_nodes
  )
  print("DONE!")

  print("Calculating relative error of collisions")
  collisions_re <- collisions.relative.error(
    sent_broadcast_msgs, recv_broadcast_msgs,
    msgs_ids, overlays, all_nodes
  )
  print("DONE!")

  print('Get distribution of broadcast session time')
  sent_msgs <- load.datafile(args$file, "name(msg_sent:vector)" )
  recv_msgs <- load.datafile(args$file, "name(broadcast_msg_received:vector)" )
  bs <- broadcastingTime(sent_msgs, recv_msgs, simulation.time = args$simTime)
  print("DONE")

  print("Exporting rest of broadcast metrics")
  saveDataFrame(
    data.frame(
      data=density.relative.errors,
      algo=rep(algorithmN, length(density.relative.errors)), stringsAsFactors=F
    ),
    args$outputPath, 'densityRelativeError', args$configuration
  )
  saveDataFrame(
    data.frame(
      data=collisions_re,
      algo=rep(algorithmN, length(collisions_re)), stringsAsFactors=F
    ),
    args$outputPath, 'collisionsRelativeError', args$configuration
  )
  save.delay.time(bs, args$simTime, args$outputPath, args$configuration)
  # save network coverage
  coverage <- (bs$n.received / expectedCoverage) * 100
  saveDataFrame(
    data.frame(
      data=coverage,
      algo=rep(algorithmN, length(coverage)), stringsAsFactors=F
    ),
    args$outputPath, 'coverage', args$configuration
  )
  print('DONE')
  if (args$showAverages) {
    print("Printing average values")
    averages <- average.values(energy_consumption, bs, max=args$simTime)
    print(
      noquote( paste("average_values",
      averages$coverage, averages$broadcasting.time, averages$power_consumption,
			averages$duplicated_messages, averages$retransmitted_messages
    )))
    print("DONE")
  }
}

main(get.arguments())
