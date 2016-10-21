require('omnetpp')

load.datafile <- function(fname, query, extensions=c("sca", "vec")) {
  ds <- loadVectors(loadDataset(paste(fname, sep= ".", extensions), add(type="vector", select=query) ), NULL)
}

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

exportDataset <- function(ds, dst){
  if (!file.exists(dst)) write.table(ds, file = dst, col.names = T, row.names = F, append = F, sep=",")
  else write.table(ds, file = dst, col.names = F, row.names = F, append = T, sep=",")
}

args <- commandArgs(trailingOnly=TRUE)
print(args)
if (length(args) == 5) {
  dsSrc <- args[1]
  dstDir <- args[2]
  sim.time <- strtoi(args[3])
  algoName <- args[4]
  density <- args[5]
  print(paste("Simulation time", sim.time, "seconds"))
  pl.step <- 3
  print(paste("Size of time inteval", pl.step, "seconds"))
  # get the intervals of time of two radio modes where:
  # - 2 means reception mode
  # - 3 means transmission mode
  # this script was tested with a dataset of ABBA and Floding just for reception mode
  #TODO: for protocols that send control messages (like CDS) this script gets an error
  #TODO: figure out why an error occurs when the transmission mode is analyzed
  radioMode <- load.datafile(dsSrc, "name(radioMode:vector)" )
  rcvM <- subset(radioMode$vectordata, y == 2)
  trsM <- subset(radioMode$vectordata, y == 3)
  msgSentDs <- load.datafile(dsSrc, "name(msg_sent:vector)" )
  msgRcvDs <- load.datafile(dsSrc, "name(broadcast_msg_received:vector)" )
  r <- countMsgsPerRadioMode(rcvM, msgRcvDs, algoName)
  dst <- paste(dstDir, "/RadioModeReception", sep="")
  dst <- paste(dst, density, sep="-")
  exportDataset(r, dst)
}
