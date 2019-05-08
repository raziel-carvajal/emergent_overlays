library(ggplot2)
library(plyr)
library(argparse)
library(e1071)
library(grid)
library(reshape2)
library(Cairo)
library(grid)
library(gridExtra)
source("R/theme-for-papers.R")

get_arguments <- function() {
  parser <- ArgumentParser(description='Plot broadcast metrics.')

  parser$add_argument('resultsDir',  type="character")

  parser$add_argument('--plot-energy-consumption', dest='pc', action='store_true')
  parser$add_argument('--plot-coverage', dest='co', action='store_true')
	parser$add_argument('--plot-observables', dest='obs', action='store_true')
	parser$add_argument('--plot-recv-msgs-in-time', dest='recvt', action='store_true')
	parser$add_argument('--plot-coverage-in-time', dest='covint', action='store_true')
	parser$add_argument('--plot-runalgo-in-time', dest='algoint', action='store_true')
  parser$add_argument('--plot-packet-err', dest='pe', action='store_true')
  parser$add_argument('--plot-sent-msgs', dest='sm', action='store_true')
  parser$add_argument('--plot-recv-msgs', dest='rm', action='store_true')
	parser$add_argument('--plot-saved-rebroadcasts', dest='srb', action='store_true')
	parser$add_argument('--with-colours', dest='wco', action='store_true')

  parser$parse_args()
}

plot.nodes.roles.distribution <- function(ds) {
  names(ds) <- c('count', 'fw_type', 'zone', 'algorithm')
  denseDs <- subset(ds, zone == 'DENSE')
  sparsDs <- subset(ds, zone == 'SPARSE')
  sparsP <- ggplot(sparsDs)
  denseP <- ggplot(denseDs)
  p1 <- sparsP + geom_col(aes(x=algorithm, y=count, fill=fw_type)) +
    ggtitle('Forwarding nodes in sparse zone') + get.plot.theme.style() +
    xlab('Algorithm') + ylab('Nodes (%)') + guides(fill=guide_legend(title='Type'))
  p2 <- denseP + geom_col(aes(x=algorithm, y=count, fill=fw_type)) +
    ggtitle('Forwarding nodes in dense zone') + get.plot.theme.style() +
    xlab('Algorithm') + ylab('Nodes (%)') + guides(fill=guide_legend(title='Type'))
  print(p1)
  print(p2)
}

plot.dist.as.cdf <- function(ds, title, xlabel, ylabel) {
	p <- ggplot(ds, aes(x = data, linetype = region))
	p <- p + stat_ecdf(aes(y = ..y..*100), pad = F, size = 1)
	p <- p + scale_linetype_manual(
		labels = c("All", "At PoI", "Out of PoI"),
		values = c('solid', 'dashed', 'dotted')
	)
	p <- p + scale_x_continuous(breaks = seq(0, ceiling(max(ds$data)), by = 1))
	p <- p + theme_Publication() + labs(y = ylabel, x = xlabel)
	p <- p + ylim(0, 100)
	# p <- p + xlim(0, ceiling(max(ds$data))) + ylim(0, 100)
  print(p)
}

plotRunAlgoOverTime <- function(ds, xlabel, ylabel){
	p <- ggplot(
		data = ds,
		aes(x = time, y = nodes, group = algo)
	)
	p <- p + geom_col(aes(fill = algo), colour = 'black')
	p <- p + geom_text(
		aes(label = c('100\nCF', nodes[2:(length(nodes)-1)], '67\nMPR') ),
		position = position_stack(vjust = 0.5),
		size = 3
	)
	p <- p + scale_fill_manual(
		values = c("#ffffff", "grey90")
	)
	# p <- p + geom_text(
	# 	data = ds,
	# 	aes(x = time, y = nodes, label = paste0(nodes,"%")),
  # 	size = 4, position = position_stack(vjust = 0.5)
	# )
	p <- p + scale_x_continuous(
		# limits = c(0, 125),
		breaks = seq(0, 120, by = 20)
	)

	p <- p + labs(x = xlabel, y = ylabel)
	p + theme0()
}

plotOverTimeReg <- function(ds, xlabel, ylabel, ylim, ybr){
	p <- ggplot(data = ds, aes(
		x = time, y = data, linetype = region
	))
	p <- p + geom_line()
	p <- p + geom_point()

	p <- p + scale_x_continuous(
		limits = c(0, 120),
		breaks = seq(0, 120, by = 20)
	)
	p <- p + scale_y_continuous(
		limits = ylim,
		breaks = ybr
	)

	p <- p + labs(x = xlabel, y = ylabel)
	p + theme1()
}

plotOverTimeAlg <- function(ds, xlabel, ylabel, ylim, ybr){
	p <- ggplot(data = ds, aes(
		x = time, y = data, linetype = algo
	))
	p <- p + geom_line()
	p <- p + geom_point()

	p <- p + scale_x_continuous(
		limits = c(0, 120),
		breaks = seq(0, 120, by = 20)
	)
	p <- p + scale_y_continuous(
		limits = ylim,
		breaks = ybr
	)

	p <- p + labs(x = xlabel, y = ylabel)
	p + theme2()
}

plot.data.using.boxes <- function(ds, title, xlabel, ylabel) {
	p <- ggplot(data = ds, aes(x = algorithm, y = data, fill = region) )
	p <- p + geom_boxplot()
	p <- p + scale_fill_manual(
		labels = c("All", "At PoI", "Out of PoI"),
		values = c("#cccccc", "#666666", "#ffffff")
	)
	# "MPR3" = expression(MPR['\u0394=30']))
	p <- p + scale_x_discrete(
		labels = c(
			"HYBRID1" = expression('Emerg Ovl'),
			"ADAPTIVECF" = expression('Adaptive CF'),
			"SCOPEDHYPFLOOD" = expression('S-H Flood')
		)
	)
	p <- p + theme_Publication() + labs(y = ylabel) + ylim(0, max(ds$data))
	cairo_pdf(file="plot.pdf")
  print(p)
	dev.off()
}

args <- get_arguments()
metadata = NULL
separate_dist = TRUE

if (args$algoint) {
  ds <- read.table(
    paste(args$resultsDir, 'runningAlgorithmTimeline-HYBRID1', sep=''),
    header=T
  )

  p1 <- plotRunAlgoOverTime(ds, 'Time (s)', 'Nodes (%)')
  print('DONE')
}

if (args$covint) {
  ds <- read.table(
    paste(args$resultsDir, 'coverage-HYBRID1', sep=''),
    header=T
  )
	lim <- 120
	timeLine <- seq(2, lim, 2)
	ds <- data.frame(
		time = rep(timeLine, 1),
		region = c(
			# rep('all', length(timeLine)),
			# rep('outPoi', length(timeLine)),
			rep('inPoi', length(timeLine))
		),
		data = c(
			# ds$localCoverageAtAll[1:length(timeLine)],
			# ds$localCoverageAtSparse[1:length(timeLine)],
			ds$localCoverageAtDense[1:length(timeLine)]
		)
	)
  p2 <- plotOverTimeReg(ds,
		'Time (s)',
		'LBC at POI (%)',
		c(0, 100),
		seq(0, 100, by = 25)
	)

  print('DONE')
}

if (args$recvt) {
  ds <- read.table(
    paste(args$resultsDir, 'recvMessagesTimeline', sep=''),
    header=T
  )
	lim <- 120
	timeLine <- seq(2, lim, 2)
	ds <- data.frame(
		time = timeLine,
		data = ds$avgRecvMsgs,
		algo = ds$algo
	)
  p3 <- plotOverTimeAlg(
		ds,
		'Time (s)',
		'Inc. messages (#)',
		c(0, 200),
		seq(0, 200, by = 50)
	)
  print('DONE')
}

pdf(file="plot.pdf", width = unit(5.5, 'cm'), height = unit(4, 'cm'))
grid.arrange(p1, p2, p3, ncol = 1)
dev.off()

if (args$pc) {
  print('Plotting power consumption')
  ds <- read.table(
    paste(args$resultsDir, 'batteryConsumptionTimeline', sep=''),
    header=T
  )
	ds <- data.frame(
		time = ds$time,
		data = ds$e_consumption,
		algo = ds$algo
	)
  plotOverTime(ds, 'Time (s)', 'Average power consumption (W)')
  print('DONE')
}

if (args$srb) {
  print('Plotting saved rebroadcasts')
  ds <- read.table(
    paste(args$resultsDir, 'savedRebroadcasts', sep=''),
    header=F
  )
  names(ds) <- headers
  plot.data.using.boxes(ds, 'Saved rebroadcasts', '', 'Broadcast sessions [%]', c(0, 100))
	print('DONE')
}

if (args$co) {
  print('Ploting network coverage')
  ds <- read.table(
    paste(args$resultsDir, 'coverage', sep=''),
    header=F
  )
  names(ds) <- headers
  plot.data.using.boxes(
    ds, 'Reachability', '', 'Broadcast sessions [%]', c(0, 100)
  )
  print('DONE')
}

if (args$pe) {
  print('Ploting packet error rate')
  ds <- read.table(
    paste(args$resultsDir, 'packetErrorRate', sep=''),
    header=F
  )
  names(ds) <- c('data', 'algorithm')
  plot.dist.as.cdf(
    ds, '',
    'Lost broadcast messages (%)', 'CDS', xMax=100
  )
  print('DONE')
}

if (args$obs) {
	print("Plotting distribution of observables")
	ds <- read.table(
		paste(args$resultsDir, 'ObservablesDistribution-SIMPLEF', sep=''),
		header=T
	)
	window <- unique(ds$time)[1]
	subDs <- subset(ds, time == window)
	dsToPlot <- data.frame(
		data = subDs$mobility,
		# data = subDs$density,
		region = subDs$positionedAt
	)
  plot.dist.as.cdf(
		dsToPlot, '', 'Estimated stability (seconds/neighbor)', 'CDF in % (nodes)'
	)
	print('DONE')
}
if (args$rm) {
  print("Plotting received broadcast messages")
  ds <- read.table(
    paste(args$resultsDir, 'recvBroadcastMsgsDistribution', sep=''),
    header=T
  )
	subDs <- data.frame(
		data = ds$recvMsgNo,
		region = ds$positionedAt,
		algorithm = ds$algorithm
	)
  plot.data.using.boxes(subDs, '', '', 'Incoming messages (application level)')
  print('DONE')
}

if (args$sm) {
  print('Plotting sent broadcast messages')
  ds <- read.table(
    paste(args$resultsDir, 'sentBroadcastMsgsDistribution', sep=''),
    header=T
  )
  subDs <- data.frame(
		data = ds$sentMsgNo,
		region = ds$positionedAt,
		algorithm = ds$algorithm
	)
	plot.data.using.boxes(subDs, '', '', 'Outgoing messages (application level)')
  print('DONE')
}
