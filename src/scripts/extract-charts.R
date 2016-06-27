
require('omnetpp')

load.datafile <- function(fname, extensions=c("sca", "vec")) {
  ds <- loadDataset(paste(fname, sep= ".", extensions), add('vector'))
  ds <- loadVectors(ds, NULL)
}

#powerlevels <- function(ds, ts = seq(step, max, by=step), max = 600, step=30, dev=pdf("powerlevels.pdf")) {
#  v <- ds$vectordata
#  power_levels <- ds$vectors[ ds$vectors$name == 'power_level:vector', ]$result
#  dev
#  boxplot(sapply(lapply(ts, function(t) lapply(power_levels, function(p) tail(subset(v, resultkey == p & x < t, select=c(y)), 1))), unlist))
#  dev.off()
#}

#powerlevels2 <- function(ds, ts = seq(step, max, by=step), max = 600, step=30, dev=pdf("powerlevels.pdf")) {
#  v <- ds$vectordata
#  power_levels <- ds$vectors[ ds$vectors$name == 'power_level:vector', ]$result
#  tmp <- subset(v, resultkey %in% power_levels)
#  dev
#  boxplot(sapply(lapply(ts, function(t) lapply(power_levels, function(p) tail(subset(tmp, resultkey == p & x <= t, select=c(y)), 1))), unlist))
#  dev.off()
#}

powerlevels3 <- function(ds, ts = seq(step, max, by=step), max = 600, step=30) {
  v <- ds$vectordata
  power_levels <- ds$vectors[ ds$vectors$name == 'power_level:vector', ]$result
  tmp <- subset(v, resultkey %in% power_levels) # filter out other vectors
  others <- lapply(power_levels, function(p) subset(tmp, resultkey == p)) # create a separete list for each power level
  sapply(lapply(ts, function(t)  lapply(others, function(s) tail(subset(s, x<=t, select=c(y)), 1) )), unlist) # vector of power levels for each instant of time
}


broadcastingTime <- function(ds) {
	v <- ds$vectordata
	msg_sent <- ds$vectors[ ds$vectors$name == 'msg_sent:vector', ]$result
	tmp <- subset(v, resultkey %in% msg_sent) # filter out vectors that are not msg_sent
	list_of_sent <- lapply(msg_sent, function(p) subset(tmp, resultkey == p)) # create a separate list for each msg_sent vector

	id_msgs <- tmp[[4]][!duplicated(tmp[[4]])] # recover list of msg id

	msg_received <- ds$vectors[ ds$vectors$name == 'broadcast_msg_received:vector', ]$result
	tmp2 <- subset(v, resultkey %in% msg_received) # filter out vectors that are not broadcast_msg_received
	list_of_received <- lapply(msg_received, function(p) subset(tmp2, resultkey == p)) # create a separate list for each broadcast_msg_received vector

	sending.time <- sapply(id_msgs, function(id) min( unlist(lapply(list_of_sent, function(d)  subset(d, y == id, select=c(x))[[1]] )) ) )
	reception.time <- sapply(id_msgs, function (id) max(sapply(list_of_received, function(d)  head(subset(d, y == id, select=c(x)), 1)[[1]] )) )
	
	# compute number of message received at each location (coverage)
  rcv <- sapply(id_msgs, function(id) { sum( sapply(list_of_received, function(d) id %in% d$y ) ) } )

	B.i.tmp <- sapply(id_msgs, function(id) sum(sapply(list_of_received, function(d)  sum(subset(d, y == 1, select=c(y))[[1]]) )))

	broadcasting.time <- data.frame(
			id = id_msgs, # session id
			time = reception.time - sending.time, # broadcasting time per session id
			n.received = rcv, # how many location received a message from a particular session
			B.i = B.i.tmp # total number of messages recevied per broadcast session
	)
}


plot.charts.for.single.experiment <- function(power.level, broadcast.info) {

	nr.nodes <- length(power.level[,1])
	n <- length(broadcast.info$id) # number of broadcast messages

	hist(broadcast.info$time, xlab="Session broadcasting Time (Seconds)", main="Broadcasting Time")

	plot(nr.nodes/broadcast.info$B.i, type="l", col="blue", xlab="Broadcast Session", ylab="n/B.i", main="Ratio of Duplicated Messages ?")

	plot(broadcast.info$n.received/nr.nodes*100, type="l", col="blue", xlab="Session Id", ylab="Coverage (%)", main="Coverage")

  boxplot(power.level)
	
}

# TODO: coverage (percentage of nodes that receive a message per broadcast session) (this depends on many experiments, it is partially done in one of the functions)
# 			- we can aggregate this in many ways
#					1. chart of broadcast session and coverage (one curve per protocol). this one is only useful to compare protocols using the same topology
#					2. I (Inti) think that we can also compute the complete coverage in the experiments (all sessions together) and plot a single value per experiment in a chart. This is the one I explained before.
# TODO: total power consumption in one experiment
# TODO: chart of power consumption in many experiments (depends on the previous one)


args <- commandArgs(trailingOnly=TRUE)
if (length(args) == 2) {
  print(paste("Loading data file:", args[1]))
  ds <- load.datafile(args[1])

  device<-pdf(paste(args[2], "charts.pdf", sep="-"), width=10, height=7)
  device

  print(paste("Creating powerlevels:", args[1]))
  pl <- powerlevels3(ds)

  print(paste("Creating broadcasting time:", args[1]))  
  bs <- broadcastingTime(ds)

	plot.charts.for.single.experiment(pl, bs)

}


#lapply(1:1, function(b) max(as.numeric(unlist(lapply(broadcasts, function(n) { s = x$vectordata[x$vectordata$resultkey == n,]; min(s[s$y == b,]$x) } )))))
