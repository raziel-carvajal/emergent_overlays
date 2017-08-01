require(omnetpp)
library(argparse)
library(igraph)

TOLERANCE <- 1e-8

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
  parser$add_argument('-d', '--density', metavar='density', type="integer",
                      help='Density of the topology used')
  parser$add_argument('-ds', '--density-as-string', metavar='density_string', type="character",
                      help='Density of the topology used as string')
  parser$add_argument('--radio-mode', dest='computeRadioMode', action="store_true",
                      help='Computing the time spent in each radio mode (a debug only option)')
  parser$add_argument('--save-time-power-level', dest='timeOfPowerLevels', action="store_true",
                      help='Compute and save the time last time each node updates its power consumption (a debug only option)')
  parser$add_argument('--export-data-for-raziel', dest='exportForRaziel', action="store_true",
                      help='This option will probably become the default as soon as we fixed the other scripts')

  parser$add_argument('--plot', dest='plot', action="store_true",
                      help='When this flag is specified, a pdf file with the name of the configuration is generared. The file contains a bunch of charts.')

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

save.coverage <- function(broadcast.info, max, outputPath, expeId){
  cov <- broadcast.info$n.received
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

save.density.relative.errors <- function(data, outputPath, expeId){
  values <- data.frame(value=data)
  colnames(values) <- c(expeId)

  write.table(
            values,
            file = build.filename(outputPath, "densityRelativeError", expeId),
            row.names = F, append = F
  )
}

save.density.distribution <- function(data, outputPath, expeId){
  values <- data.frame(value=data)
  colnames(values) <- c(expeId)

  write.table(
            values,
            file = build.filename(outputPath, "distributionOfDensity", expeId),
            row.names = F, append = F
  )
}

save.collisions.relative.error <- function(data, outputPath, expeId){
  values <- data.frame(value=data)
  colnames(values) <- c(expeId)

  write.table(
            values,
            file = build.filename(outputPath, "collisionsRelativeError", expeId),
            row.names = F, append = F
  )
}


######### FUNCTIONS TO COMPUTE DISTRIBUTIONS OF EACH METRIC (BEGIN) ############################################
# DEPRECATED
# getting power consumption per an X interval of time doesn't
# provide accurate information about what nodes consume per broadcast session
#getPowerConsumption <- function(ds, algo, timeLine) {
#  nRow <- length( ds[[1]] )
#  nCol <- 1 + length( ds )
#  headers <- paste("", timeLine, sep="")
#  df <- as.data.frame(matrix(seq(nRow*nCol), nrow=nRow, ncol=nCol))
#  names(df) <- c("Algorithm", headers)
#  for (i in 1:nRow) {
#    tmp <- c(algo)
#    for (j in 1:length( ds )) {
#      v <- ds[[j]][i]
#      tmp <- c(tmp, v)
#    }
#    df[i,] <- tmp
#  }
#  df
#}

getNumberOfRelays <- function(msgDs, algo) {
  # create a separate list for each msg_sent vector
  list_of_sent <- lapply(msgDs$vectors$resultkey, function(p) subset(msgDs$vectordata, resultkey == p))

  # recover list of msg id
  id_msgs <- msgDs$vectordata[[4]][!duplicated(msgDs$vectordata[[4]])]
  nRow <- 1
  nCol <- 1 + length( id_msgs )
  headers <- paste("B", id_msgs, sep="")
  df <- as.data.frame(matrix(seq(nRow*nCol), nrow=nRow, ncol=nCol))
  names(df) <- c("Algorithm", headers)
  x <- sapply(id_msgs, function(id) { sum( sapply(list_of_sent, function(d) id %in% d$y ) ) } )
  x <- c(algo, x)
  df[1,] <- x
  df
}

getDuplicatedMsgs <- function(msgDs, broDs, algo){
  # create a separate list for each broadcast_msg_received vector
  list_of_received <- lapply(broDs$vectors$resultkey, function(p) subset(broDs$vectordata, resultkey == p))
  # recover list of msg id
  id_msgs <- msgDs$vectordata[[4]][!duplicated(msgDs$vectordata[[4]])]
  tmp <- lapply(id_msgs, function(id){
    lapply(list_of_received, function(v){
      id==v$y
    })
  })

  nRow <- length(tmp[[1]])
  nCol <- 1 + length( id_msgs )
  headers <- paste("B", id_msgs, sep="")
  df <- as.data.frame(matrix(seq(nRow*nCol), nrow=nRow, ncol=nCol))
  names(df) <- c("Algorithm", headers)
  for (i in 1:nRow) {
    x <- c(algo)
    for (j in 1:length( id_msgs )) {
      t <- tmp[[j]][[i]]
      x <- c(x, sum( t == TRUE))
    }
    df[i,] <- x
  }
  df
}

getBroadcastingTime <- function(msgDs, broDs, algo) {
  # create a separate list for each msg_sent vector
  list_of_sent <- lapply(msgDs$vectors$resultkey, function(p) subset(msgDs$vectordata, resultkey == p))

  # recover list of msg id
  id_msgs <- msgDs$vectordata[[4]][!duplicated(msgDs$vectordata[[4]])]

  # create a separate list for each broadcast_msg_received vector
  list_of_received <- lapply(broDs$vectors$resultkey, function(p) subset(broDs$vectordata, resultkey == p))

  sending.time <- sapply(id_msgs, function(id) min( unlist(lapply(list_of_sent, function(d)  subset(d, y == id, select=c(x))[[1]] )) ) )

  l.recp <- lapply(id_msgs, function (id) {
    lapply(list_of_received, function(r) {
      max(r[r$y == id,]$x)
    })
  })

  nRow <- length( l.recp[[1]] )
  nCol <- 1 + length( l.recp )
  headers <- paste("B", id_msgs, sep="")
  df <- as.data.frame(matrix(seq(nRow*nCol), nrow=nRow, ncol=nCol))
  names(df) <- c("Algorithm", headers)
  for (i in 1:nRow) {
    tmp <- c(algo)
    for (j in 1:length( l.recp )) {
      tmp <- c(tmp, (l.recp[[j]][[i]] - sending.time[j])*1000)
    }
  df[i,] <- tmp
  }
  df
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

getRcvOrSentBroadcastMessagesPerSession = function(ds, algo) {
  nodes <- ds$resultkey[!duplicated(ds$resultkey)]
  sess  <- ds$y[!duplicated(ds$y)]
  nRow <- length(nodes)
  nCol <- length(sess) + 1
  df <- as.data.frame(matrix(seq(nRow*nCol), nrow=nRow, ncol=nCol))
  names(df) <- c("Algorithm", paste("B", 1:(nCol - 1), sep="") )
  for (i in 1:nRow) {
    values <- c(vector(), algo)
    for (j in 2:nCol - 1) {# why 2 ??
      msgs <- subset(ds, y == j)
      values <- c(values, length(msgs$y))
    }
    df[i, ] <- values
  }
  df
}

getPowerConsumptionPerBroadcastSession = function(powerConDs, sentMsgsDs, rcvMsgsDs, algo, step){
  nodes <- rcvMsgsDs$resultkey[!duplicated(rcvMsgsDs$resultkey)]
  broadcastSessions <- sentMsgsDs$y[!duplicated(sentMsgsDs$y)]
  battConByNode <- lapply(nodes, function(n){
    subset(powerConDs, resultkey==n)
  })
  nRow <- length(nodes)
  nCol <- length(broadcastSessions) + 1
  df <- as.data.frame(matrix(seq(nRow*nCol), nrow=nRow, ncol=nCol))
  names(df) <- c("Algorithm", paste("B", 1:(nCol - 1), sep="") )
  rowNumber <- 1
  for (i in 1:length(nodes)) {
    vCpy <- c(vector(), battConByNode[[i]]$y)
    vCpy[ length(vCpy) ] <- NA
    vCpy <- vCpy[!is.na(vCpy)]
    vCpy <- c(0.0, vCpy)
    battConByNode[[i]]$y <- battConByNode[[i]]$y * (-1.0) - vCpy * (-1.0)
    nodeBatCon <- battConByNode[[i]]
    values <- c(vector(), algo)
    for (j in 1:length(broadcastSessions)) {
      if (j == 1){
        limInf <- 0
        #NOTE: be sure that peers must start broadcasting after two steps
        inte <- step*2
      } else {
        limInf <- inte
        inte <- inte + step
      }
      consumpPerSession <- subset(subset(nodeBatCon, x > limInf), x <= inte)
      totalConsump <- sum( (consumpPerSession$y) )
      values <- c(values, totalConsump)
    }
    df[i, ] <- values
  }
  df
}

getCoveragePerBroadcastSession = function(broInfo, algo, nodes) {
  sess <- length(broInfo$id)
  nCol <- sess + 1
  df <- as.data.frame(matrix(seq(nCol), nrow=1, ncol=nCol))
  names(df) <- c("Algorithm", paste("B", 1:(nCol - 1), sep="") )
  values <- c(vector(), algo)
  for (i in 1:sess){
    values <- c(values, broInfo$n.received[i]/nodes*100)
  }
  df[1, ] <- values
  df
}
#getPowerConsumptionPerBroadcastSession = function(powerConDs, sentMsgsDs, rcvMsgsDs, algo){
#  nodes <- rcvMsgsDs$resultkey[!duplicated(rcvMsgsDs$resultkey)]
#  broadcastSessions <- sentMsgsDs$y[!duplicated(sentMsgsDs$y)]
#  recTimes <- getRecOrTraTimeByNode_Session(sentMsgsDs, nodes, broadcastSessions)
#  traTimes <- getRecOrTraTimeByNode_Session(rcvMsgsDs,  nodes, broadcastSessions)
#  battConByNode <- lapply(nodes, function(n){
#    subset(powerConDs, resultkey==n)
#  })
#  nRow <- length(nodes)
#  nCol <- length(broadcastSessions) + 1
#  df <- as.data.frame(matrix(seq(nRow*nCol), nrow=nRow, ncol=nCol))
#  names(df) <- c("Algorithm", paste("B", 1:(nCol - 1), sep="") )
#  rowNumber <- 1
#  for (i in 1:length(nodes)) {
#    values <- c(algo)
#    eventsVector <- vector()
#    nodeBatCon <- battConByNode[[i]]
#    for (j in 1:length(broadcastSessions)) {
#      m <- max(c(recTimes[[i]][[j]], traTimes[[i]][[j]]))
#      consumpPerSession <- subset(subset(nodeBatCon, x<=m), !(eventno %in% eventsVector) )
#      eventsVector <- c(eventsVector, consumpPerSession$eventno)
#      totalConsump <- sum( (consumpPerSession$y) * (-1.0) )
#      values <- c(values, totalConsump)
#    }
#    df[i, ] <- values
#  }
#  df
#}
######### FUNCTIONS TO COMPUTE DISTRIBUTIONS OF EACH METRIC (END) ############################################

plot.charts.for.single.experiment <- function(power.level, broadcast.info, ts = seq(step, max, by=step), max, step=30) {

  nr.nodes <- max(sapply(power.level, function(p) length(p)))
  n <- length(broadcast.info$id) # number of broadcast messages

  valid.time <- broadcast.info$time[broadcast.info$time <= max ]
  if (length(valid.time) == 0) {
  	valid.time <- broadcast.info$time
  }
  plot(ecdf(valid.time * 1000), xlab="Time (ms)", main="ECDF of maximal reception delay")
  hist(valid.time, xlab="Maximal reception delay (Seconds)", main="Maximal reception delay")

  plot(broadcast.info$B.i / broadcast.info$n.received, type="l", col="blue", xlab="Broadcast Session",
    ylab="n/B.i", main="Mean of Duplicated Messages ?")

  #plot(broadcast.info$B.i / broadcast.info$n.received,
  #     type="l", col="blue", xlab="Broadcast Session", ylab="n/B.i", main="Mean of Duplicated Messages ?",
  #     ylim=c(1, 3)
  #)

  plot(broadcast.info$n.received/nr.nodes*100, type="l", col="blue", xlab="Session Id", ylab="Coverage (%)", main="Coverage")

  # nr.dead.nodes <- apply(power.level, 2, function(e) length(e[e == 0]) )
  #nr.dead.nodes <- apply(power.level, 2, function(e) 0 )

  plot(y=broadcast.info$n.received/nr.nodes*100,
  	 x = broadcast.info$sending ,
  	 type="l",
  	 col="blue",
  	 xlab="Sending Time (Seconds) of each session",
  	 ylab="Coverage (%)",
  	 main="Coverage per session Id"
  	)

  #print(nr.dead.nodes)

  # TODO: PLOT THIS USING LINES

  #plot(x = ts, y = nr.dead.nodes*100.0/nr.nodes, type="l", main="Dead Nodes")

  boxplot(power.level, names = sapply(ts, function(x) { paste("", x, sep="") }) )

  #boxplot(
  #  power.level, names = sapply(ts, function(x) paste("", x, sep="") ),
  #  main="Distribution of power consumption", xlab="Time (s)", ylab="Joules (watt-s)"
  #)

}


average.values <- function(pl, broadcast.info, max) {

	nr.nodes <- max(sapply(pl, function(p) length(p)))
	n <- length(broadcast.info$id) # number of broadcast messages

	c  <- sum(broadcast.info$n.received/nr.nodes*100)/n

	valid.time <- broadcast.info$time[broadcast.info$time <= max ]
	bt <- sum(valid.time, na.rm=TRUE)/length(valid.time)

	pc <- unlist(lapply(pl, sum))/nr.nodes

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
  msg_freq, trans_range, sent_msgs){
  
  x_positions <- replace.resultkey.with.node_id(
    results_file, "name(node_position_x:vector)"
  )
  y_positions <- replace.resultkey.with.node_id(
    results_file, "name(node_position_y:vector)"
  )
  
  node_ids <- unique(
    replace.resultkey.with.node_id(
      results_file, "name(density_approximation:vector)"
    )$node_id
  )
  msgs_ids <- unique(sent_msgs$value)

  density_ground_truth <- sapply(msgs_ids, function(msg){
    # get point in time where nodes' positions were reported
    time <- first_measure + msg_freq * (msg - 1)
    # create the graph with the position of each node
    g <- get.graph(time, trans_range, x_positions, y_positions)
    sapply(node_ids, function(node_id){
      node_neigs <- g[node_id, ]
      length(node_neigs[node_neigs != 0])
    })
  })
  
  sapply(1:nrow(density_ground_truth), function(r){
    sum(density_ground_truth[r, 1]) / length(density_ground_truth[r, ])
  })

}

compute.relative.error.in.density <- function(results_file, first_measure,
  msg_freq, trans_range, sent_msgs){
  
  x_positions <- replace.resultkey.with.node_id(
    results_file, "name(node_position_x:vector)"
  )
  y_positions <- replace.resultkey.with.node_id(
    results_file, "name(node_position_y:vector)"
  )
  measured_density <- replace.resultkey.with.node_id(
    results_file, "name(density_approximation:vector)"
  )
  
  node_ids <- unique(measured_density$node_id)
  msgs_ids <- unique(sent_msgs$value)

  density_approx <- sapply(msgs_ids, function(msg){
    # get point in time where nodes' positions were reported
    time <- first_measure + msg_freq * (msg - 1)

    indx_per_time <- measured_density[abs(measured_density$time - time) < TOLERANCE, ]

    sapply(node_ids, function(node_id){
      indx_per_time[indx_per_time$node_id == node_id, ]$value
    })
  })
  
  density_ground_truth <- sapply(msgs_ids, function(msg){

    # get point in time where nodes' positions were reported
    time <- first_measure + msg_freq * (msg - 1)
    # create the graph with the position of each node
    g <- get.graph(time, trans_range, x_positions, y_positions)
    sapply(node_ids, function(node_id){
      node_neigs <- g[node_id, ]
      length(node_neigs[node_neigs != 0])
    })
  })

  absolute_err <- abs(density_approx - density_ground_truth)

  #relative error with vectors
  relative_err <- sapply(1:nrow(absolute_err), function(r){
    max(absolute_err[r, ]) / max( density_ground_truth[r, ] )
  })
  print(relative_err)
  relative_err
#  final.data <- lapply(all.data, function(d) {
#  	ttt <- function(radious, x, y, d) {
#  		length(d[((d$x-x)*(d$x-x) + (d$y-y)*(d$y-y)) < radious*radious,]$node)
#  	}
#  	expected.density<- sapply(nodes, function(n) {
#  		x <- d[d$node == n,]$x[1]
#  		y <- d[d$node == n,]$y[1]
#  		ttt(20, x, y, d)
#  	})
#
#  	data.frame(node=d$node, t=d$t, observed.density=d$d, expected.density=expected.density)
#  })
#
#  sapply(final.data, function(d) {
#  	o <- d$observed.density
#  	e <- d$expected.density
#  	diff <- e - o
#  	n_diff <- norm(as.matrix(diff), type="F")
#  	n_e <- norm(as.matrix(e), type="F")
#  	n_diff/n_e
#  })

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
  
  graph( edges=tmp, n=length(nodes))

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

      colors <- sapply(1:length(V(g)), function(v){
        ifelse(v %in% senders, "orange", "red")
      })
      V(g)$color <- colors
      name <- paste(
        paste(
          paste("GraphForMsg_", msg, sep=""), 
            is_connected(g), sep="_"), 
      "pdf", sep=".")
      pdf(name)
      plot(g)
      dev.off()

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

# TODO: coverage (percentage of nodes that receive a message per broadcast session) (this depends on many experiments, it is partially done in one of the functions)
# 			- we can aggregate this in many ways
#					1. chart of broadcast session and coverage (one curve per protocol). this one is only useful to compare protocols using the same topology
#					2. I (Inti) think that we can also compute the complete coverage in the experiments (all sessions together) and plot a single value per experiment in a chart. This is the one I explained before.
# TODO: total power consumption in one experiment
# TODO: chart of power consumption in many experiments (depends on the previous one)

main <- function(args) {
  print(paste("Simulation time", args$simTime, "seconds"))

  #TODO find a way to adapt this parameter in an automatic way
  pl.step <- args$step
  # mandatory behavior

  print("Reading vectors with messages sent and received")
  sent_msgs <- load.datafile(args$file, "name(msg_sent:vector)" )
  recv_msgs <- load.datafile(args$file, "name(broadcast_msg_received:vector)" )

  print("DONE!")

  print("Get the distribution of density")
  density_dist <- get.density.distribution(
    args$file,
    args$first_time_of_measuring_nodes_position,
    args$step,
    args$transmission_range,
    replace.resultkey.with.node_id(args$file, "name(msg_sent:vector)")
  )
  print("DONE!")
  
  print("Computing observed and expected densities")
  density.relative.errors <- compute.relative.error.in.density(
    args$file,
    args$first_time_of_measuring_nodes_position,
    args$step,
    args$transmission_range,
    replace.resultkey.with.node_id(args$file, "name(msg_sent:vector)")
  )
  print("DONE!")
  
  print("Computing relative error of collisions")
  collisions_re <- collisions.relative.error(
    args$file,
    args$first_time_of_measuring_nodes_position,
    args$step,
    args$transmission_range,
    replace.resultkey.with.node_id(args$file, "name(msg_sent:vector)"),
    replace.resultkey.with.node_id(args$file, "name(broadcast_msg_received:vector)")
  )
  print(collisions_re)
  print("DONE!")

  print(paste("Loading power consumption data file:", args$file))
  powerLevelDs <- load.datafile(args$file, "name(residualCapacity:vector)")
  pl.local <- powerlevels3( powerLevelDs, max= args$simTime, step=pl.step)
  print("DONE!")

  print(paste("Loading MAC frame data file:", args$file))
  mac.frames.sent <- load.datafile.scalar(args$file, "name(nbTxFrames)")
  mac.frames.received <- load.datafile.scalar(args$file, "name(nbRxFrames)")
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

  print("Computing maximal reception delay")
  bs <- broadcastingTime(sent_msgs, recv_msgs, simulation.time = args$simTime)
  print("DONE!")

  print("Collecting information on number of duplicated messages")
	dm <- collect.duplicated.messages(sent_msgs, recv_msgs, simulation.time = args$simTime)

  print("Exporting data")
  save.power.level(pl.local, args$outputPath, args$configuration, median.density.per.node)
  save.delay.time(bs, args$simTime, args$outputPath, args$configuration)
  save.number.of.relays(bs, args$simTime, args$outputPath, args$configuration)
  save.coverage(bs, args$simTime, args$outputPath, args$configuration)

  save.density.relative.errors(density.relative.errors, args$outputPath, args$configuration)

  save.density.distribution(density_dist, args$outputPath, args$configuration)
 
  save.duplicated.messages(dm, args$outputPath, args$configuration)
  save.collisions.relative.error(collisions_re, args$outputPath, args$configuration)
  save.mac.frames.sent(mac.frames.sent, args$outputPath, args$configuration, median.density.per.node)
  save.mac.frames.received(mac.frames.received, args$outputPath, args$configuration, median.density.per.node)
  # export.data.of.experiment(args$configuration, bs, args$simTime, args$outputPath)

  # optional behavior

  if (args$timeOfPowerLevels) {
    print("Ohhh ... this is a debug session. Ok, reading time of power levels")
    time.pl <- time.of.powerlevels( powerLevelDs, max= args$simTime, step=pl.step)
    save.time.of.power.level(time.pl, args$outputPath, args$configuration)
  }

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

  if (args$exportForRaziel) {
    print("Computing distributions of each metric...")
    pcoDist <- getPowerConsumptionPerBroadcastSession(
      powerLevelDs$vectordata,
      sent_msgs$vectordata,
      recv_msgs$vectordata,
      args$algorithm, pl.step
    )
    #pcoDist <- getPowerConsumption(pl.local, args$algorithm, seq(pl.step, args$simTime, by=pl.step))
    relDist <- getNumberOfRelays(sent_msgs, args$algorithm)
    dupDist <- getDuplicatedMsgs(sent_msgs, recv_msgs, args$algorithm)
    broDist <- getBroadcastingTime(sent_msgs, recv_msgs, args$algorithm)
    nodes   <- max(sapply(pl.local, function(p) length(p)))
    netCove <- getCoveragePerBroadcastSession(bs, args$algorithm, nodes)
    sentMsg <- getRcvOrSentBroadcastMessagesPerSession(sent_msgs$vectordata, args$algorithm)
    rcvdMsg <- getRcvOrSentBroadcastMessagesPerSession(recv_msgs$vectordata, args$algorithm)
    print("DONE")

    print("Exporting distributions of metrics...")
    filename <- build.filename(args$outputPath, "batteryConsumption", args$density_as_string, seP="_")
    exportDataset(pcoDist, filename)

    filename <- build.filename(args$outputPath, "numberOfRelays", args$density_as_string, seP="_")
    exportDataset(relDist, filename)

    filename <- build.filename(args$outputPath, "duplicatedMsgs", args$density_as_string, seP="_")
    exportDataset(dupDist, filename)

    filename <- build.filename(args$outputPath, "broadcastSessionTime", args$density_as_string, seP="_")
    exportDataset(broDist, filename)

    filename <- build.filename(args$outputPath, "networkCoverage", args$density_as_string, seP="_")
    exportDataset(netCove, filename)

    filename <- build.filename(args$outputPath, "sentMsgs", args$density_as_string, seP="_")
    exportDataset(sentMsg, filename)

    filename <- build.filename(args$outputPath, "rcvdMsgs", args$density_as_string, seP="_")
    exportDataset(rcvdMsg, filename)
    print("DONE")
  }

  if (args$plot) {
    print("Plotting :-P")
    id <- paste(args$algorithm, args$density_as_string, sep="-")
    pdf( build.filename(args$outputPath, "IndividualPlots", id) )
    plot.charts.for.single.experiment(pl.local, bs, max = args$simTime, step=pl.step)
  }

  if (args$showAverages) {
    print("Printing average values")
    averages <- average.values(pl.local, bs, max=args$simTime)
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
