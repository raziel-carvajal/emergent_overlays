require(omnetpp)
library(igraph)

getAvgEnergyConsumption <- function(msgs, isSent = T) {
	if (length(msgs) == 0) {
		NA
	} else {
		# constant cost in watts
		cost <- data.frame(sent = .1, recv = .01)
		cons <- sapply(unique(msgs$node_id), function(n){
			length(subset(msgs, node_id == n)$value) * ifelse(isSent, cost$sent, cost$recv)
		})
		mean(cons)
	}
}

getRecvMsgsOverTime <- function(msgs, timeLine) {
	metrics <- lapply(timeLine, function(t){
		ds <- subset(msgs, time >= t$limInf & time < t$limSup)
		nos<- sapply(unique(ds$node_id), function(n){
			length(subset(ds, node_id == n)$value)
		})
		data.frame(
			time = t$limInf,
			data = ifelse(is.na(mean(nos)), 0, mean(nos))
		)
	})
	do.call('rbind', metrics)
}

getWattsFromSentRecvMsgs <- function(sentMsgs, recvMsgs, sentCtrlFrames, recvCtrlFrames, timeLine){
	metrics <- lapply(timeLine, function(t){
		sentM <- subset(sentMsgs, time >= t$limInf & time < t$limSup)
		recvM <- subset(recvMsgs, time >= t$limInf & time < t$limSup)
		sentF <- subset(sentCtrlFrames, time >= t$limInf & time < t$limSup)
		recvF <- subset(recvCtrlFrames, time >= t$limInf & time < t$limSup)
		data.frame(
			time = t$limSup,
			consumption = sum(
				getAvgEnergyConsumption(sentM),
				getAvgEnergyConsumption(recvM, isSent = F),
				getAvgEnergyConsumption(sentF),
				getAvgEnergyConsumption(recvF, isSent = F), na.rm = T
			)
		)
	})
	do.call('rbind', metrics)
}

getRunningAlogrithm <- function(runAlgoDs, simTime) {
	algosMap <- c('MPR', 'CF')
	algos <- unique(runAlgoDs$value)
	records <- unique(runAlgoDs$time)
	d <- 10
	timeLine <- lapply(1:floor(simTime / d), function(i){
		data.frame(limInf = (i -1) * d, limSup = i * d)
	})
	metrics <- lapply(timeLine, function(t){
		ts <- head(records[records < t$limSup], 1)
		sDs <- subset(runAlgoDs, time == ts)
		temp <- lapply(algos, function(a){
			data.frame(
				time = t$limInf,
				algo = algosMap[a],
				nodes= length(subset(sDs, value == a[1])$value)
			)
		})
		do.call('rbind', temp)
	})
	do.call('rbind', metrics)
}

getLocalCoverage <- function(overlay, senders, withBorderNode = NA) {
	if( is.na(withBorderNode) ){ # all graph
		# ground thruth of receptions
		sum( sapply(senders, function(s) { length(neighbors(overlay, s)) }) )
	} else { # in 2 partitions
		sendersAtSparse <- senders[ senders < withBorderNode ]
		if(length(sendersAtSparse) != 0){
			atSparse <- sum( sapply(sendersAtSparse, function(s) { length(neighbors(overlay, s)) }) )
		} else {
			atSparse <- NA
		}
		sendersAtDense <- senders[ senders >= withBorderNode ]
		if(length(sendersAtDense) != 0){
			atDense <- sum( sapply(sendersAtDense, function(s) { length(neighbors(overlay, s)) }) )
		} else {
			atDense <- NA
		}
		data.frame(sparse = atSparse, dense = atDense)
	}
}

getGlobalCoverage <- function(overlays, withBorderNode = NA) {
	# all graph
	if( is.na(withBorderNode) ){
	  sapply(overlays, function(overlay) {
			max(components(overlay)$csize)
	  })
	} else { # in 2 partitions
		lapply(overlays, function(overlay) {
			components <- components(overlay)$membership
			atSparse <- sapply( c(1 : (withBorderNode - 1)), function(i) {
				ifelse(components[i] == 1, 1, 0)
			})
			atDense <- sapply( c(withBorderNode:length(components)), function(i) {
				ifelse(components[i] == 1, 1, 0)
			})
			data.frame(sparse = sum(atSparse), dense = sum(atDense))
	  })
	}
}

getStatistics <- function(dataset_path, scalar_name, stat="mean"){
  all_stats <- loadDataset(
    paste(dataset_path, sep= ".", "sca"),
    add(select=paste("name", "(", scalar_name, ")", sep=""))
  )

  node_ids <- toString(all_stats$statistics$module)
  node_ids <- strsplit(unlist(strsplit(node_ids, "\\.")), "host")
  node_ids <-unlist(
    lapply(node_ids, function(id_str){
      tmp <- ifelse( length(id_str) == 2, id_str[2], NA )
      tmp[!is.na(tmp)]
    })
  )

  key_id_map <- data.frame(
    key = all_stats$statistics$resultkey,
    node_id = as.numeric(node_ids)
  )

  scalar <- subset(all_stats$fields, fieldname == stat)
  data.frame(
    node_id = key_id_map$node_id,
    data = subset(scalar, resultkey == key_id_map$key)$fieldvalue
  )
}

getSavedRebroadcasts <- function(overlay, recvMsgs) {
	subG <- components(overlay)$membership
	nodes <- sapply( c(1:length(subG)), function( i ) {
		ifelse(subG[i] == 1, i, NA)
	})
	nodes <- nodes[!is.na(nodes)]
	floodingRetrans <- sapply(nodes, function( n ) {
		length(neighbors(overlay, n))
	})
	floodingRetrans <- sum(floodingRetrans)
	measuredRetrans <- length(recvMsgs)
	100 - (measuredRetrans * 100) / floodingRetrans
}
