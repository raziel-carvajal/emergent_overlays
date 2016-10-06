require('omnetpp')
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

broadcastingTime <- function(msgDs, broDs, simulation.time) {

  # create a separate list for each msg_sent vector
  list_of_sent <- lapply(msgDs$vectors$resultkey, function(p) subset(msgDs$vectordata, resultkey == p))

  # recover list of msg id
  id_msgs <- msgDs$vectordata[[4]][!duplicated(msgDs$vectordata[[4]])]

  # create a separate list for each broadcast_msg_received vector
  list_of_received <- lapply(broDs$vectors$resultkey, function(p) subset(broDs$vectordata, resultkey == p))

  sending.time <- sapply(id_msgs, function(id) min( unlist(lapply(list_of_sent, function(d)  subset(d, y == id, select=c(x))[[1]] )) ) )

  l.recp <- lapply(id_msgs, function (id) {
						tmp.list <- lapply(list_of_received, function(d)  d[d$y == id,]$x )
						l <- sapply(tmp.list, function(d)  c(d, NA)[[1]] )
						data.frame(
							reception.time = max(l),
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

export.data.of.experiment <- function(expeId, broadcast.info, max, power.level, time.of.powerlevels){

  valid.time <- broadcast.info$time[broadcast.info$time <= max ]
  valid.time <- valid.time[!is.na(valid.time)]
  if (length(valid.time) == 0) { valid.time <- broadcast.info$time }
  broSes <- valid.time * 1000

  broSes <- data.frame( whatever = broSes)
  colnames(broSes) <- c(expeId)
  write.table(
            broSes,
            file = paste("../../results/broadcastSession",expeId,sep="-"),
            row.names = FALSE,
            append = F
  )

  #n <- length(broadcast.info$id) # number of broadcast messages
  #broDupMsgs <- broadcast.info$B.i / broadcast.info$n.received
  #broDupMsgsInfo <- data.frame( whatever = c(mean(broDupMsgs), sd(broDupMsgs)) )
  #colnames(broDupMsgsInfo) <- c(expeId)
  #write.table(
  #          broDupMsgsInfo,
  #          file = paste("../../results/duplicatedMsgs", expeId,sep="-"),
  #          row.names = FALSE,
  #          append = F
  #)

  n <- length(broadcast.info$id) # number of broadcast messages
  broDupMsgs <- broadcast.info$B.i / broadcast.info$n.received
  broDupMsgsInfo <- data.frame( whatever = c(broDupMsgs) )
  colnames(broDupMsgsInfo) <- c(expeId)
  write.table(
            broDupMsgsInfo,
            file = paste("../../results/duplicatedMsgsDistribution", expeId,sep="-"),
            row.names = FALSE,
            append = F
  )

  pl <- power.level[lapply(power.level, length) > 0]
  powerLevelInfo <- data.frame( whatever = c(tail(pl, 1)) )
  colnames(powerLevelInfo) <- c(expeId)
  write.table(
            powerLevelInfo,
            file = paste("../../results/batteryConsumptionDistribution",expeId,sep="-"),
            row.names = FALSE,
            append = F
  )

  t.pl <- time.of.powerlevels[lapply(time.of.powerlevels, length) > 0]
  t.powerLevelInfo <- data.frame( whatever = c(tail(t.pl, 1)) )
  colnames(t.powerLevelInfo) <- c(expeId)
  write.table(
            t.powerLevelInfo,
            file = paste("../../results/batteryConsumptionDistributionTime",expeId,sep="-"),
            row.names = FALSE,
            append = F
  )
}

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

# TODO: coverage (percentage of nodes that receive a message per broadcast session) (this depends on many experiments, it is partially done in one of the functions)
# 			- we can aggregate this in many ways
#					1. chart of broadcast session and coverage (one curve per protocol). this one is only useful to compare protocols using the same topology
#					2. I (Inti) think that we can also compute the complete coverage in the experiments (all sessions together) and plot a single value per experiment in a chart. This is the one I explained before.
# TODO: total power consumption in one experiment
# TODO: chart of power consumption in many experiments (depends on the previous one)

args <- commandArgs(trailingOnly=TRUE)
print(args)

if (length(args) == 4) {
	sim.time <- strtoi(args[3])
  print(paste("Simulation time", sim.time, "seconds"))
	pl.step <- sim.time / 10

	print(paste("Loading data file:", args[1]))
	powerLevelDs <- load.datafile(args[1], "name(residualCapacity:vector)" )
  msgSentDs <- load.datafile(args[1], "name(msg_sent:vector)" )
  msgRcvDs <- load.datafile(args[1], "name(broadcast_msg_received:vector)" )

 	device<-pdf(paste(args[2], "charts.pdf", sep="-"), width=10, height=7)
	device

	print(paste("Creating powerlevels:", args[1]))
	pl.local <- powerlevels3( powerLevelDs, max= sim.time, step=pl.step)
	time.pl <- time.of.powerlevels( powerLevelDs, max= sim.time, step=pl.step)
	# pl <- powerlevels3(powerLevelDs, max= sim.time, step=1)

	print(paste("Creating maximal reception delay:", args[1]))
	bs <- broadcastingTime(msgSentDs, msgRcvDs, simulation.time = sim.time)

	print("Plotting :-P")
	plot.charts.for.single.experiment(pl.local, bs, max = sim.time, step=pl.step)

  print("Exporting data...")
  export.data.of.experiment(args[4], bs, max = sim.time, pl.local, time.pl)

	print("Printing average values")
	averages <- average.values(pl.local, bs, max=sim.time)
	print(noquote(paste("average_values",
					averages$coverage,
					averages$broadcasting.time,
					averages$power_consumption,
					averages$duplicated_messages,
					averages$retransmitted_messages)))
}
