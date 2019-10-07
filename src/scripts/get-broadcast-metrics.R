library(argparse)
library(rjson)

source("R/dataset-utils.R")
source("R/wireless-topology.R")
source("R/broadcast-metrics-utils.R")

get.arguments <- function() {
  parser <- ArgumentParser(
    description='Get a distribution per broadcast metric from Omnet++ datasets.'
  )
  # metadata of data set
  parser$add_argument('configName', type='character',
    help='Configuration ID at INI file.')
  parser$add_argument('datasetFile', type='character',
    help='Dataset of an experiment with Omnet++/INET (no extension).')
  # experimental settings
  parser$add_argument('--simulation-time',
    dest='simTime', type='double', help='Duration of experiment in seconds.')
  parser$add_argument('--results-dir',
    dest='resultsDir', type='character')
  parser$add_argument('--transmission-range',
    dest='tx', type='integer', help='Nodes transmission range.')
	parser$add_argument('--with-mobility',
		dest='wmob', action='store_true')
	parser$add_argument('--with-plotting',
		dest='wplot', action='store_true')
	parser$add_argument('--with-metrics-over-time',
		dest='wmot', action='store_true')
  # list of broadcast metrics
  parser$add_argument('--with-energy-consumption',
    dest='wpc', action='store_true')
  parser$add_argument('--with-coverage',
    dest='wco', action='store_true')
  parser$add_argument('--with-packet-err',
    dest='wpe', action='store_true')
  parser$add_argument('--with-sent-msgs',
    dest='wsm', action='store_true')
  parser$add_argument('--with-recv-msgs',
    dest='wrm', action='store_true')
	parser$add_argument('--with-fwd-type',
		dest='wft', action='store_true')
	parser$add_argument('--with-saved-rebroadcasts',
		dest='wsre', action='store_true')
	parser$add_argument('--with-observables',
		dest='wobs', action='store_true')

  parser$parse_args()
}
args <- get.arguments()

# create name of data set
expeConfig <- unlist(strsplit(args$configName, '_'))
algorithmN <- toupper(expeConfig[ length(expeConfig) ])
datasetFile <- unlist(strsplit(args$datasetFile, args$configName))
datasetFile <- paste(datasetFile[1], 'results/', args$configName, '-0', sep='')

# metadata of every wireless topology form per each entry of the mobility trace
fName <- strsplit(args$configName, expeConfig[ length(expeConfig) ])
fName <- paste('../../experiments/networks/built_topologies/', fName[1], '.json', sep='')
groundTruth <- fromJSON(file=fName)

# get ID of topologies with a broadcast session
topologyIndx <- sapply(names(groundTruth), function(i) {
  ifelse(is.nan( as.numeric(groundTruth[[ i ]]$srcNode) ) , NaN, i)
})
topologyIndx <- topologyIndx[ !is.nan(topologyIndx) ]

# fetch sent/received messages
sent_broadcast_msgs <- getVector(datasetFile, 'sentBroadcastMsg:vector')
recv_broadcast_msgs <- getVector(datasetFile, 'rcvdBroadcastMsg:vector')

# identifiers of all broadcast sessions
msgs_ids <- sort.int(unique(sent_broadcast_msgs$value))

if(args$wco){
  # get global coverage
  ### over all nodes
  print("Getting global coverage...")
  globalCoverage <- sapply(topologyIndx, function(i) {
    groundTruth[[ i ]]$componentSize
  })
  measuredGlobalCoverage <- sapply(msgs_ids, function(msg) {
    length( unique( subset(recv_broadcast_msgs, value == msg)$node_id ) )
  })
  globalCovPerc <- (measuredGlobalCoverage / globalCoverage) * 100
  print(globalCovPerc)

  ### per cluster(s)
  coveredNodes <- lapply(msgs_ids, function(msg) {
    unique( subset(recv_broadcast_msgs, value == msg)$node_id )
  })
  ###### at PoI
  print("Getting global coverage at PoI...")
  gCovAtPoi <- sapply(topologyIndx, function(i) {
    nodesAtPoi <- groundTruth[[ i ]]$nodesAtDense
    measured <- sapply(nodesAtPoi, function(n) {
      ifelse(n %in% coveredNodes[[ strtoi(i) ]], 1, 0)
    })
    ( sum(measured) / length(nodesAtPoi) ) * 100
  })
  print(gCovAtPoi)
  ###### out of PoI
  print("Getting global coverage out of PoI...")
  gCovOutOfPoi <- sapply(topologyIndx, function(i) {
    nodesOutOfPoi <- groundTruth[[ i ]]$nodesAtSparse
    measured <- sapply(nodesOutOfPoi, function(n) {
      ifelse(n %in% coveredNodes[[ strtoi(i) ]], 1, 0)
    })
    ( sum(measured) / length(nodesOutOfPoi) ) * 100
  })
  print(gCovOutOfPoi)

  # get local coverage...
  ### over all nodes
  print("Getting local coverage...")
  localCoverage <- sapply(topologyIndx, function(i) {
    neigs <- groundTruth[[ i ]]$neighbors
    sum( sapply(names(neigs), function(n) { length(neigs[[ n ]]) }) ) + 1
  })
  measuredLocalCoverage <- sapply(msgs_ids, function(msg) {
    length( subset(recv_broadcast_msgs, value == msg)$node_id )
  })
  localCovPerc <- (measuredLocalCoverage / localCoverage) * 100
  print(localCovPerc)

  ### at/out (of) PoI
  ###### get ground truth per each zone
  gtLocalCov <- lapply(topologyIndx, function(i) {
    neigs <- groundTruth[[ i ]]$neighbors
    gtAtPoi <- sapply(groundTruth[[ i ]]$nodesAtDense, function(n) {
      length(neigs[[ toString(n) ]])
    })
    gtOutPoi <-sapply(groundTruth[[ i ]]$nodesAtSparse, function(n) {
      length(neigs[[ toString(n) ]])
    })
    data.frame(
      lCovAtPoi =sum(gtAtPoi),
      lCovOutPoi=sum(gtOutPoi)
    )
  })
  ###### get measured coverage per zone
  measuredLocalCov <- lapply(msgs_ids, function(msg) {
    recvMsgDs <- subset(recv_broadcast_msgs, value == msg)
    recvMsgAtPoi <- sapply(groundTruth[[ toString(msg) ]]$nodesAtDense, function(n){
      length( subset(recvMsgDs, node_id == n)$node_id )
    })
    recvMsgOutPoi <-sapply(groundTruth[[ toString(msg) ]]$nodesAtSparse, function(n){
      length( subset(recvMsgDs, node_id == n)$node_id )
    })
    data.frame(
      lCovAtPoi =sum(recvMsgAtPoi),
      lCovOutPoi=sum(recvMsgOutPoi)
    )
  })
  lCovAtPoi <- sapply(msgs_ids, function(msg) {
    ( measuredLocalCov[[ msg ]]$lCovAtPoi / gtLocalCov[[ msg ]]$lCovAtPoi ) * 100
  })
  lCovOutPoi <-sapply(msgs_ids, function(msg) {
    ( measuredLocalCov[[ msg ]]$lCovOutPoi / gtLocalCov[[ msg ]]$lCovOutPoi ) * 100
  })
  print("Getting local coverage at PoI...")
  print(lCovAtPoi)
  print("Getting local coverage out of PoI...")
  print(lCovOutPoi)

  # get message error rate...
  ### over all nodes and all broadcast messages
  print("Getting message error rate...")
  msgErrorRate <- (localCoverage - measuredLocalCoverage) / localCoverage
  print(msgErrorRate)
  ### at/out (of) PoI
  print("Getting message error rate at PoI...")
  merAtPoi <- sapply(msgs_ids, function(msg) {
    gt <- gtLocalCov[[ msg ]]$lCovAtPoi
    measured <- measuredLocalCov[[ msg ]]$lCovAtPoi

    ( gt - measured ) / gt
  })
  print(merAtPoi)
  print("Getting message error rate out of PoI...")
  merOutOfPoi <- sapply(msgs_ids, function(msg) {
    gt <- gtLocalCov[[ msg ]]$lCovOutPoi
    measured <- measuredLocalCov[[ msg ]]$lCovOutPoi

    ( gt - measured ) / gt
  })
  print(merOutOfPoi)

  # get collisions...
  ### over all nodes and  broadcast sessions
  print("Getting total number of collisions...")
  globalCollisionsNo <- sum(localCoverage - measuredLocalCoverage)
  print(globalCollisionsNo)
  ### at/out (of) PoI
  print("Getting collisions at PoI...")
  colAtPoi <- sapply(msgs_ids, function(msg) {
    gt <- gtLocalCov[[ msg ]]$lCovAtPoi
    measured <- measuredLocalCov[[ msg ]]$lCovAtPoi
    gt - measured
  })
  colAtPoi <- sum(colAtPoi)
  print(colAtPoi)
  print("Getting collisions out of PoI...")
  colOutOfPoi <- globalCollisionsNo - colAtPoi
  print(colOutOfPoi)

  dataSet <- data.frame(
		globalCoverage = globalCovPerc,
		localCoverage = localCovPerc,
		msgsErrorRate = msgErrorRate,
		algo=rep(algorithmN, length(globalCovPerc)), stringsAsFactors=F
	)
	saveDataFrame(dataSet, args$resultsDir, 'coverage_msg-error-rate', algorithmN)
}

xPositions <- getVector(datasetFile, 'positionAtX:vector')
yPositions <- getVector(datasetFile, 'positionAtY:vector')
# merge nodes positions in one dataframe
positions <- data.frame(
  nodeId = xPositions$node_id,
  time = xPositions$time,
  x = xPositions$value,
  y = yPositions[yPositions$node_id == xPositions$node_id, ]$value
)
positions <- positions[order(positions$time), ]
positions <- subset(positions, time <= args$simTime)

runningAlgorithm <- getVector(datasetFile, 'runningAlgorithm:vector')
runningAlgorithm <- runningAlgorithm[order(runningAlgorithm$time), ]
runningAlgorithm <- subset(runningAlgorithm, time <= args$simTime)

# nodes are labeled according to the type of FWD they perform OR whether they
# are border nodes (hybrid deployment) or not, this vector contains that
# information in form of integer values where: 3 means border node,
# 2 is a CDS relay and 0 means simple FWD
forwardTypeDs <- getVector(datasetFile, 'forward_type:vector')
forwardTypeDs <- forwardTypeDs[ order(forwardTypeDs$time), ]

nodes <- unique( getVector(datasetFile, 'positionAtX:vector')$node_id )

if(args$wplot){
  N <- length(nodes)
	topologies <- lapply(topologyIndx, function( i ) {
    i <- strtoi(i)
		# senders/receivers per broadcast message
    senders <- subset(sent_broadcast_msgs, value == msgs_ids[i])
    receivers<-subset(recv_broadcast_msgs, value == msgs_ids[i])
		# get what type of FWD nodes perform
		fwdTypeAtTopology <- subset(
			forwardTypeDs, min(senders$time) <= time & time <= max(receivers$time)
		)
		# get positions of nodes during dissemination of broadcast message
    nodesPositions <- positions[ ( (i - 1) * N + 1 ):( i * N ), ]
		# get the algorithm that nodes run during the dissemination of message: msgs_ids[o]
    runningAlgoAtTopology <- runningAlgorithm[ ( (i - 1) * N + 1 ):( i * N ), ]
    # get neighbors fro groundTruth
    neighbors <- groundTruth[[ i ]]$neighbors
		# build wireless topology
		plotWirelessTopology(
      i, N, neighbors, nodesPositions, unique(receivers$node_id),
			fwdTypeAtTopology, runningAlgoAtTopology
    )
  })
}

if(args$wobs){
	densityObs  <- getVector(datasetFile, 'densityObs:vector')
	denAtSparse <- subset(densityObs, node_id < args$fadz)
	denAtDense  <- subset(densityObs, node_id >= args$fadz)
	mobilityObs <- getVector(datasetFile, 'mobilityObs:vector')
	mobAtSparse <- subset(mobilityObs, node_id < args$fadz)
	mobAtDense  <- subset(mobilityObs, node_id >= args$fadz)
	ds <- data.frame(
		time=c(denAtSparse$time, denAtDense$time, densityObs$time),
		density=c(denAtSparse$value, denAtDense$value, densityObs$value),
		mobility=c(mobAtSparse$value, mobAtDense$value, mobilityObs$value),
		positionedAt=c(
			rep("Sparse", length(denAtSparse$value)),
			rep("Dense", length(denAtDense$value)),
			rep("All", length(densityObs$value))
		),
		algo=rep(
			algorithmN,
			length(denAtSparse$value) + length(denAtDense$value) + length(densityObs$value)
		),
		stringsAsFactors=F
	)
  saveDataFrame(
    ds,
    args$resultsDir, 'ObservablesDistribution', algorithmN
  )
}



if(args$wmot) {
	d <- 5 # delta in seconds
	timeLine <- lapply(1:floor(args$simTime / d), function(i){
		data.frame(limInf = (i -1) * d, limSup = i * d)
	})
	sent_broadcast_msgs <- subset(sent_broadcast_msgs, time <= args$simTime)
	recv_broadcast_msgs <- subset(recv_broadcast_msgs, time <= args$simTime)
	sentCtrlMsgs <- subset(sentCtrlMsgs, time <= args$simTime)
	recvCtrlMsgs <- subset(recvCtrlMsgs, time <= args$simTime)

	recvMsgsOverTime <- getRecvMsgsOverTime(recv_broadcast_msgs, timeLine)
	saveDataFrame(
    data.frame(
      time = recvMsgsOverTime$time,
			avgRecvMsgs = recvMsgsOverTime$data,
      algo=rep(algorithmN, length(recvMsgsOverTime$time)), stringsAsFactors=F
    ),
    args$resultsDir, 'recvMessagesTimeline', algorithmN
  )

	energy_consumption <- getWattsFromSentRecvMsgs(
    sent_broadcast_msgs, recv_broadcast_msgs,
		sentCtrlMsgs, recvCtrlMsgs, timeLine
  )
	saveDataFrame(
    data.frame(
      time = energy_consumption$time,
			e_consumption = energy_consumption$consumption,
      algo=rep(algorithmN, length(energy_consumption$time)), stringsAsFactors=F
    ),
    args$resultsDir, 'batteryConsumptionTimeline', algorithmN
  )

	runningAlgosDist <- getRunningAlogrithm(runningAlgorithm, args$simTime)
	saveDataFrame(
    runningAlgosDist,
    args$resultsDir,
		'runningAlgorithmTimeline',
		algorithmN
  )
}

if(args$wpc){
  print('Get distribution of energy consumption')
  energy_consumption <- getWattsFromSentRecvMsgs(
    sent_broadcast_msgs, recv_broadcast_msgs, all_nodes
  )
  saveDataFrame(
    data.frame(
      data=energy_consumption,
      algo=rep(algorithmN, length(energy_consumption)), stringsAsFactors=F
    ),
    args$resultsDir, 'batteryConsumptionDistribution', algorithmN
  )
}
if(args$wsm){
  print('DONE - Get distribution of sent broadcast messages')
  ds <- lapply(all_nodes, function(n){
		data.frame(
			sentMsgNo = length(subset(sent_broadcast_msgs, node_id == n)$value),
			positionedAt = ifelse(n < args$fadz, "Sparse", "Dense")
		)
  })
	ds <- do.call('rbind', ds)
  saveDataFrame(
    data.frame(
      sentMsgNo = c(ds$sentMsgNo, ds$sentMsgNo),
			positionedAt = c(as.character(ds$positionedAt), rep("All", length(ds$positionedAt))),
      algorithm = rep(algorithmN, length(ds$sentMsgNo)*2), stringsAsFactors=F
    ),
    args$resultsDir, 'sentBroadcastMsgsDistribution', algorithmN
  )
}
if(args$wrm){
  print('DONE - Get distribution of received broadcast messages')
  ds <- lapply(all_nodes, function(n){
		data.frame(
			recvMsgNo = length(subset(recv_broadcast_msgs, node_id == n)$value),
			positionedAt = ifelse(n < args$fadz, "Sparse", "Dense")
		)
  })
	ds <- do.call('rbind', ds)
  saveDataFrame(
    data.frame(
      recvMsgNo = c(ds$recvMsgNo, ds$recvMsgNo),
			duplicates = c((ds$recvMsgNo - 1), (ds$recvMsgNo - 1)),
			positionedAt = c(as.character(ds$positionedAt), rep("All", length(ds$positionedAt))),
      algorithm=rep(algorithmN, length(ds$recvMsgNo)*2), stringsAsFactors=F
    ),
    args$resultsDir, 'recvBroadcastMsgsDistribution', algorithmN
  )
}


# # creates a list of wireless topologies using nodes positions (ground thruth)
# if(args$wmob){
# 	overlays <- lapply(msgs_ids, function( m ) {
# 		# senders/receivers per broadcast message
#     senders <- subset(sent_broadcast_msgs, value == msgs_ids[m])
#     receivers<-subset(recv_broadcast_msgs, value == msgs_ids[m])
# 		# get what type of FWD nodes perform
# 		fwdTypeAtTopology <- subset(
# 			forwardTypeDs, min(senders$time) <= time & time <= max(receivers$time)
# 		)
# 		# get positions of nodes during dissemination of broadcast message
#     nodesPositions <- positions[ ( (m - 1) * N + 1 ):( m * N ), ]
# 		# get the algorithm that nodes run during the dissemination of message: msgs_ids[o]
#     runningAlgoAtTopology <- runningAlgorithm[ ( (m - 1) * N + 1 ):( m * N ), ]
# 		# build wireless topology
# 		get.graph(
#       all_nodes, nodesPositions, args$tx, m, unique(receivers$node_id),
# 			fwdTypeAtTopology, runningAlgoAtTopology, savePlot=args$wplot
#     )
#   })
# } else {
# 	# get unique position in static scenario
# 	nodesPositions <- head(positions, n=N)
#   overlays <- lapply(msgs_ids, function( o ) {
# 		# senders/receivers per broadcast message
#     senders <- subset(sent_broadcast_msgs, value == msgs_ids[o])
#     receivers<-subset(recv_broadcast_msgs, value == msgs_ids[o])
# 		# get what type of FWD nodes perform
# 		fwdTypeAtTopology <- subset(forwardTypeDs, time <= max(senders$time))
# 		# get the algorithm that nodes run during the dissemination of message: msgs_ids[o]
# 		runningAlgoAtTopology <- tail( head( runningAlgorithm, n=o*N ), n=N )
#     # build wireless topology
#     get.graph(
#       all_nodes, nodesPositions, args$tx, o, unique(receivers$node_id),
# 			fwdTypeAtTopology, runningAlgoAtTopology, savePlot=args$wplot
#     )
#   })
# }
# save distribution of nodes per type of FWD they perform within the biggest
# connected graph (a component of a wireless topology)
sentCtrlMsgs <- getVector(datasetFile, 'sentCtrlFrames:vector')
recvCtrlMsgs <- getVector(datasetFile, 'recvCtrlFrames:vector')
if(args$wft){
	print('Get distribution of forwading types')
  saveDataFrame(
    get.node.roles(overlays, msgs_ids, algorithmN),
    args$resultsDir, 'noderoles', algorithmN
  )
}
if(args$wpe){
  print("DONE - Get packet error rate")
  pktErrorRate <- getStatistics(datasetFile, "packetErrorRate:histogram")
  saveDataFrame(
    data.frame(
      data=pktErrorRate$data * 100 , # in percetage
      algo=rep(algorithmN, length(pktErrorRate$data)), stringsAsFactors=F
    ),
    args$resultsDir, 'packetErrorRate', algorithmN
  )
}

if (args$wsre){
	print("DONE - Get saved rebroadcasts")
	savedRe <- sapply(msgs_ids, function( o ) {
    receivers <- subset(recv_broadcast_msgs, value == msgs_ids[o])$value
		getSavedRebroadcasts(overlays[[o]], receivers)
	})
	saveDataFrame(
    data.frame(
      data=savedRe,
      algo=rep(algorithmN, length(savedRe)), stringsAsFactors=F
    ),
    args$resultsDir, 'savedRebroadcasts', algorithmN
  )
}
print('End of get-broadcast-metrics.R')
