
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

powerlevels3 <- function(ds, ts = seq(step, max, by=step), max = 600, step=30, dev=pdf("powerlevels3.pdf")) {
  v <- ds$vectordata
  power_levels <- ds$vectors[ ds$vectors$name == 'power_level:vector', ]$result
  tmp <- subset(v, resultkey %in% power_levels) # filter out other vectors
  others <- lapply(power_levels, function(p) subset(tmp, resultkey == p)) # create a separete list for each power level
  #dev
  boxplot(sapply(lapply(ts, function(t)  lapply(others, function(s) tail(subset(s, x<=t, select=c(y)), 1) )), unlist))
  #dev.off()
}


broadcastingTime <- function(ds, dev=pdf("broadcastingTime3.pdf")) {
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

	broadcasting.time <- data.frame(
	  id = id_msgs,
	  time = reception.time - sending.time
	)
	
	#dev
	hist(bt$time, xlab="Session broadcasting Time (Seconds)", main="Broadcasting Time")
	#dev.off()
}



args <- commandArgs(trailingOnly=T)
if (length(args) == 1) {
  print(paste("Loading data file:", args))
  ds <- load.datafile(args)

  device <- pdf(paste("Charts", args, sep="-"))
  device()

  print(paste("Creating powerlevels:", args))
  powerlevels3(ds, dev = device)

  print(paste("Creating broadcasting time:", args))  
  broadcastingTime(ds, dev = device)

  device.off()
}


#lapply(1:1, function(b) max(as.numeric(unlist(lapply(broadcasts, function(n) { s = x$vectordata[x$vectordata$resultkey == n,]; min(s[s$y == b,]$x) } )))))
