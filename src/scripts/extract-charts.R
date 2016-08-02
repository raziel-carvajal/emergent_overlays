require('omnetpp')

load.datafile <- function(fname, query, extensions=c("sca", "vec")) {
  ds <- loadVectors(loadDataset(paste(fname, sep= ".", extensions), add(type="vector", select=query) ), NULL)
}

powerlevels3 <- function(ds, ts = seq(step, max, by=step), max, step=30) {
  # create a separete list for each power level
  others <- lapply(ds$vectors$resultkey, function(p) subset(ds$vectordata, resultkey==p) )
  # vector of power levels for each instant of time
  sapply(lapply(ts, function(t)  lapply(others, function(s) tail(subset(s, x<=t, select=c(y)), 1) )), unlist) 
}

broadcastingTime <- function(msgDs, broDs, simulation.time) {
  # create a separate list for each msg_sent vector
  list_of_sent <- lapply(msgDs$vectors$resultkey, function(p) subset(msgDs$vectordata, resultkey == p)) 
  # recover list of msg id
  id_msgs <- msgDs$vectordata[[4]][!duplicated(msgDs$vectordata[[4]])] 
  
  # create a separate list for each broadcast_msg_received vector
  list_of_received <- lapply(broDs$vectors$resultkey, function(p) subset(broDs$vectordata, resultkey == p))
  
  sending.time <- sapply(id_msgs, function(id) min( unlist(lapply(list_of_sent, function(d)  subset(d, y == id, select=c(x))[[1]] )) ) )
  
  reception.time <- sapply(id_msgs, function (id) max(sapply(list_of_received, function(d)  head( rbind(subset(d, y == id, select=c(x)), NA), 1 )[[1]] )) )
  #sending.time[ which(is.na(reception.time)) ] <- NA
  #sending.time <- sending.time[ !is.na(sending.time) ]
  #reception.time <- reception.time[ !is.na(reception.time) ]
  #tmp <- reception.time - sending.time
  #tmp <- tmp[!is.na(tmp)]
  #test <- reception.time - sending.time
  #test <- test[!is.na(test)]
  #print('NA indexes')
  #lapply( which(is.na(reception.time)), function(entry) replace(sending.time, sending.time[entry] , NA ) )
  #print(sending.time)
  
  # compute number of message received at each location (coverage)
  rcv <- sapply(id_msgs, function(id) { sum( sapply(list_of_received, function(d) id %in% d$y ) ) } )
  
  # compute number of message sent at each location (retransmission)
  sent <- sapply(id_msgs, function(id) { sum( sapply(list_of_sent, function(d) id %in% d$y ) ) } )
  
  # compute number of message received per broadcast session
  B.i.tmp <- sapply(id_msgs, function(id) sum(sapply(list_of_received, function(d) length(subset(d, y == id, select=c(y))[[1]]) )))
  
  broadcasting.time <- data.frame(
  		id = id_msgs, # session id
  		sending = sending.time, 
  		receiving = reception.time,
  		time = reception.time - sending.time, # broadcasting time per session id
  		n.received = rcv, # how many locations received a message in a particular session
  		n.sent = sent, # how many locations sent a message in a particular session
  		B.i = B.i.tmp # total number of messages received per broadcast session
  )
}


plot.charts.for.single.experiment <- function(power.level, broadcast.info, ts = seq(step, max, by=step), max, step=30) {

	nr.nodes <- length(power.level[,1])
	n <- length(broadcast.info$id) # number of broadcast messages
        
        # TODO this implies a change of size in the data.frame
        #      an an error is reached
        # broadcast.info$time <- broadcast.info$time[!is.na(broadcast.info$time)]
	
        valid.time <- broadcast.info$time[broadcast.info$time <= max ]
	if (length(valid.time) == 0) {
		valid.time <- broadcast.info$time
	}
        plot(ecdf(valid.time * 1000), xlab="Time (ms)", main="ECDF of broadcasting session time")
	hist(valid.time, xlab="Session broadcasting Time (Seconds)", main="Broadcasting Time")

	plot(broadcast.info$B.i / broadcast.info$n.received, type="l", col="blue", xlab="Broadcast Session", ylab="n/B.i", main="Mean of Duplicated Messages ?")

	plot(broadcast.info$n.received/nr.nodes*100, type="l", col="blue", xlab="Session Id", ylab="Coverage (%)", main="Coverage")

	nr.dead.nodes <- apply(power.level, 2, function(e) length(e[e == 0]) )

	plot(y=broadcast.info$n.received/nr.nodes*100, 
		 x = broadcast.info$sending ,
		 type="l", 
		 col="blue", 
		 xlab="Sending Time (Seconds) of each session", 
		 ylab="Coverage (%)", 
		 main="Coverage per session Id"
		)

	print(ts)
	print(nr.dead.nodes)

	# TODO: PLOT THIS USING LINES
	
	plot(x = ts, y = nr.dead.nodes*100.0/nr.nodes, type="l")
	
	boxplot(power.level, names = sapply(ts, function(x) paste("", x, sep="")  ) )

}

average.values <- function(pl, broadcast.info, max) {

	nr.nodes <- length(pl[,1])
	n <- length(broadcast.info$id) # number of broadcast messages 

	c  <- sum(broadcast.info$n.received/nr.nodes*100)/n
	
	valid.time <- broadcast.info$time[broadcast.info$time <= max ]
	bt <- sum(valid.time, na.rm=TRUE)/length(valid.time)
	
	pc <- sum ( pl[, ncol(pl)] )/nr.nodes
	
	dm <- sum(broadcast.info$B.i / broadcast.info$n.received)/n

	rt <- mean(broadcast.info$n.sent)

	data.frame(
		coverage = c,
		broadcasting.time = bt,
		power_consumption = pc,
		duplicated_messages = dm,
		retransmitted_messages = rt
	) 
}

# TODO: coverage (percentage of nodes that receive a message per broadcast session) (this depends on many experiments, it is partially done in one of the functions)
# 			- we can aggregate this in many ways
#					1. chart of broadcast session and coverage (one curve per protocol). this one is only useful to compare protocols using the same topology
#					2. I (Inti) think that we can also compute the complete coverage in the experiments (all sessions together) and plot a single value per experiment in a chart. This is the one I explained before.
# TODO: total power consumption in one experiment
# TODO: chart of power consumption in many experiments (depends on the previous one)

args <- commandArgs(trailingOnly=TRUE)
print(args)
if (length(args) == 3) {
	sim.time <- strtoi(args[3])
	print(paste("Loading data file:", args[1]))
	powerLevelDs <- load.datafile(args[1], "name(residualCapacity:vector)" )
        msgSentDs <- load.datafile(args[1], "name(msg_sent:vector)" )
        msgRcvDs <- load.datafile(args[1], "name(broadcast_msg_received:vector)" )

  #return( data.frame(plD = powerLevelDs, msD = msgSentDs, bmrD = broadcastMsgRcvDs) )
	device<-pdf(paste(args[2], "charts.pdf", sep="-"), width=10, height=7)
	device

	print(paste("Creating powerlevels:", args[1]))
	#pl <- powerlevels3( ds, max= sim.time )
	pl <- powerlevels3(powerLevelDs, max= sim.time )

	print(paste("Creating broadcasting time:", args[1]))
	#bs <- broadcastingTime(ds, simulation.time = sim.time)
	bs <- broadcastingTime(msgSentDs, msgRcvDs, simulation.time = sim.time)

	print("Plotting :-P");
	plot.charts.for.single.experiment(pl, bs, max = sim.time)
	
	# printing average values
	averages <- average.values(pl, bs, max=sim.time)
	print(noquote(paste("average_values", averages$coverage, averages$broadcasting.time, averages$power_consumption, averages$duplicated_messages, averages$retransmitted_messages)))
}

#lapply(1:1, function(b) max(as.numeric(unlist(lapply(broadcasts, function(n) { s = x$vectordata[x$vectordata$resultkey == n,]; min(s[s$y == b,]$x) } )))))
