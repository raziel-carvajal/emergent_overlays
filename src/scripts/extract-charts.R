require('omnetpp')
library(argparse)

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
  parser$add_argument('step', metavar='step', type="integer",
                      help='Every broadcasting metric as function of time will use this value as xtics to be plotted')
  parser$add_argument('-a','--algorithm', dest='algorithm', type="character",
                      help='Algorithm used')
  parser$add_argument('-d', '--density', metavar='density', type="integer",
                      help='Density of the topology used')
  parser$add_argument('-ds', '--density-as-string', metavar='density_string', type="character",
                      help='Density of the topology used as string')
  parser$add_argument('-mf', '--mapping-file', metavar='mapping_file', type="character",
                      help='File with two columns, NodeId and the protocol ID that runs on that node')
  parser$add_argument('--radio-mode', dest='computeRadioMode', action="store_true",
                      help='Computing the time spent in each radio mode (a debug only option)')
  parser$add_argument('--save-time-power-level', dest='timeOfPowerLevels', action="store_true",
                      help='Compute and save the time last time each node updates its power consumption (a debug only option)')
  parser$add_argument('--export-data-for-raziel', dest='exportForRaziel', action="store_true",
                      help='This option will probably become the default as soon as we fixed the other scripts')

  parser$add_argument('--plot', dest='plot', action="store_true",
                      help='When this flag is specified, a pdf file with the name of the configuration is generared. The file contains a bunch of charts.')

  parser$add_argument('--show-averages', dest='showAverages', action="store_true",
                      help='Show the average of all the metrics')

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
  #print(list_of_sent)
  #print(msgDs)
  #data.frame(x=ds$vectors[5], y=ds$vectors[1])
  #splitted <- strsplit(as.character(df$module), ".", fixed=T)
  #r <- unlist(lapply(splitted, function(x){ x[2] }))
  #n <- data.frame(nodeId=r, vectorId=df$resultkey)

  # recover list of msg id
  id_msgs <- msgDs$vectordata[[4]][!duplicated(msgDs$vectordata[[4]])]
  #print("feo")
  #print(id_msgs)

  # create a separate list for each broadcast_msg_received vector
  list_of_received <- lapply(broDs$vectors$resultkey, function(p) subset(broDs$vectordata, resultkey == p))
  #print("feo2")
  #print(list_of_received)

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

  #print(l.recp)
  #print(sending.time)

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

collect.duplicated.messages <- function(msgDs, broDs, simulation.time, mapNodeAlgoId=NULL) {
  df <- data.frame(module=broDs$vectors[5], resultkey=broDs$vectors[1])
  splitted <- strsplit(as.character(df$module), ".", fixed=T)
  r <- unlist(lapply(splitted, function(x){ x[2] }))
  n <- data.frame(nodeId=r, resultkey=df$resultkey)
  
  # create a separate list for each msg_sent vector
  list_of_sent <- lapply(msgDs$vectors$resultkey, function(p) subset(msgDs$vectordata, resultkey == p))
 
  # recover list of msg id
  id_msgs <- msgDs$vectordata[[4]][!duplicated(msgDs$vectordata[[4]])]

  if (!is.null(mapNodeAlgoId)) {
    names(mapNodeAlgoId) <- c("nodeId", "protocolId")
    mr <- merge(n,mapNodeAlgoId)
    # create a separate list for each broadcast_msg_received vector
    list_of_received <- lapply(broDs$vectors$resultkey, function(p){
                             t <- subset(broDs$vectordata, resultkey == p)
                             merge(t, mr)
    })
  } else {
    # create a separate list for each broadcast_msg_received vector
    list_of_received <- lapply(broDs$vectors$resultkey, function(p){
                             t <- subset(broDs$vectordata, resultkey == p)
                             t$protocolId <- c(rep("", length(t$resultkey)))
                             t
    })

  }
  l.recp <- lapply(id_msgs, function (id) {
    tmp.list <- lapply(list_of_received, function(d){
     #data.frame(t=d[d$y == id,]$x, protocolId=d[d$y == id,]$protocolId)
     d[d$y == id,]$protocolId
    })
    data.frame(dm = sapply(tmp.list, function(d) length(d)), protocolId=sapply(tmp.list, function(d) unique(d)) )
  })

  do.call("rbind", l.recp)
}

powerlevels3 <- function(ds, ts = seq(step, max, by=step), max, step=30, mapNodeAlgoId=NULL) {
  # create a separate list for each power level
  others <- lapply(ds$vectors$resultkey, function(p) subset(ds$vectordata, resultkey==p) )
  # vector of power levels for each instant of time
  df <- data.frame(module=ds$vectors[5], resultkey=ds$vectors[1])
  splitted <- strsplit(as.character(df$module), ".", fixed=T)
  r <- unlist(lapply(splitted, function(x){ x[2] }))
  n <- data.frame(nodeId=r, vectorId=df$resultkey)
  vId <- unlist(lapply(others, function(x) tail(x$resultkey,1)))
  if (!is.null(mapNodeAlgoId)) {
    names(mapNodeAlgoId) <- c("nodeId", "protocolId")
    mr <- merge(n,mapNodeAlgoId)
    r <- lapply(ts, function(t)  {
      z <- lapply(others, function(s) {
        a <- tail(s[s$x <= t,], 1)
        data.frame(y=a$y, vectorId=a$resultkey)
      })
      merge(do.call("rbind", z), mr)
    })
  } else {
    r <- lapply(ts, function(t)  {
      z <- lapply(others, function(s) {
        a <- tail(s[s$x <= t,], 1)
        data.frame(y=a$y, vectorId=a$resultkey)
      })
      w <- do.call("rbind", z)
      w$protocolId <- c(rep("", length(w$y)))
      w
    })
  }
  t <- lapply(r, function(r1) data.frame(y=r1$y, protocolId=r1$protocolId))
  t
}

save.duplicated.messages <- function(data, outputPath, expeId){
  dm <- data$dm[data$dm > 0] # only data from nodes that received the messages
  df <- data.frame( whatever = dm)
  u <- unique(data$protocolId)
  lapply(u, function(protocol){
    df <- subset(data, protocolId == protocol)
    name <- gsub('[_]', '', protocol)
    dupMsgs <- data.frame(wathever=df$dm)
    colnames(dupMsgs) <- c(paste(expeId, name, sep=""))
    write.table(
      dupMsgs,
      file = build.filename(outputPath, "duplicatedMsgsDistribution", expeId),
      row.names = F, append = T
    )
  })
}


save.power.level <- function(power.level, outputPath, expeId){
  pl <- power.level[lapply(power.level, length) > 0]
  taR <- tail(pl, 1)[[1]]
  u <- unique(taR$protocolId)
  lapply(u, function(protocol) {
    df <- subset(taR, protocolId == protocol)
    powerLevelInfo <- data.frame( whatever = -1*as.numeric(unlist(c(df$y))) )
    name <- gsub('[_]', '', protocol)
    colnames(powerLevelInfo) <- c(paste(expeId, name, sep=""))
    write.table(
              powerLevelInfo,
              file = build.filename(outputPath, "batteryConsumptionDistribution", expeId),
              row.names = F, append = T
    )
  })
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
        tmp.list <- lapply(pl, function(i) i$y)
	pc <- unlist(lapply(tmp.list, sum))/nr.nodes

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
  if (!is.null(args$mapping_file)) {
      mapNodeAlgoId <- read.table(args$mapping_file)
  } else {
    mapNodeAlgoId <- NULL
  }

  # mandatory behavior

  print("Reading vectors with messages sent and received")
  msgSentDs <- load.datafile(args$file, "name(msg_sent:vector)" )
  msgRcvDs <- load.datafile(args$file, "name(broadcast_msg_received:vector)" )

  print("DONE!")

  print(paste("Loading power consumption data file:", args$file))
  powerLevelDs <- load.datafile(args$file, "name(residualCapacity:vector)")

  pl.local <- powerlevels3( powerLevelDs, max= args$simTime, step=pl.step, mapNodeAlgoId=mapNodeAlgoId)
  print("DONE!")


  print("Computing maximal reception delay")
  bs <- broadcastingTime(msgSentDs, msgRcvDs, simulation.time = args$simTime)
  print("DONE!")

  print("Collecting information on number of duplicated messages")
  dm <- collect.duplicated.messages(msgSentDs, msgRcvDs, simulation.time = args$simTime, mapNodeAlgoId=mapNodeAlgoId)
  print("Exporting data")
  save.power.level(pl.local, args$outputPath, args$configuration)
  # stop()
  save.delay.time(bs, args$simTime, args$outputPath, args$configuration)
  save.number.of.relays(bs, args$simTime, args$outputPath, args$configuration)
  save.coverage(bs, args$simTime, args$outputPath, args$configuration)
  # FIXME:
  save.duplicated.messages(dm, args$outputPath, args$configuration)
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
    r <- countMsgsPerRadioMode(rcvM, msgRcvDs, args$algorithm)
    filename <- build.filename(args$outputPath, "RadioModeReception", args$density)
    exportDataset(r, filename)
  }

  if (args$exportForRaziel) {
    print("Computing distributions of each metric...")
    pcoDist <- getPowerConsumptionPerBroadcastSession(
      powerLevelDs$vectordata,
      msgSentDs$vectordata,
      msgRcvDs$vectordata,
      args$algorithm, pl.step
    )
    #pcoDist <- getPowerConsumption(pl.local, args$algorithm, seq(pl.step, args$simTime, by=pl.step))
    relDist <- getNumberOfRelays(msgSentDs, args$algorithm)
    dupDist <- getDuplicatedMsgs(msgSentDs, msgRcvDs, args$algorithm)
    broDist <- getBroadcastingTime(msgSentDs, msgRcvDs, args$algorithm)
    nodes   <- max(sapply(pl.local, function(p) length(p)))
    netCove <- getCoveragePerBroadcastSession(bs, args$algorithm, nodes)
    sentMsg <- getRcvOrSentBroadcastMessagesPerSession(msgSentDs$vectordata, args$algorithm)
    rcvdMsg <- getRcvOrSentBroadcastMessagesPerSession(msgRcvDs$vectordata, args$algorithm)
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
