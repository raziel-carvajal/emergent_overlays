require(omnetpp)
library(argparse)
library(igraph)

get.arguments <- function() {
  parser <- ArgumentParser(
    description='Get a distribution per broadcast metric from Omnet++ datasets.'
  )

  parser$add_argument('configName', type='character',
    help='Configuration ID at INI file.')
  parser$add_argument('datasetFile', type='character',
    help='Dataset of an experiment with Omnet++/INET (no extension).')

  parser$add_argument('--simulation-time',
    dest='simTime', type='double', help='Duration of experiment in seconds.')
  parser$add_argument('--broadcast-interval-lim-inf',
    dest='broaIntT0', type='double')
  parser$add_argument('--broadcast-interval-lim-sup',
    dest='broaIntT1', type='double')
  parser$add_argument('--results-dir',
    dest='resultsDir', type='character')
  parser$add_argument('--transmission-range',
    dest='tx', type='integer', help='Nodes transmission range.')

  parser$add_argument('--with-energy-consumption',
    dest='wpc', action='store_true')
  parser$add_argument('--with-coverage',
    dest='wco', action='store_true')
  parser$add_argument('--with-packet-err',
    dest='wpe', action='store_true')
  parser$add_argument('--with-sent-msgs',
    dest='wsm', action='store_true')
  parser$add_argument('--with-recv-msgs',
    dest='wrm', action='store_true')

  # center of dense zone
  parser$add_argument('--dense-zone-at-x',
    dest='dzx', type='double')
  parser$add_argument('--dense-zone-at-y',
    dest='dzy', type='double')
  # dense zone width
  parser$add_argument('--dense-zone-w',
    dest='dzw', type='double')
  parser$parse_args()
}

build.filename <- function(path, filename, id, seP="-") {
  filename <- paste(path, filename, sep="/")
  paste(filename, id, sep=seP)
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

get.density.relative.error <- function(results_file, first_measure,
  msg_freq, msgs_ids, overlays, algorithmN){
  measured_density <- getVector(
    results_file, 'density_approximation:vector'
  )
  denRelErrPerZone <- lapply(
    c('SPARSE', 'DENSE'),
    function(zone){
      densityRelativeError <- sapply(
        msgs_ids,
        function(msg){
          overlay <- overlays[[msg +1]]
          nodes <- getVerticesFromBiggestCluster(overlay)
          nodesInZone <- sapply( nodes,
            function(n){ ifelse(V(overlay)$location[n] == zone, n, NA) }
          )
          nodesInZone <- nodesInZone[!is.na(nodesInZone)]
          timestamp <- first_measure + msg_freq * (msg - 1)
          densAtTi  <- subset( measured_density, abs(time - timestamp) < TOLERANCE )
          # get measured number of neighbors over nodes
          densityPerZone <- sapply( nodesInZone,
            function(n){
              subset(densAtTi, node_id == n)$value
            }
          )
          # get real number of neighbors over nodes
          groundTruth <- sapply( nodesInZone,
            function(n){
              neigs <- overlay[n, ]
              length(neigs[neigs != 0])
            }
          )
          # get the relative error
          1 - ( densityPerZone / groundTruth )
        }
      )
      densityRelativeError <- as.vector(densityRelativeError)
      # print(densityRelativeError)
      # stop()
      data.frame(
        density_relative_err=densityRelativeError,
        zone=rep(zone, length(densityRelativeError)),
        algorithm=rep(algorithmN, length(densityRelativeError)),
        stringsAsFactors=F
      )
    }
  )
  # print(denRelErrPerZone)
  # stop()
  do.call('rbind', denRelErrPerZone)
}

get.graph <- function(nodes, nodesPositions, Tx, overlayNo,
  msgReceivers, msgEmitters, denseZone, forward_type_ds, savePlot=F) {

  edges <- unlist(
    sapply(nodes, function(n) {
      node <- subset(nodesPositions, nodeId == n)
      others<-subset(nodesPositions, nodeId != n)
      neigs <- sapply(others$nodeId, function(id) {
        o <- others[others$nodeId == id,]
        ifelse(
          sqrt((node$x - o$x)*(node$x - o$x) + (node$y - o$y)*(node$y - o$y)) <= Tx, o$nodeId, NA
        )
      })
      neigs <- neigs[ !is.na(neigs) ]
      sapply(neigs, function(neig) { c(node$nodeId, neig) })
    })
  )
  # TODO
  #
  # xlim <- data.frame(
  #   infe=denseZone$atX - denseZone$halfLenAtX,
  #   supe=denseZone$atX + denseZone$halfLenAtX
  # )
  # ylim <- data.frame(
  #   infe=denseZone$atY - denseZone$halfLenAtY,
  #   supe=denseZone$atY + denseZone$halfLenAtY
  # )
  #
  # nodesLocation <- sapply(nodes,
  #   function(n){
  #     nPos <- nodesPositions[nodesPositions$nodeId == n, ]
  #     ifelse(
  #       nPos$x >= xlim$infe && nPos$x <= xlim$supe &&
  #       nPos$y >= ylim$infe && nPos$y <= ylim$supe,
  #       'DENSE',
  #       'SPARSE'
  #     )
  #   }
  # )

  # create graph based on edges
  # TODO

  # forward_type <- subset( forward_type_ds,
  #   timestamp[1] <= time & timestamp[2] >= time
  # )

  g <- graph( edges=edges )
  # g <- make_undirected_graph(edges)
  # label whether nodes are located at the dense zone
  # TODO
  # V(g)$location <- nodesLocation

  # this code is followed IN DATASET to label nodes that forward messages:
  #   0 => SIMPLE
  #   1 => CDS RELAY
  #   2 => BORDER
  #   3 => RECEIVER
  #   4 => UNREACHABLE

  # TODO
  # labelCode <- rep(5, length(nodes))
  # labelCode[msgReceivers] <- 4
  # labelCode[ subset(forward_type, value == 0)$node_id ] <- 1
  # labelCode[ subset(forward_type, value == 1)$node_id ] <- 2
  # labelCode[ subset(forward_type, value == 2)$node_id ] <- 3
  # V(g)$colorCode <- labelCode

  if(savePlot){
    # TODO
    E(g)$arrow.mode <- 0
    E(g)$color <- 'lightgrey'
    # V(g)$size <- 4
    # V(g)$label <- ''
    # V(g)$frame.color <- 'black'
    # colors <- c('cyan', 'gold', 'orangered', 'dimgray', 'white')
    # V(g)$color <- colors[labelCode]

    # use node coordinates as layout
    layout <- cbind(nodesPositions$x, nodesPositions$y)
    # save one graph per broadcast session
    name <- paste("graph_", overlayNo, ".pdf", sep="")
    pdf(name)
    plot.igraph(g, layout=layout)

    # TODO
    # legend(
    #   x=0.7, y=1.4, title='Type of forward',
    #   c(
    #     paste('Simple [', length(labelCode[labelCode == 1]), ']'),
    #     paste('CDS relay [', length(labelCode[labelCode == 2]), ']'),
    #     paste('Border [', length(labelCode[labelCode == 3]), ']'),
    #     paste('Receiver [', length(labelCode[labelCode == 4]), ']'),
    #     paste('Unreachable [', length(labelCode[labelCode == 5]), ']')
    #   ), pch=21, col="#777777", pt.bg=colors, pt.cex=2, cex=.8, bty="n", ncol=1
    # )

    dev.off()
  }
  g
}

getVerticesFromBiggestCluster <- function(g){
  c <- components(g)
  d1 <- data.frame(indx=c(1:length(c$csize)), csize=c$csize)
  d2 <- data.frame(indx=c(1:length(c$membership)), membership=c$membership)
  clusterId <- subset(d1, csize == max(c$csize))$indx
	subset(d2, membership == clusterId)$indx
}

# This method replace the column [resultkey] of a dataset with a string
# obtained from the field [module], which refers to the node identifier
getVector <- function(dataset_file, vec_name){
  dataset <- loadVectors(
    loadDataset(
      paste(dataset_file, "vec", sep= "."),
      add(select=paste("name", "(", vec_name, ")", sep=""))
    ),
    NULL
  )
  # getting node identifier from column [vectors$module]
  tmp <- toString(dataset$vectors$module)
  tmp <- strsplit(unlist(strsplit(tmp, "\\.")), "host")
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

getEnergyConsumption <- function(dataset_loc, node_ids){

  radio_mode <- getVector(dataset_loc, "radioMode:vector")
  e_consump  <- getVector(dataset_loc, "residualCapacity:vector")

  sapply(node_ids, function(id){
    # timestamps of radio in tranceiver mode
    transciever_timestamp <- subset(
      subset(radio_mode, node_id == id),
      value == 2
    )$time
    e_consump_all_modes <- subset(e_consump, node_id == id)
    # get energy consumption of tranceiver mode per node
    e_consump_transcv_m <- sapply(transciever_timestamp, function(t){
      # energy at node when radio switch to tranceiver mode
      c0 <- subset(e_consump_all_modes, time == t)$value
      i  <- match(c0, e_consump_all_modes$value) + 1
      # energy at node when radio changed of mode (sleep, etc..)
      c1 <- e_consump_all_modes$value[i]
      c0 - c1
    })
    sum(e_consump_transcv_m[ !is.na(e_consump_transcv_m) ] * 1000) # convert to milli-Joules
  })
}

getWattsFromSentRecvMsgs <- function(sentMsgs, recvMsgs, nodes){
  wattsFromEmi <- sapply(nodes, function(n){
    # this constant is the cost in watts to send one message
    length(subset(sentMsgs, node_id == n)$value) * 0.1
  })
  wattsFromRec <- sapply(nodes, function(n){
    # this constant is the cost in watts to receive one message
    length(subset(recvMsgs, node_id == n)$value) * 0.01
  })
  data.frame(
    recCost=unlist(wattsFromRec),
    emiCost=unlist(wattsFromEmi)
  )
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
      overlay <- overlays[[msg + 1]]
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
      overlay <- overlays[[msg + 1]]
      senders <- unique( subset(sent_bro_msgs, value == msg)$node_id )
      data.frame(
        msgsNo=count.events.per.node(senders, sent_bro_msgs),
        algorithm=rep(algorithmN, length(senders)), stringsAsFactors=F
        # TODO
        # zone=V(overlay)$location[ senders ],
      )
    }
  )

  sentMsgDist <- do.call('rbind', sentMsgDist)
# INFO get distribution of received broadcast messages, adding the type of zone
#      (dense or sparse) where the receiver was positioned
  recvMsgDist <- lapply( msgs_ids,
    function(msg){
      overlay <- overlays[[msg + 1]]
      receivers <- unique( subset(recv_bro_msgs, value == msg)$node_id )
      data.frame(
        msgsNo=count.events.per.node(receivers, recv_bro_msgs),
        algorithm=rep(algorithmN, length(receivers)), stringsAsFactors=F
        # TODO
        # zone=V(overlay)$location[ receivers ],
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

getExpectedCoveredNodesNo <- function(overlays){
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

getStatistics <- function(dataset_path, scalar_name, stat="mean"){
  all_stats <- loadDataset(
    paste(dataset_path, sep= ".", "sca"),
    add(select=paste("name", "(", scalar_name, ")", sep=""))
  )

  node_ids <- toString(all_stats$statistics$module)
  node_ids <- strsplit(unlist(strsplit(node_ids, "\\.")), "host")
  node_ids <-unlist(
    lapply(node_ids, function(id_str){
      tmp <- ifelse( length(id_str) == 2, id_str[2], NA )
      tmp[!is.na(tmp)]
    })
  )

  key_id_map <- data.frame(
    key = all_stats$statistics$resultkey,
    node_id = as.numeric(node_ids)
  )

  scalar <- subset(all_stats$fields, fieldname == stat)
  data.frame(
    node_id = key_id_map$node_id,
    data = subset(scalar, resultkey == key_id_map$key)$fieldvalue
  )
}

main <- function(args) {
  expeConfig <- unlist(strsplit(args$configName, '_'))
  algorithmN <- toupper(expeConfig[ length(expeConfig) ])
  broadcastIn<- c(args$broaIntT0, args$broaIntT1)
  # TODO
  # NOTE ATM we consider that there is only one dense zone and one sparse zone
  # denseZone <- data.frame(
  #   atX=args$d_x, atY=args$d_y,
  #   halfLenAtX=(args$d_z_w / 2), halfLenAtY=(args$d_z_w / 2)
  # )
  datasetFile <- unlist(strsplit(args$datasetFile, args$configName))
  datasetFile <- paste(datasetFile[1], 'results/', args$configName, '-0', sep='')

  xPositions <- getVector(datasetFile, 'positionAtX:vector')
  yPositions <- getVector(datasetFile, 'positionAtY:vector')
  # merge nodes positions in one dataframe
  positions <- data.frame(
    nodeId = xPositions$node_id,
    time = xPositions$time,
    x = xPositions$value,
    y = yPositions[yPositions$node_id == xPositions$node_id, ]$value
  )
  positions <- positions[order(positions$time), ]
  positions <- subset(positions, time <= args$simTime)

  all_nodes <- unique( getVector(datasetFile, 'positionAtX:vector')$node_id )

  sent_broadcast_msgs <- getVector(datasetFile, 'sentBroadcastMsg:vector')
  recv_broadcast_msgs <- getVector(datasetFile, 'rcvdBroadcastMsg:vector')

  if(args$wpc){
    # NOTE deprecated
    # energy_consumption <- getEnergyConsumption(datasetFile, all_nodes)
    # saveDataFrame(
      # data.frame(
      #   data=energy_consumption,
      #   algo=rep(algorithmN, length(energy_consumption)), stringsAsFactors=F
      # ),
      #args$resultsDir, 'batteryConsumptionDistribution', algorithmN
    # )
    print('Get distribution of energy consumption')
    energy_consumption <- getWattsFromSentRecvMsgs(
      sent_broadcast_msgs, recv_broadcast_msgs, all_nodes
    )
    saveDataFrame(
      data.frame(
        data=energy_consumption$recCost + energy_consumption$emiCost,
        algo=rep(algorithmN, length(energy_consumption$recCost)), stringsAsFactors=F
      ),
      args$resultsDir, 'batteryConsumptionDistribution', algorithmN
    )
  }
  if(args$wsm){
    print('DONE - Get distribution of sent broadcast messages')
    sentBroMsgDist <- sapply(all_nodes, function(n){
      length(subset(sent_broadcast_msgs, node_id == n)$value)
    })
    saveDataFrame(
      data.frame(
        data=sentBroMsgDist,
        algo=rep(algorithmN, length(sentBroMsgDist)), stringsAsFactors=F
      ),
      args$resultsDir, 'sentBroadcastMsgsDistribution', algorithmN
    )
  }
  if(args$wrm){
    print('DONE - Get distribution of received broadcast messages')
    recvBroMsgDist <- sapply(all_nodes, function(n){
      length(subset(recv_broadcast_msgs, node_id == n)$value)
    })
    saveDataFrame(
      data.frame(
        data=recvBroMsgDist,
        algo=rep(algorithmN, length(recvBroMsgDist)), stringsAsFactors=F
      ),
      args$resultsDir, 'recvBroadcastMsgsDistribution', algorithmN
    )
  }
  # nodes are labeled according to the type of FWD they perform OR whether they
  # are border nodes (hybrid deployment) or not, this vector contains that
  # information in form of integer values where: 3 means border node,
  # 2 is a CDS relay and 0 means simple FWD
  # TODO
  # forward_type_ds <- getVector(
  # 	datasetFile, 'forward_type:vector')

  msgs_ids <- sort.int(unique(sent_broadcast_msgs$value))

  overlaysNumber <- floor(length(positions$time) / length(all_nodes))
  intervals <- data.frame(
    lowerLim= c(1, c( 1 : (overlaysNumber - 1) ) * length(all_nodes) + 1 ),
    upperLim= ( c(1:overlaysNumber) * length(all_nodes) )
  )
  # creates a list of wireless topologies using nodes positions (ground thruth)
  overlays <- lapply( c( 1 : overlaysNumber ), function( o ) {
    # a snapshot of the topology is taken just before a broadcast session take place
    nodesPositions <- positions[ c(intervals$lowerLim[o]:intervals$upperLim[o]), ]
    nodesPositions <- nodesPositions[order(nodesPositions$nodeId), ]

    # get emitters and receivers per snapshot
    msgEmitters <- unique( subset(sent_broadcast_msgs, value == msgs_ids[o])$node_id )
    msgReceivers <-unique( subset(recv_broadcast_msgs, value == msgs_ids[o])$node_id )
    # build wireless topology
    get.graph(
      all_nodes, nodesPositions, args$tx, o,
      msgReceivers, msgEmitters, NULL, NULL,
      savePlot=TRUE
    )
    # TODO
    # get.graph(
    #   all_nodes, positions, args$tx, locationTimestamp,
    #   msgReceivers, msgEmitters, denseZone, forward_type_ds,
    #   savePlot=TRUE
    # )
  })

  # save distribution of nodes per type of FWD they perform within the biggest
  # connected graph (a component of a wireless topology)
  # TODO
  #print('Get distribution of forwading types')
  # saveDataFrame(
  #   get.node.roles(overlays, msgs_ids, algorithmN),
  #   args$resultsDir, 'noderoles', algorithmN
  # )
  # TODO
  # print("DONE - Get relative error of density")
  # try(
  #   densityRelativeError <- get.density.relative.error(
  #     datasetFile, args$first_time_of_measuring_nodes_position,
  #     args$step, msgs_ids, overlays, algorithmN
  #   )
  # )
  # try(
  #   saveDataFrame(
  #     densityRelativeError,
  #     args$resultsDir, 'densityRelativeError', algorithmN
  #   )
  # )
  if(args$wpe){
    print("DONE - Get packet error rate")
    pktErrorRate <- getStatistics(datasetFile, "packetErrorRate:histogram")
    saveDataFrame(
      data.frame(
        data=pktErrorRate$data * 100 , # in percetage
        algo=rep(algorithmN, length(pktErrorRate$data)), stringsAsFactors=F
      ),
      args$resultsDir, 'packetErrorRate', algorithmN
    )
  }
  if(args$wco){
    print("DONE - Get network coverage")
    expectedCoverage <- getExpectedCoveredNodesNo(overlays)
    measuredCoverage <- sapply(msgs_ids, function(msg) {
      length( unique( subset(recv_broadcast_msgs, value == msg)$node_id ) )
    })
    coverage <- (measuredCoverage / expectedCoverage) * 100
    saveDataFrame(
      data.frame(
        data=coverage,
        algo=rep(algorithmN, length(coverage)), stringsAsFactors=F
      ),
      args$resultsDir, 'coverage', algorithmN
    )
  }
  # TODO
  # print('Get distribution of broadcast session time')
  # bs <- broadcastingTime(sent_msgs, recv_msgs, simulation.time = args$simTime)
  # print("DONE")
  # print("Exporting rest of broadcast metrics")
  # save.delay.time(bs, args$simTime, args$resultsDir, algorithmN)
  print('End of get-broadcast-metrics.R')
}

main(get.arguments())
