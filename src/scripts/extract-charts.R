require(omnetpp)
library(argparse)
library(igraph)

TOLERANCE <- 1e-8
SENT_RECV_PKG_TOLERANCE <- 1.5e-03
#
# Used to define the arguments of the script
#
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

load.datafile.scalar <- function(fname, query, extensions=c("sca", "vec")) {
  loadDataset(paste(fname, sep= ".", extensions), add(type="scalar", select=query) )
}


powerlevels3 <- function(ds, ts = seq(step, max, by=step), max, step=30) {
  # create a separate list for each power level
  others <- lapply(ds$vectors$resultkey, function(p) subset(ds$vectordata, resultkey==p) )
  # vector of power levels for each instant of time
  lapply(lapply(ts, function(t)  lapply(others, function(s) tail(s[s$x <= t,]$y, 1) ) ), unlist)
}

getRecOrTraTimeByNode_Session <- function(rcvOrTrsMsgsDs, nodes, broadcastSessions){
  lapply(nodes, function(n){
    lapply(broadcastSessions, function(b){
      subset(subset(rcvOrTrsMsgsDs, resultkey==n), y==b)$x
    })
  })
}


time.of.powerlevels <- function(ds, ts = seq(step, max, by=step), max, step=30) {
  # create a separate list for each power level
  others <- lapply(ds$vectors$resultkey, function(p) subset(ds$vectordata, resultkey==p) )
  # vector of power levels for each instant of time
  lapply(lapply(ts, function(t)  lapply(others, function(s) tail(s[s$x <= t,]$x, 1) ) ), unlist)
}

broadcastingTime <- function(msgDs, broDs, simulation.time) {

  # create a separate list for each msg_sent vector
  list_of_sent <- lapply(msgDs$vectors$resultkey, function(p) subset(msgDs$vectordata, resultkey == p))
  # print(list_of_sent)


  # recover list of msg id
  id_msgs <- msgDs$vectordata[[4]][!duplicated(msgDs$vectordata[[4]])]
  # print("feo")
  # print(id_msgs)

  # create a separate list for each broadcast_msg_received vector
  list_of_received <- lapply(broDs$vectors$resultkey, function(p) subset(broDs$vectordata, resultkey == p))
  # print("feo2")
  # print(list_of_received)

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

  # print(l.recp)
  # print(sending.time)

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


collect.duplicated.messages <- function(msgDs, broDs, simulation.time) {
  # create a separate list for each msg_sent vector
  list_of_sent <- lapply(msgDs$vectors$resultkey, function(p) subset(msgDs$vectordata, resultkey == p))

  # recover list of msg id
  id_msgs <- msgDs$vectordata[[4]][!duplicated(msgDs$vectordata[[4]])]

  # create a separate list for each broadcast_msg_received vector
  list_of_received <- lapply(broDs$vectors$resultkey, function(p) subset(broDs$vectordata, resultkey == p))

  l.recp <- lapply(id_msgs, function (id) {
						tmp.list <- lapply(list_of_received, function(d)  d[d$y == id,]$x )
						data.frame(dm = sapply(tmp.list, function(d) length(d)) )
			}
  )

  do.call("rbind", l.recp)
}


export.data.of.experiment <- function(expeId, broadcast.info, max, outputPath){

  n <- length(broadcast.info$id) # number of broadcast messages
  broDupMsgs <- broadcast.info$B.i / broadcast.info$n.received
  broDupMsgsInfo <- data.frame( whatever = c(broDupMsgs) )
  colnames(broDupMsgsInfo) <- c(expeId)
  write.table(
            broDupMsgsInfo,
            file = build.filename(outputPath, "duplicatedMsgsDistribution", expeId),
            row.names = F, append = F
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


save.duplicated.messages <- function(data, outputPath, expeId){
  dm <- data$dm[data$dm > 0] # only data from nodes that received the messages
  df <- data.frame( whatever = dm)
  colnames(df) <- c(expeId)
  write.table(
            df,
            file = build.filename(outputPath, "duplicatedMsgsDistribution", expeId),
            row.names = F, append = F
  )
}


save.power.level <- function(power.level, outputPath, expeId, class.of.nodes=NULL){
  pl <- power.level[lapply(power.level, length) > 0]
  values <- -1*as.numeric(unlist(c(tail(pl, 1))))
  if (is.null(class.of.nodes)) {
    class.of.nodes <- rep('*', length(values))
  }
  powerLevelInfo <- data.frame( whatever = values, protocol=class.of.nodes )
  colnames(powerLevelInfo) <- c(expeId, "protocol")

  print("COCO")
  print(class.of.nodes)

  if (length(unique(class.of.nodes)) > 1) {
    sapply(unique(class.of.nodes), function (p) {
      s <- powerLevelInfo[powerLevelInfo$protocol == p,1, drop=F]
      the.name <- paste(names(s)[1], as.character(p), sep="-")
      colnames(s) <- c(the.name)

      write.table(
        s,
        file = build.filename(outputPath, "batteryConsumptionDistribution", expeId),
        row.names = F, append = (p!=unique(class.of.nodes)[1])
        )
    })
  }

  write.table(
            powerLevelInfo[, 1, drop=F],
            file = build.filename(outputPath, "batteryConsumptionDistribution", expeId),
            row.names = F, append = (length(unique(class.of.nodes)) > 1)
  )
}


save.time.of.power.level <- function(data, outputPath, expeId) {
  t.pl <- time.of.data[lapply(data, length) > 0]
  t.powerLevelInfo <- data.frame( whatever = c(tail(t.pl, 1)) )
  colnames(t.powerLevelInfo) <- c(expeId)
  write.table(
            t.powerLevelInfo,
            file = build.filename(outputPath, "batteryConsumptionDistributionTime", expeId),
            row.names = F, append = F
  )
}


save.mac.frames.sent <- function(data, outputPath, expeId, class.of.nodes = NULL){
  values <- data.frame(node=data$scalars$resultkey, value=data$scalars$value)
  values <- values[order(values$node),]
  if (is.null(class.of.nodes)) {
    protocol.per.node <- rep('*', length(values$value))
  }
  values <- data.frame( whatever = values$value, protocol=class.of.nodes )
  colnames(values) <- c(expeId, "protocol")

  if (length(unique(class.of.nodes)) > 1) {
    sapply(unique(class.of.nodes), function (p) {
      s <- values[values$protocol == p,1, drop=F]
      the.name <- paste(names(s)[1], as.character(p), sep="-")
      colnames(s) <- c(the.name)

      write.table(
        s,
        file = build.filename(outputPath, "macFramesSent", expeId),
        row.names = F, append = (p!=unique(class.of.nodes)[1])
        )
    })
  }

  write.table(
            values[, 1, drop=F],
            file = build.filename(outputPath, "macFramesSent", expeId),
            row.names = F, append = (length(unique(class.of.nodes)) > 1)
  )

}


save.mac.frames.received <- function(data, outputPath, expeId, class.of.nodes=NULL){
  values <- data.frame(node=data$scalars$resultkey, value=data$scalars$value)
  values <- values[order(values$node),]
  if (is.null(class.of.nodes)) {
    protocol.per.node <- rep('*', length(values$value))
  }
  values <- data.frame( whatever = values$value, protocol=class.of.nodes )
  colnames(values) <- c(expeId, "protocol")

  if (length(unique(class.of.nodes)) > 1) {
    sapply(unique(class.of.nodes), function (p) {
      s <- values[values$protocol == p,1, drop=F]
      the.name <- paste(names(s)[1], as.character(p), sep="-")
      colnames(s) <- c(the.name)

      write.table(
        s,
        file = build.filename(outputPath, "macFramesReceived", expeId),
        row.names = F, append = (p!=unique(class.of.nodes)[1])
        )
    })
  }

  write.table(
            values[, 1, drop=F],
            file = build.filename(outputPath, "macFramesReceived", expeId),
            row.names = F, append = (length(unique(class.of.nodes)) > 1)
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


countmsgsperradiomode <- function(radiomodeds, msgsds, algo){
  keys <- subset(msgsds$vectordata, !duplicated(resultkey))$resultkey
  headers <- vector()
  for (i in 1:length(keys)) {
    a <- subset(radiomodeds, resultkey == keys[i])
    tmp <- subset(msgsds$vectordata, resultkey == keys[i])
    for (j in 1:length(tmp$resultkey)) {
      v <- tmp[j, ]
      t <- nrow( subset(a, x <= v$x) )
      if (na %in% headers[t]) {
        headers <- c(headers, t)
      }
    }
  }
  headers <- c(headers, "algorithm")
  nrow <- length(keys)
  ncol <- length(headers)
  r <- as.data.frame(matrix(0, nrow=nrow, ncol=ncol))
  names(r) <- headers
  for (i in 1:length(keys)) {
    a <- subset(radiomodeds, resultkey == keys[i])
    tmp <- subset(msgsds$vectordata, resultkey == keys[i])
    for (j in 1:length(tmp$resultkey)) {
      v <- tmp[j, ]
      t <- nrow( subset(a, x <= v$x) )
      r[i, t] <- r[i, t] + 1
    }
  }
  r[,"algorithm"] = algo
  r
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

exportDataset <- function(ds, dst){
  if (!file.exists(dst)) write.table(ds, file = dst, col.names = T, row.names = F, append = F, sep=",")
  else write.table(ds, file = dst, col.names = F, row.names = F, append = T, sep=",")
}

compute.time.per.protocol <- function(changes.of.protocol) {

  d <- changes.of.protocol$vectordata
  df <- data.frame(node=d$resultkey, t=d$x, v=d$y)

  nodes <- unique(df$node)

  protocol.changes <- lapply(nodes, function(n) { df[df$node==n,] } )

  max.time = max(df$t)

  my.shift.left <- function (x, shift, emptyvalue=NA) c(x[(1+shift):(length(x))], rep(emptyvalue, shift))

  my.shift.left <- function (x, shift, emptyvalue=NA) {
  	if (length(x) > shift ) (c(x[(1+shift):(length(x))], rep(emptyvalue, shift)))	else (rep(emptyvalue, length(x)))
  }

  df <- lapply(protocol.changes, function (pc) {
  	times = pc$t
  	tmp <- my.shift.left(times, 1, max.time)
  	data.frame(node = pc$node, t=times, v=pc$v, elapsed=(tmp - times))
  })

  times <- lapply(df, function (pc) {
  	tmp <- unique(pc$v)
  	node <- unique(pc$node)
  	dd <- sapply(tmp, function(pro) sum(pc[pc$v == pro,]$elapsed))
  	protocols <- sapply(tmp, intToUtf8)
  	dd <- data.frame(node=rep(node, length(tmp)), protocol=protocols, elapsed.time=dd)
    dd[dd$protocol!='E',]
  })

  tt <-do.call("rbind",lapply(times, function(pc) pc[max(pc$elapsed.time) == pc$elapsed.time,]))

  print("Count of nodes executing a protocol")
  print(lapply(unique(tt$protocol), function(t) data.frame(pro = t, count=length(tt[tt$protocol==t,]$protocol)) ))

  tt
}

compute.median.density.per.node <- function(density.over.time) {
  df <- density.over.time$vectordata
  df <- data.frame(node=df$resultkey, t=df$x, v=df$y)
  nodes <- unique(df$node)
  # densities.total <- lapply(nodes, function(n) { df[df$node==n,] } )
  densities <- lapply(nodes, function(n) { median(df[df$node==n,]$v) } )
  sapply(densities, function(d) if (d>15) 'dense' else 'sparse')
}

get.density.distribution <- function(results_file, first_measure,
  msg_freq, trans_range, sent_msgs, node_ids){

  x_positions <- replace.resultkey.with.node_id(
    results_file, "name(node_position_x:vector)"
  )
  y_positions <- replace.resultkey.with.node_id(
    results_file, "name(node_position_y:vector)"
  )

  msgs_ids <- unique(sent_msgs$value)
#  print(msgs_ids)

  density_ground_truth <- lapply(msgs_ids, function(msg){
    # get point in time where nodes' positions were reported
    time <- first_measure + msg_freq * (msg - 1)
    # create the graph with the position of each node
    g <- get.graph(time, trans_range, x_positions, y_positions)
    vertices <- getVerticesFromBiggestCluster(g)
   	#XXX plot to check graph
#		name <- paste("graph_", msg, ".pdf", sep="")
#		pdf(name)
#		plot(g)
#		dev.off()

    lapply(vertices, function(v){
      node_neigs <- g[v, ]
      length(node_neigs[node_neigs != 0])
    })
  })

  unlist(density_ground_truth)
#  print(density_ground_truth)
#  stop()
#
#  sapply(1:nrow(density_ground_truth), function(r){
#    sum(density_ground_truth[r, ]) / length(density_ground_truth[r, ])
#  })

}

compute.relative.error.in.density <- function(results_file, first_measure,
  msg_freq, trans_range, sent_msgs, node_ids){

  x_positions <- replace.resultkey.with.node_id(
    results_file, "name(node_position_x:vector)"
  )
  y_positions <- replace.resultkey.with.node_id(
    results_file, "name(node_position_y:vector)"
  )
  measured_density <- replace.resultkey.with.node_id(
    results_file, "name(density_approximation:vector)"
  )

  msgs_ids <- unique(sent_msgs$value)

  density_approx <- lapply(msgs_ids, function(msg){
    # get point in time where nodes' positions were reported
    time <- first_measure + msg_freq * (msg - 1)

    indx_per_time <- measured_density[abs(measured_density$time - time) < TOLERANCE, ]

    lapply(node_ids, function(node_id){
      indx_per_time[indx_per_time$node_id == node_id, ]$value
    })
  })

  unlist(density_approx)
#
#  density_ground_truth <- sapply(msgs_ids, function(msg){

#    # get point in time where nodes' positions were reported
#    time <- first_measure + msg_freq * (msg - 1)
#    # create the graph with the position of each node
#    g <- get.graph(time, trans_range, x_positions, y_positions)
#    sapply(node_ids, function(node_id){
#      node_neigs <- g[node_id, ]
#      length(node_neigs[node_neigs != 0])
#    })
#  })

#  absolute_err <- abs(density_approx - density_ground_truth)

#  #relative error with vectors
#  relative_err <- sapply(1:nrow(absolute_err), function(r){
#    max(absolute_err[r, ]) / max( density_ground_truth[r, ] )
#  })
#  print(relative_err)
#  relative_err
}

get.graph <- function(time, Tx, x_positions, y_positions) {

  allPositions <- data.frame(
    nodeId = x_positions$node_id,
    time = x_positions$time,
    x = x_positions$value,
    y = y_positions[y_positions$node_id == x_positions$node_id, ]$value
  )

  nodes <- unique(allPositions$nodeId)

  nodesPositions <- allPositions[ abs(allPositions$time - time) < TOLERANCE, ]

  tmp <- unlist(lapply(nodes, function(n){
    node <- nodesPositions[nodesPositions$nodeId == n, ]
    others <- nodesPositions[nodesPositions$nodeId != n, ]

    neigs <- subset(
      others,
      sqrt((node$x - x)*(node$x - x) + (node$y - y)*(node$y - y)) <= Tx
    )$nodeId

    sapply(neigs, function(neig){
      c(node$nodeId, neig)
    })

  }))

  # network overlay from last time nodes print their positions
  g <- graph( edges=tmp )

  # gets the biggest connected cluster
  # XXX we assume that the source node belongs to this cluster
  # TODO find a way to ensure that the source node is always within the
  #			the biggest cluster
  biggestCluster <- getVerticesFromBiggestCluster(g)

  d0 <- data.frame(indx=1:length(tmp), v=tmp)
  matr <- data.frame(
  	A=subset(d0, indx %% 2 == 1)$v,
  	B=subset(d0, indx %% 2 == 0)$v
  )
	edgesAtCluster <- unlist(sapply(biggestCluster, function(i){
		dsts <- subset(matr, A == i)$B
		sapply(dsts, function(j){
			c(i, j)
		})
	}))
	graph(edges=edgesAtCluster, directed=F)
#	vertices <- V(subGraph)
#	print(vertices)
#	toRemove <- vertices[! vertices %in% biggestCluster]
#	print(toRemove)
#	g1 <- delete_vertices(subGraph, toRemove)
#	print(V(g1))
#	g1
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
    n_e_consump <- sort.int( subset(energy_consumption, node_id == n)$value )
    n_e_consump[length(n_e_consump)] - n_e_consump[1]
  })

  e_consump_per_node
}
# energy.consumption.of.sent_recv.messages <- function(results_file,
#   exp_duration, sent_packages, recv_packages, nodes){
#
#   energy_consumption <- subset(
#     replace.resultkey.with.node_id(results_file, "name(residualCapacity:vector)"),
#     time < exp_duration
#   )
#
#   e_consump_per_node <- sapply(nodes, function(n){
#
#     n_e_consump <- subset(energy_consumption, node_id == n)
#
#     n_recv_msgs <- subset(recv_packages, node_id == n)
#
#     key_timestamps <- unlist(
#       sapply(n_recv_msgs$time, function(t){
#         subset(n_e_consump, time == t)$time
#       })
#     )
#
#     e_consump_recv_msgs <- sapply(key_timestamps, function(t_i){
#       consump_before_t <- abs(
#         subset(
#           subset(n_e_consump, t_i - time >= 0),
#           abs(t_i - time) < SENT_RECV_PKG_TOLERANCE
#         )
#       )
#       ifelse(
#         length(consump_before_t$node_id) >= 2,
#         abs(tail(consump_before_t$value, 1) - tail(consump_before_t$value, 2)[1]),
#         0
#       )
#     })
#
#     key_timestamps <- subset(sent_packages, node_id == n)$time
#
#     e_consump_sent_msgs <- sapply(key_timestamps, function(t_i){
#
#       t_i_consump_vec <- sort(
#         abs(
#           subset(
#             n_e_consump,
#             abs(t_i - time) < SENT_RECV_PKG_TOLERANCE
#           )$value
#         )
#       , decreasing = T)
#
#       ifelse(
#         length(t_i_consump_vec) >= 2,
#         highest.energy.consumption(t_i_consump_vec),
#         0
#       )
#
#     })
#
#     # this vector is multiplied by 1K to have milli Joules
#     sum( unlist(e_consump_sent_msgs), unlist(e_consump_recv_msgs) ) * 1000
#   })
#
#   e_consump_per_node
# }

highest.energy.consumption <- function(v){
  quasi_v <- tail(v, length(v) - 1)
  quasi_v <- c(quasi_v, tail(v,1)[1])
  max(v - quasi_v)
}

collisions.relative.error <- function(results_file, first_measure, msg_freq,
    trans_range, sent_msgs, recv_msgs){

  x_positions <- replace.resultkey.with.node_id(
    results_file, "name(node_position_x:vector)"
  )
  y_positions <- replace.resultkey.with.node_id(
    results_file, "name(node_position_y:vector)"
  )

  sent_msgs <- data.frame(
    node_id = sent_msgs$node_id,
    broadcast_id = sent_msgs$value
  )
  recv_msgs <- data.frame(
    node_id = recv_msgs$node_id,
    broadcast_id = recv_msgs$value
  )
  msgs_ids <- unique(sent_msgs$broadcast_id)

  ground_truth_recv_msgs <- unlist(
    lapply(msgs_ids, function(msg){
      # get point in time where nodes' positions were reported
      time <- first_measure + msg_freq * (msg - 1)

      # create the graph with the position of each node
      g <- get.graph(time, trans_range, x_positions, y_positions)
      #
      is_connected <- is_connected(g)

      #all nodes that send broadcast messages [msg]
      senders <- unique(sent_msgs[sent_msgs$broadcast_id == msg, ]$node_id)

#      colors <- sapply(1:length(V(g)), function(v){
#        ifelse(v %in% senders, "orange", "red")
#      })
#      V(g)$color <- colors
#      name <- paste(
#        paste(
#          paste("GraphForMsg_", msg, sep=""),
#            is_connected(g), sep="_"),
#      "pdf", sep=".")
#      pdf(name)
#      plot(g)
#      dev.off()

      tmp <- sapply(senders, function(s){
        edges <- g[s, ]
        #return number of neighbors of node [e]
        length( edges[edges != 0] )
      })
      #the ground truth of sent broadcast is obtained as follows:
      #  - the sum of the size of every node's neighborhood (getting from graph)
      #  - every emitter also receive a message when it is sent by itself (self transition)
      #  - the last case is not valid for the source node; reason of having minus one
      sum(tmp) + length(senders) - 1
    })
  )

  measured_recv_msgs <- unlist(
      lapply(msgs_ids, function(msg){
        #all nodes that receive broadcast message [msg]
        receivers <- recv_msgs[recv_msgs$broadcast_id == msg, ]$node_id

        length(receivers)
      })
  )

  abs(measured_recv_msgs - ground_truth_recv_msgs) / ground_truth_recv_msgs
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

saveGroundTruthOfDensity <- function(results_file, first_measure,
  msg_freq, trans_range, sent_msgs, node_ids){

  x_positions <- replace.resultkey.with.node_id(
    results_file, "name(node_position_x:vector)"
  )
  y_positions <- replace.resultkey.with.node_id(
    results_file, "name(node_position_y:vector)"
  )

  msgs_ids <- unique(sent_msgs$value)

  density_ground_truth <- lapply(msgs_ids, function(msg){
    # get point in time where nodes' positions were reported
    time <- first_measure + msg_freq * (msg - 1)
    # create the graph with the position of each node
    g <- get.graph(time, trans_range, x_positions, y_positions)
    vertices <- getVerticesFromBiggestCluster(g)

# 	name <- paste("graph_", msg, ".pdf", sep="")
#		pdf(name)
#		plot(g)
#		dev.off()

    lapply(vertices, function(v){
      node_neigs <- g[v, ]
      length(node_neigs[node_neigs != 0])
    })
  })

	unlist(density_ground_truth)
}

getExpectedCoverage <- function(results_file, first_measure,
  msg_freq, trans_range, sent_msgs, node_ids){
  x_positions <- replace.resultkey.with.node_id(
    results_file, "name(node_position_x:vector)"
  )
  y_positions <- replace.resultkey.with.node_id(
    results_file, "name(node_position_y:vector)"
  )
  msgs_ids <- unique(sent_msgs$value)
  sapply(msgs_ids, function(msg) {
    # get point in time where nodes' positions were reported
    time <- first_measure + msg_freq * (msg - 1)
    # create the graph with the position of each node
    g <- get.graph(time, trans_range, x_positions, y_positions)
    length( getVerticesFromBiggestCluster(g) )
  })

}

main <- function(args) {
  print(paste("Simulation time", args$simTime, "seconds"))
  pl.step <- args$step
  exp_duration <-
	  args$time_of_first_broadcast_message + args$broadcast_msgs * pl.step
	all_nodes <- unique(
		replace.resultkey.with.node_id(args$file, "name(density_approximation:vector)")$node_id
	)

  sent_broadcast_msgs <- replace.resultkey.with.node_id(
  	args$file, "name(msg_sent:vector)")
  recv_broadcast_msgs <- replace.resultkey.with.node_id(
  	args$file, "name(broadcast_msg_received:vector)")

  sent_packages <- subset(
      replace.resultkey.with.node_id(args$file, "name(sentPk:vector*)"),
      time < exp_duration)
  recv_packages <- subset(
      replace.resultkey.with.node_id(args$file, "name(rcvdPk:vector*)"),
      time < exp_duration)

	expectedCoverage <- getExpectedCoverage(
	  args$file,
	  args$first_time_of_measuring_nodes_position,
	  args$step,
	  args$transmission_range,
	  sent_broadcast_msgs, all_nodes
	)

	datasetExists <- list.files(args$outputPath)
	datasetExists <- datasetExists[datasetExists == "groundTruthDensityDist-"]
	if( length(datasetExists) == 0 ) {
		print("Save ground truth of density")
		groundTruthD <- saveGroundTruthOfDensity(
		  args$file,
		  args$first_time_of_measuring_nodes_position,
		  args$step,
		  args$transmission_range,
		  sent_broadcast_msgs, all_nodes
		)
		save.distribution(
		  "groundTruthDensityDist", groundTruthD,
		  args$outputPath, ""
  	)
		strV <- unlist(strsplit(args$configuration, "_"))
		strV <- strV[ 1:length(strV)-1 ]
		undV <- rep("_", length(strV))
		resu <- sapply(1:length(strV), function(i){
			paste(strV[i], undV[i], sep="")
		})
		resu <- c(resu, "Ground-Truth")
		newName <- paste(resu, collapse="")
		save.distribution(
		  "groundTruthDensityDist", groundTruthD,
		  args$outputPath, newName
  	)
  	print("DONE!")
  }

  print("Calculating nodes' real density")
  density_dist <- get.density.distribution(
    args$file,
    args$first_time_of_measuring_nodes_position,
    args$step,
    args$transmission_range,
    sent_broadcast_msgs, all_nodes
  )
  print("DONE!")

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
  density.relative.errors <- compute.relative.error.in.density(
    args$file,
    args$first_time_of_measuring_nodes_position,
    args$step,
    args$transmission_range,
    sent_broadcast_msgs, all_nodes
  )
  print("DONE!")

  print("Calculating relative error of collisions")
  collisions_re <- collisions.relative.error(
    args$file,
    args$first_time_of_measuring_nodes_position,
    args$step,
    args$transmission_range,
    sent_broadcast_msgs,
    recv_broadcast_msgs
  )
  print(collisions_re)
  print("DONE!")

  protocol.per.node <- NULL
  median.density.per.node <- NULL
  if (args$splitted) {
    print(paste("Loading changes of protocol over time", args$file))
    changes.of.protocol <- load.datafile(args$file, "name(protocol_change:vector)")
    protocol.per.node <- compute.time.per.protocol(changes.of.protocol)
    print(paste("Loading density over time", args$file))
    density.over.time <- load.datafile(args$file, "name(density_approximation:vector)")
    median.density.per.node <- compute.median.density.per.node(density.over.time)
    print("DONE!")
  }

  print("Reading vectors with messages sent and received")
  sent_msgs <- load.datafile(args$file, "name(msg_sent:vector)" )
  recv_msgs <- load.datafile(args$file, "name(broadcast_msg_received:vector)" )
  print("DONE!")

  print("Computing maximal reception delay")
  bs <- broadcastingTime(sent_msgs, recv_msgs, simulation.time = args$simTime)
  print("DONE!")

#  print("Collecting information on number of duplicated messages")
#  dm <- collect.duplicated.messages(sent_msgs, recv_msgs, simulation.time = args$simTime)

  #######################
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
    "distributionOfDensity", density_dist,
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
#  save.duplicated.messages(dm, args$outputPath, args$configuration)
  #######################
  # optional behavior
  if (args$computeRadioMode) {
    print("Ohhh ... this is a debug session. Ok, reading radio modes")
    # get the intervals of time of two radio modes where:
    # - 2 means reception mode
    # - 3 means transmission mode
    # this script was tested with a dataset of ABBA and Floding just for reception mode
    #TODO: for protocols that send control messages (like CDS) this script gets an error
    #TODO: figure out why an error occurs when the transmission mode is analyzed
    radioMode <- load.datafile(args$file, "name(radioMode:vector)" )
    rcvM <- subset(radioMode$vectordata, y == 2)
    trsM <- subset(radioMode$vectordata, y == 3)
    r <- countMsgsPerRadioMode(rcvM, recv_msgs, args$algorithm)
    filename <- build.filename(args$outputPath, "RadioModeReception", args$density)
    exportDataset(r, filename)
  }

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
