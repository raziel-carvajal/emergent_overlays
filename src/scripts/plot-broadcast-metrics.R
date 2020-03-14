library(argparse)
library(gridExtra)

source("R/theme-for-papers.R")
source("R/plotting-functions.R")

get_arguments <- function() {
  parser <- ArgumentParser(description='Plot broadcast metrics.')

  parser$add_argument('resultsDir',  type="character")
  parser$add_argument('dataset',  type="character")
  parser$add_argument('protocol',  type="character")

  parser$add_argument('--plot-energy-consumption', dest='pc', action='store_true')

  parser$add_argument('--plot-coverage', dest='co', action='store_true')
  parser$add_argument('--plot-coverage-all-datasets', dest='coads', action='store_true')

  parser$add_argument('--plot-local-coverage-over-time', dest='plcot', action='store_true')
  parser$add_argument('--plot-local-coverage-all-datasets', dest='plcads', action='store_true')

  parser$add_argument('--plot-density-obs', dest='denobs', action='store_true')
  parser$add_argument('--plot-mobility-obs', dest='mobobs', action='store_true')
	parser$add_argument('--plot-recv-msgs-in-time', dest='recvt', action='store_true')
	parser$add_argument('--plot-coverage-in-time', dest='covint', action='store_true')
	parser$add_argument('--plot-runalgo-in-time', dest='algoint', action='store_true')

  parser$add_argument('--plot-msg-err-rate', dest='pmer', action='store_true')
  parser$add_argument('--plot-msg-err-rate-over-time', dest='pmerot', action='store_true')
  parser$add_argument('--plot-msg-err-rate-all-datasets', dest='merads', action='store_true')

  parser$add_argument('--plot-sent-msgs', dest='sm', action='store_true')
  parser$add_argument('--plot-recv-msgs', dest='rm', action='store_true')
	parser$add_argument('--plot-saved-rebroadcasts', dest='srb', action='store_true')
	parser$add_argument('--with-colours', dest='wco', action='store_true')

  parser$parse_args()
}
args <- get_arguments()

metadata = NULL
separate_dist = TRUE
files <- list.files(
  path=args$resultsDir,
  pattern=paste(args$dataset, '-', args$protocol, sep='')
)

if ( length(files) == 0 ) {
  print("No dataset was found")
  stop()
}

if (args$plcot) {
  pdf(file=paste('local-coverage-over-time-', args$protocol, '.pdf', sep=''))
  t <- read.table( paste(args$resultsDir, files[1], sep=''), header=T )
  d <- c( t$globalLocalCoverage, t$localCoverageAtPoi, t$localCoverageOutPoi)
  dataset <- data.frame(
    data = d,
    # for emergent overlays
    time = rep(order(t$time, decreasing=T) * 10, 3),
    # time = rep(t$time, 3),
    region = c(
      rep("All", length(t$globalLocalCoverage)),
      rep("At PoI", length(t$localCoverageAtPoi)),
      rep("Out of PoI", length(t$localCoverageOutPoi))
    )
  )
  p <- plotOverTime(
    dataset,
    paste('Local coverage over time of', args$protocol),
    'Time (s)',
    'Local coverage (%)',
    # for emergent overlays
    data.frame(min=0, max=max(t$time*10), step=50),
    # data.frame(min=0, max=max(t$time), step=5),
    data.frame(min=0, max=100, step=10)
  )
  grid.arrange(p, ncol = 1)
  dev.off()
}

if (args$pmerot) {
  pdf(file=paste('mer-over-time-', args$protocol, '.pdf', sep=''))
  t <- read.table( paste(args$resultsDir, files[1], sep=''), header=T )
  d <- c( t$globalMsgsErrorRate, t$msgErrorRateAtPoi, t$msgErrorRateOutPoi)
  dataset <- data.frame(
    data = d,
    # for emergent overlays
    # time = rep(order(t$time, decreasing=T) * 10, 3),
    time = rep(t$time, 3),
    region = c(
      rep("All", length(t$globalMsgsErrorRate)),
      rep("At PoI", length(t$msgErrorRateAtPoi)),
      rep("Out of PoI", length(t$msgErrorRateOutPoi))
    )
  )
  p <- plotOverTime(
    dataset,
    paste('Broadcast message error rate of', args$protocol),
    'Time (s)',
    'Error Rate',
    # for emergent overlays
    # data.frame(min=0, max=max(t$time*10), step=50),
    data.frame(min=0, max=max(t$time), step=5),
    data.frame(min=0, max=1.0, step=0.2)
  )
  grid.arrange(p, ncol = 1)
  dev.off()
}

if (args$coads) {
  pdf(file="coverage.pdf")
  algos <- c('CF', 'MPR', 'Emergent Overlays')
  datasets <- data.frame(
    'coverage_msg-error-rate-CONTROLLEDFLOOD-3',
    'coverage_msg-error-rate-MPR',
    'coverage_msg-error-rate-EMERG-OVRL-0'
  )
  names(datasets) <- algos
  plots <- lapply(algos, function(a){
    t <- read.table( paste(args$resultsDir, datasets[[ a ]], sep=''), header=T )
    d <- c( t$globalCoverage, t$coverageAtPoi, t$coverageOutPoi)
    dataset <- data.frame(
      data = d, algorithm = rep(unique(t$algo), length(d)),
      region = c(
        rep("All", length(t$globalCoverage)),
        rep("At PoI", length(t$coverageAtPoi)),
        rep("Out of PoI", length(t$coverageOutPoi))
      )
    )
    plot.dist.as.cdf(
      dataset,
      paste('Global coverage of', a),
      'Global coverage (%)',
      'Broadcast messages (CDF in %)', c(0, 100)
    )
  })
  grid.arrange(plots[[1]], plots[[2]], plots[[3]], ncol = 1)
  dev.off()
}

if (args$plcads) {
  pdf(file="local-coverage.pdf")
  algos <- c('CF', 'MPR', 'Emergent Overlays')
  datasets <- data.frame(
    'coverage_msg-error-rate-CONTROLLEDFLOOD-0',
    'coverage_msg-error-rate-MPR',
    'coverage_msg-error-rate-EMERG-OVRL-0'
  )
  names(datasets) <- algos
  plots <- lapply(algos, function(a){
    t <- read.table( paste(args$resultsDir, datasets[[ a ]], sep=''), header=T )
    d <- c( t$globalLocalCoverage, t$localCoverageAtPoi, t$localCoverageOutPoi)
    dataset <- data.frame(
      data = d, algorithm = rep(unique(t$algo), length(d)),
      region = c(
        rep("All", length(t$globalLocalCoverage)),
        rep("At PoI", length(t$localCoverageAtPoi)),
        rep("Out of PoI", length(t$localCoverageOutPoi))
      )
    )
    plot.dist.as.cdf(
      dataset,
      paste('Local coverage of', a),
      'Local coverage (%)',
      'Broadcast messages (CDF in %)', c(0, 100)
    )
  })
  grid.arrange(plots[[1]], plots[[2]], plots[[3]], ncol = 1)
  dev.off()
}

if (args$merads) {
  pdf(file="message-error-rate.pdf")
  algos <- c('CF', 'MPR', 'Emergent Overlays')
  datasets <- data.frame(
    'coverage_msg-error-rate-CONTROLLEDFLOOD-3',
    'coverage_msg-error-rate-MPR',
    'coverage_msg-error-rate-EMERG-OVRL-0'
  )
  names(datasets) <- algos
  plots <- lapply(algos, function(a){
    t <- read.table( paste(args$resultsDir, datasets[[ a ]], sep=''), header=T )
    d <- c( t$globalMsgsErrorRate, t$msgErrorRateAtPoi, t$msgErrorRateOutPoi)
    dataset <- data.frame(
      data = d, algorithm = rep(unique(t$algo), length(d)),
      region = c(
        rep("All", length(t$globalMsgsErrorRate)),
        rep("At PoI", length(t$msgErrorRateAtPoi)),
        rep("Out of PoI", length(t$msgErrorRateOutPoi))
      )
    )
    plot.dist.as.cdf(
      dataset,
      paste('Message Error Rate of', a),
      'Error Rate',
      'Broadcast messages (CDF in %)', c(0, 1)
    )
  })
  grid.arrange(plots[[1]], plots[[2]], plots[[3]], ncol = 1)
  dev.off()
}

if (args$co) {
  print('Ploting coverage...')
  pdf('coverage.pdf')
  for (f in files) {
    t <- read.table( paste(args$resultsDir, f, sep=''), header=T )
    d <- c( t$globalCoverage, t$coverageAtPoi, t$coverageOutPoi)
    dataset <- data.frame(
      data = d, algorithm = rep(unique(t$algo), length(d)),
      region = c(
        rep("All", length(t$globalCoverage)),
        rep("At PoI", length(t$coverageAtPoi)),
        rep("Out of PoI", length(t$coverageOutPoi))
      )
    )
    plot.dist.as.cdf(
      dataset,
      'Global coverage of Emergent Overlays',
      'Global coverage (%)',
      'Broadcast messages (CDF in %)', c(0, 100)
    )
  }
  dev.off()
  print('DONE')
}

if (args$pmer) {
  print('Ploting broadcast message error rate...')
  pdf('broadcast-message-error-rate.pdf')
  for (f in files) {
    t <- read.table( paste(args$resultsDir, f, sep=''), header=T )
    d <- c( t$globalMsgsErrorRate, t$msgErrorRateAtPoi, t$msgErrorRateOutPoi)
    dataset <- data.frame(
      data = d, algorithm = rep(unique(t$algo), length(d)),
      region = c(
        rep("All", length(t$globalMsgsErrorRate)),
        rep("At PoI", length(t$msgErrorRateAtPoi)),
        rep("Out of PoI", length(t$msgErrorRateOutPoi))
      )
    )
    plot.dist.as.cdf(
      dataset,
      'Message error rate of controlled flooding',
      'Error rate',
      'Broadcast messages (CDF in %)', c(0, 1)
    )
  }
  dev.off()
  print('DONE')
}

if (args$denobs || args$mobobs) {
	print("Plotting observables")
  for (f in files) {
    dataset <- read.table( paste(args$resultsDir, f, sep=''), header=T )
    samples <- unique(dataset$time)
    regions <- unique(dataset$region)
    obs <- ifelse(args$denobs, 'density', 'mobility')
    plotInfo <- data.frame(
      plotTitle = paste('Observable: nodes', obs, '(in'),
      xLabel = paste('Nodes', obs),
      yLabel = paste('Number of times', obs, 'was measured (CDF in %)')
    )
    for (r in regions) {
      sdsByRegion <- subset(dataset, region == r)
      pdf(paste(obs, '-approx-at-', r, '.pdf', sep=''))
      if (args$denobs) {
        values <- sdsByRegion$density
      } else {
        values <- sdsByRegion$mobility
      }
      sdsByRegion <- data.frame(
        data = values,
        sample = sapply(sdsByRegion$time, toString)
      )
      plotCDFset(
        sdsByRegion,
        paste(plotInfo$plotTitle, r, 'zone)'),
        plotInfo$xLabel, plotInfo$yLabel, c(0, 40)
      )
      dev.off()
    }
  }
  print('DONE')
  # plot.dist.as.cdf(
	# 	dsToPlot, '', 'Estimated stability (seconds/neighbor)', 'CDF in % (nodes)'
	# )
}

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

# pdf(file="plot.pdf", width = unit(5.5, 'cm'), height = unit(4, 'cm'))
# grid.arrange(p1, p2, p3, ncol = 1)
# dev.off()

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

# if (args$pe) {
#   print('Ploting packet error rate')
#   ds <- read.table(
#     paste(args$resultsDir, 'packetErrorRate', sep=''),
#     header=F
#   )
#   names(ds) <- c('data', 'algorithm')
#   plot.dist.as.cdf(
#     ds, '',
#     'Lost broadcast messages (%)', 'CDS', xMax=100
#   )
#   print('DONE')
# }

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
