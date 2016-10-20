require('omnetpp')
library(argparse)
#library(data.table)


load.datafile <- function(fname, query, extensions=c("sca", "vec")) {
  ds <- loadVectors(loadDataset(paste(fname, sep= ".", extensions), add(type="vector", select=query) ), NULL)
}


powerlevels3 <- function(ds, ts = seq(step, max, by=step), max, step=30) {
	# create a separate list for each power level
	others <- lapply(ds$vectors$resultkey, function(p) subset(ds$vectordata, resultkey==p) )
	# vector of power levels for each instant of time
	lapply(lapply(ts, function(t)  lapply(others, function(s) tail(s[s$x <= t,]$y, 1) ) ), unlist)
}


time.of.powerlevels <- function(ds, ts = seq(step, max, by=step), max, step=30) {
	# create a separate list for each power level
	others <- lapply(ds$vectors$resultkey, function(p) subset(ds$vectordata, resultkey==p) )
	# vector of power levels for each instant of time
	lapply(lapply(ts, function(t)  lapply(others, function(s) tail(s[s$x <= t,]$x, 1) ) ), unlist)
}

### FUNCTIONS TO COMPUTE DISTRIBUTIONS OF EACH METRIC ###
getPowerConsumption <- function(ds, algo, timeLine) {
	nRow <- length( ds[[1]] )
	nCol <- 1 + length( ds )
	headers <- paste("", timeLine, sep="")
	df <- as.data.frame(matrix(seq(nRow*nCol), nrow=nRow, ncol=nCol))
	names(df) <- c("Algorithm", headers)
	for (i in 1:nRow) {
		tmp <- c(algo)
		for (j in 1:length( ds )) {
      v <- ds[[j]][i]
			tmp <- c(tmp, v)
		}
		df[i,] <- tmp
	}
	df
}

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

# Rscript extract-charts.R ../../experiments/configs/results/SmallTestFlooding-0 ../../results 15 CDS Zero
countMsgsPerRadioMode <- function(radioModeDs, msgsDs, algo){
  keys <- subset(msgsDs$vectordata, !duplicated(resultkey))$resultkey
  headers <- vector()
  for (i in 1:length(keys)) {
    a <- subset(radioModeDs, resultkey == keys[i])
    tmp <- subset(msgsDs$vectordata, resultkey == keys[i])
    for (j in 1:length(tmp$resultkey)) {
      v <- tmp[j, ]
      t <- nrow( subset(a, x <= v$x) )
      if (NA %in% headers[t]) {
        headers <- c(headers, t)
      }
    }
  }
  headers <- c(headers, "Algorithm")
  nRow <- length(keys)
  nCol <- length(headers)
  r <- as.data.frame(matrix(0, nrow=nRow, ncol=nCol))
  names(r) <- headers
  for (i in 1:length(keys)) {
    a <- subset(radioModeDs, resultkey == keys[i])
    tmp <- subset(msgsDs$vectordata, resultkey == keys[i])
    for (j in 1:length(tmp$resultkey)) {
      v <- tmp[j, ]
      t <- nrow( subset(a, x <= v$x) )
      r[i, t] <- r[i, t] + 1
    }
  }
  r[,"Algorithm"] = algo
  r
}
### END ###


plot.charts.for.single.experiment <- function(power.level, broadcast.info, ts = seq(step, max, by=step), max, step=30) {

	nr.nodes <- max(sapply(power.level, function(p) length(p)))
	n <- length(broadcast.info$id) # number of broadcast messages

	valid.time <- broadcast.info$time[broadcast.info$time <= max ]
	if (length(valid.time) == 0) {
		valid.time <- broadcast.info$time
	}
	plot(ecdf(valid.time * 1000), xlab="Time (ms)", main="ECDF of maximal reception delay")
	hist(valid.time, xlab="Maximal reception delay (Seconds)", main="Maximal reception delay")

  plot(broadcast.info$B.i / broadcast.info$n.received, type="l", col="blue", xlab="Broadcast Session", ylab="n/B.i", main="Mean of Duplicated Messages ?")

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

	print(ts)
	#print(nr.dead.nodes)

	# TODO: PLOT THIS USING LINES

	#plot(x = ts, y = nr.dead.nodes*100.0/nr.nodes, type="l", main="Dead Nodes")

        boxplot(power.level, names = sapply(ts, function(x) paste("", x, sep="")  ) )
	#boxplot(
        #  power.level, names = sapply(ts, function(x) paste("", x, sep="") ),
        #  main="Distribution of power consumption", xlab="Time (s)", ylab="Joules (watt-s)", ylim=c(49, 50)
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

	tail(data.frame(
		coverage = c,
		broadcasting.time = bt,
		power_consumption = pc,
		duplicated_messages = dm,
		retransmitted_messages = rt
	),1)
}


exportDataset <- function(ds, dst){
	if (!file.exists(dst)) write.table(ds, file = dst, col.names = T, row.names = F, append = F, sep=",")
	else write.table(ds, file = dst, col.names = F, row.names = F, append = T, sep=",")
}


build.filename <- function(path, filename, density) {
  filename <- paste(path, filename, sep="/")
  paste(filename, density, sep="-")
}


# TODO: coverage (percentage of nodes that receive a message per broadcast session) (this depends on many experiments, it is partially done in one of the functions)
# 			- we can aggregate this in many ways
#					1. chart of broadcast session and coverage (one curve per protocol). this one is only useful to compare protocols using the same topology
#					2. I (Inti) think that we can also compute the complete coverage in the experiments (all sessions together) and plot a single value per experiment in a chart. This is the one I explained before.
# TODO: total power consumption in one experiment
# TODO: chart of power consumption in many experiments (depends on the previous one)


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
                      help='Simulation time')
  parser$add_argument('configuration', metavar='configuration', type="character",
                      help='Name of the configuration')
  parser$add_argument('-a','--algorithm', dest='algorithm', type="character",
                      help='Algorithm used')
  parser$add_argument('-d', '--density', metavar='density', type="integer",
                      help='Density of the topology used')
  parser$add_argument('-rm', '--radio-mode', dest='computeRadioMode', action="store_true",
                      help='Computing the time spent in each radio mode is a debug only option')

  # parser$print_help()
  parser$parse_args()
}


args = get.arguments()

print(paste("Simulation time", args$simTime, "seconds"))

#TODO find a way to adapt this parameter in an automatic way
pl.step <- 3

print("Reading vectors with messages sent and received")
msgSentDs <- load.datafile(args$file, "name(msg_sent:vector)" )
msgRcvDs <- load.datafile(args$file, "name(broadcast_msg_received:vector)" )

if (args$computeRadioMode) {
  print("Ohhh ... this is a debug session. Ok, reading radio modes")
  radioMode <- load.datafile(args$file, "name(radioMode:vector)" )
  rcvM <- subset(radioMode$vectordata, y == 2)
  trsM <- subset(radioMode$vectordata, y == 3)
  r <- countMsgsPerRadioMode(rcvM, msgRcvDs, args$algorithm)
  filename <- build.filename(args$outputPath, "RadioModeReception", args$density)
  exportDataset(r, filename)
}

print(paste("Loading power consumption data file:", args$file))
powerLevelDs <- load.datafile(args$file, "name(residualCapacity:vector)" )
#print(powerLevelDs)
#stop()

#print(msgRcvDs$vectordata)
print("Computing distributions of each metric...")
pl.local <- powerlevels3( powerLevelDs, max= args$simTime, step=pl.step)
pcoDist <- getPowerConsumption(pl.local, args$algorithm, seq(pl.step, args$simTime, by=pl.step))
relDist <- getNumberOfRelays(msgSentDs, args$algorithm)
dupDist <- getDuplicatedMsgs(msgSentDs, msgRcvDs, args$algorithm)
broDist <- getBroadcastingTime(msgSentDs, msgRcvDs, args$algorithm)

print("Exporting data...")
filename <- build.filename(args$outputPath, "batteryConsumption", args$density)
exportDataset(pcoDist, filename)

filename <- build.filename(args$outputPath, "numberOfRelays", args$density)
exportDataset(relDist, filename)

filename <- build.filename(args$outputPath, "duplicatedMsgs", args$density)
exportDataset(dupDist, filename)

filename <- build.filename(args$outputPath, "broadcastSessionTime", args$density)
exportDataset(broDist, filename)

print("END")

#print("Plotting :-P")
#plot.charts.for.single.experiment(pl.local, bs, max = args$sim.time, step=pl.step)
#print("Printing average values")
#averages <- average.values(pl.local, bs, max=args$sim.time)
#print(noquote(paste("average_values",
#				averages$coverage,
#				averages$broadcasting.time,
#				averages$power_consumption,
#				averages$duplicated_messages,
#				averages$retransmitted_messages)))
