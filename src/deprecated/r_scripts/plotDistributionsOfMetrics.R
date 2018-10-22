require(ggplot2)
require(reshape2)
library(argparse)
library(grid)
library(gridExtra)

# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
# NOTE: this function was originally taken from the next site:
#   http://www.cookbook-r.com/Graphs/Multiple_graphs_on_one_page_%28ggplot2%29/
#   Some changes were performed
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  numPlots = length(plots)

  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
      ncol = cols, nrow = ceiling(numPlots/cols))
  }

   if (numPlots==1) {
    print(plots[[1]])
   } else {
     # Set up the page
     grid.newpage()
     pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
     # Make each plot, in the correct location
     for (i in 1:numPlots) {
       # Get the i,j matrix positions of the regions that contain this subplot
       matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
       print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row, layout.pos.col = matchidx$col))
     }
   }
}


get.arguments <- function() {
  a <- "This script plot the distribution of the next broadcast metrics: "
  b <- "broadcast session time, number of relays, power consumption and duplicated messages."
  r <- paste(a, b, sep=" ")
  parser <- ArgumentParser(description=r)
  parser$add_argument('datasets_dir', metavar='results-dir', type="character",
                      help='Path where the datasets of each distribution was kept.')
  parser$parse_args()
}

getMode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

getRepresentativeValueAsDs <- function(ds, metric='avg') {
  algos <- unique(ds[, 1])
  algos <- sort(algos)
  broSe <- length(names(ds)) - 1
  r <- 1
  nCol <- 2
  nRow <- broSe * length(algos)
  j <- 1
  df <- as.data.frame(matrix(seq(nCol*nRow), nrow=nRow, ncol=nCol))
  for (algo in algos) {
    for (ses in 1:broSe) {
      data <- subset(ds, Algorithm == algo)[, ses + 1]
      data <- data[!is.na(data)]
      if (metric == 'avg')
        v <- mean(data)
      else if (metric == 'mode')
        v <- getMode(data)
      df[r, ] <- c(j, v)
      r <- r + 1
    }
    j <- j + 1
  }
  names(df) <- c("Algorithm", "value")
  df$Algorithm <- factor(df$Algorithm, labels=algos)
  df
}

doPlot <- function(ds, yLabel, yLim, leftPos=NULL, density="Zero", metric) {
  ds <- getRepresentativeValueAsDs(ds)
  if (metric == "dupMsg" || metric == "broSeT" || metric == "relNum" || metric == "netCov" || metric == "rcvMsg" || metric=="senMsg")
    opt <- aes(x=Algorithm, y=value)
  else 
    opt <- aes(x=Algorithm, y=value, colour=Algorithm)
  geomBx <- geom_boxplot(aes(fill=Algorithm))
  if (is.null(leftPos)) {
    p <- ggplot(data = subset(ds, !is.na(value)), opt) + geomBx +
      theme(legend.position = "top") + ylim(c(0, yLim)) + ylab("") + xlab("") + 
      ggtitle(density)
  } else if (leftPos) {
    p <- ggplot(data = subset(ds, !is.na(value)), opt) + geomBx +
      theme(legend.position = "top") + ylim(c(0, yLim)) + ylab(yLabel) + xlab("") + 
      ggtitle(density)
  } else {
    p <- ggplot(data = subset(ds, !is.na(value)), opt) + geomBx +
      theme(legend.position = "top") + ylim(c(0, yLim)) + ylab("") + xlab("") +
      ggtitle(density)
  }
  p
}

getPlotInfo <- function() {
  title <- "Power consumption of nodes per broadcast session"
  xLabe <- "Broadcast Session ID"
  yLabe <- "Joules (J)"
  nCol  <- length(names(broaMetrics)) + 2
  pInfo <- as.data.frame(matrix(seq(3*nCol), nrow=3, ncol=nCol))
  names(pInfo) <- c(names(broaMetrics), "collisions_", "graphConnectivity_")
  pInfo$powerC <- c(title, xLabe, yLabe)
  title <- "Number of relays per broadcast session"
  yLabe <- "Relays"
  pInfo$relNum <- c(title, xLabe, yLabe)
  title <- "Number of duplicated messages per broadcast session"
  yLabe <- "Duplicated Messages"
  pInfo$dupMsg <- c(title, xLabe, yLabe)
  title <- "Broadcast session time per broadcast session"
  yLabe <- "Broadcast Session Time (ms)"
  pInfo$broSeT <- c(title, xLabe, yLabe)
  title <- "Network coverage per broadcast session"
  yLabe <- "Network coverage (%)"
  pInfo$netCov <- c(title, xLabe, yLabe)
  title <- "Received broadcast messages"
  yLabe <- "Number of received messages"
  pInfo$rcvMsg <- c(title, xLabe, yLabe)
  title <- "Sent broadcast messages"
  yLabe <- "Number of sent messages"
  pInfo$senMsg <- c(title, xLabe, yLabe)
  title <- "Proportion of collisions per broadcast session"
  yLabe <- "Percentage of collisions"
  pInfo$collisions_ <- c(title, xLabe, yLabe)
  title <- "Network connectivity"
  yLabe <- "Network connectivity"
  pInfo$graphConnectivity_ <- c(title, xLabe, yLabe)
  pInfo
}

getYlimit <- function(files){
  r <- lapply(files, function(f) {
    lapply(2:length(read.csv(f)[1, ]), function(col) {
      max(read.csv(f)[, col])
    })
  })
  max(unique(unlist(r)))
}

getYlimitForColiOrConn <- function(files){
  r <- lapply(files, function(f) {
    max(read.csv(f)[, 3])
  })
  max(unique(unlist(r)))
}

getYlimits <- function(files) {
  yLimits<- vector()
  yLimits<- c(yLimits, getYlimit(files$powerC))
  yLimits<- c(yLimits, getYlimit(files$relNum))
  yLimits<- c(yLimits, getYlimit(files$dupMsg))
  yLimits<- c(yLimits, getYlimit(files$broSeT))
  yLimits<- c(yLimits, getYlimit(files$netCov))
  yLimits<- c(yLimits, getYlimit(files$rcvMsg))
  yLimits<- c(yLimits, getYlimit(files$senMsg))
  yLimits<- c(yLimits, 1) # Collisions
  yLimits<- c(yLimits, getYlimit(files$connec))
  nCol  <- length(names(broaMetrics)) + 2
  df <- as.data.frame(matrix(seq(nCol), nrow=1, ncol=nCol))
  names(df) <- c(names(broaMetrics), "collisions_", "graphConnectivity_")
  df[1, ] <- yLimits
  df
}

verifyDensities <- function(datasetsDir) {
  b <- list.files(datasetsDir, pattern=paste(broaMetrics$powerC, "[a-z]*", sep=""))
  r <- list.files(datasetsDir, pattern=paste(broaMetrics$relNum, "[a-z]*", sep=""))
  d <- list.files(datasetsDir, pattern=paste(broaMetrics$dupMsg, "[a-z]*", sep=""))
  br<- list.files(datasetsDir, pattern=paste(broaMetrics$broSeT, "[a-z]*", sep=""))
  nc<- list.files(datasetsDir, pattern=paste(broaMetrics$netCov, "[a-z]*", sep=""))
  rm<- list.files(datasetsDir, pattern=paste(broaMetrics$rcvMsg, "[a-z]*", sep=""))
  sm<- list.files(datasetsDir, pattern=paste(broaMetrics$senMsg, "[a-z]*", sep=""))
  cl<- list.files(datasetsDir, pattern=paste("collisions_", "[a-z]*", sep=""))
  cn<- list.files(datasetsDir, pattern=paste("graphConnectivity_", "[a-z]*", sep=""))
  if ( length(pmax(r, b, d, br, cl, cn, nc, rm, sm)) != length(pmin(r, b, d, br, cl, cn, nc, rm, sm)) ) {
    msg1 <- "The network densities is not the same on each dataset. As a consequence, the final PDF"
    msg2 <- "could contain empty frames OR duplicated plots per page."
    msg <- paste(msg1, msg2, sep=" ")
    print(msg)
    print("Aborting...")
    stop()
  }
  b <- paste(datasetsDir, b, sep='/')
  r <- paste(datasetsDir, r, sep='/')
  d <- paste(datasetsDir, d, sep='/')
  br<- paste(datasetsDir, br,sep='/')
  nc<- paste(datasetsDir, nc,sep='/')
  rm<- paste(datasetsDir, rm,sep='/')
  sm<- paste(datasetsDir, sm,sep='/')
  
  cl<- paste(datasetsDir, cl,sep='/')
  cn<- paste(datasetsDir, cn,sep='/')

  l <- list(b, r, d, br, nc, rm, sm, cl, cn)
  names(l) <- c(names(broaMetrics), "collis", "connec")
  l
}

getDensities <- function(files) {
  densities <- lapply(files, function(f) {
    unlist(strsplit(f, "_"))[2]
  })
  sort(unique(unlist(densities)), decreasing=T)
}

positionPlot <- function(ds, yLabel, yLimit, d, mod, i, metric) {
  if (i %% mod == 1)
    p <- doPlot(ds, yLabel, yLimit, leftPos=T, density=d, metric)
  else if (i %% mod == 0)
    p <- doPlot(ds, yLabel, yLimit, leftPos=F, density=d, metric)
  else
    p <- doPlot(ds, yLabel,yLimit,leftPos=NULL,density=d, metric)
  p
}

fixPowerConsDs <- function(ds) {
  nCol <- length(ds[1, ]) - 1
  nRow <- length(ds[, 1])
  df <- as.data.frame(matrix(seq(nRow*nCol), nrow=nRow, ncol=nCol))
  for (r in 1:nRow) {
    veCol <- length(ds[r, ])
    v <- vector()
    for (vC in 2:veCol) {
      v <- c(v, ds[r, vC])
    }
    vCpy <- vector()
    vCpy <- c(vCpy, v)
    v[length(v)] <- NA
    v <- c(0.0, v)
    v <- v[!is.na(v)]
    df[r, ] <- abs(vCpy - v)
  }
  for (c in 1:nCol) {
    ds[, c + 1] <- df[, c]
  }
  ds
}

main <- function(args) {
  files <- verifyDensities(args$datasets_dir)
  plotInfo <- getPlotInfo()
  # getting densities from any broadcast metric is fine because at verifyDensities()
  # it was checked that every dataset contains the same number of densities
  densities<- getDensities(files$powerC)
  yLimits  <- getYlimits(files)
  fiNo <- length(files)
  deNo <- length(densities)
  plotList <- list()
  i <- 1
  for (metric in names(broaMetrics)) {
    fName <- paste(args$datasets_dir, broaMetrics[[metric]], sep='/')
    for (d in densities) {
      ds <- read.csv(paste(fName, d, sep=""), header=T)
      yLabel <- plotInfo[[metric]][3]
      yLimit <- yLimits[[metric]]
      plotList[[length(plotList) + 1]] <- positionPlot(ds, yLabel, yLimit, d, deNo, i, metric)
      i <- i + 1
    }
    #for (otherM in c("collisions_", "graphConnectivity_")) {
    for (otherM in c("collisions_")) {
      fName <- paste(args$datasets_dir, otherM, sep='/')
      for (d in densities) {
        ds <- read.csv(paste(fName, d, sep=""), header=T)
        yLabel <- plotInfo[[otherM]][3]
        yLimit <- yLimits[[otherM]]
        plotList[[length(plotList) + 1]] <- positionPlot(ds, yLabel, yLimit, d, deNo, i, otherM)
        i <- i + 1
      }
    }
  }
  pdf(paste(args$datasets_dir, "plot.pdf", sep = "/"), width=40, height=50)
  noMetrics <- length(names(broaMetrics))
  multiplot(
    plotlist=plotList,
    layout=matrix(seq(1, length(plotList)), nrow=noMetrics + noMetrics, byrow=TRUE)
  )
}
broaMetrics <- data.frame(
  powerC = "batteryConsumption_",
  relNum = "numberOfRelays_",
  dupMsg = "duplicatedMsgs_",
  broSeT = "broadcastSessionTime_",
  netCov = "networkCoverage_",
  rcvMsg = "rcvdMsgs_",
  senMsg = "sentMsgs_"
)
main(get.arguments())
