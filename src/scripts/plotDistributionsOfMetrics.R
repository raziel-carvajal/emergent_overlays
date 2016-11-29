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

doPlot <- function(ds, yLabel, yLim, leftPos=NULL, density="Zero", metric) {
  ds.m <- melt(ds, id.var="Algorithm")
  if (metric == "collisions_" || metric == "dupMsg" || metric == "broSeT"){
    opt <- aes(x=variable, y=value)
    geomBx <- geom_boxplot(aes(fill=Algorithm))
  } else {
    opt <- aes(x=variable, y=value, colour=Algorithm)
    geomBx <- geom_boxplot(aes(fill=Algorithm))
  }
  if (is.null(leftPos)) {
    p <- ggplot(data = subset(ds.m, !is.na(value)), opt) + geomBx +
      theme(legend.position = "top") + ylim(c(0, yLim)) + ylab("") + xlab("") + 
      ggtitle(density)
  } else if (leftPos) {
    p <- ggplot(data = subset(ds.m, !is.na(value)), opt) + geomBx +
      theme(legend.position = "top") + ylim(c(0, yLim)) + ylab(yLabel) + xlab("") + 
      ggtitle(density)
  } else {
    p <- ggplot(data = subset(ds.m, !is.na(value)), opt) + geomBx +
      theme(legend.position = "top") + ylim(c(0, yLim)) + ylab("") + xlab("") +
      ggtitle(density)
  }
  p
}

getPlotInfo <- function() {
  title <- "Power consumption of nodes per broadcast session"
  xLabe <- "Broadcast Session ID"
  yLabe <- "Joules (J)"
  pInfo <- as.data.frame(matrix(seq(3*6), nrow=3, ncol=6))
  names(pInfo) <- c("powerC", "relNum", "dupMsg", "broSeT", "collisions_", "graphConnectivity_")
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
  yLimits<- c(yLimits, getYlimit(files$connec))
  #yLimits<- c(yLimits, getYlimit(files$collis))
  yLimits<- c(yLimits, 1)
  df <- as.data.frame(matrix(seq(6), nrow=1, ncol=6))
  names(df) <- c("powerC", "relNum", "dupMsg", "broSeT", "collisions_", "graphConnectivity_")
  df[1, ] <- yLimits
  df
}

verifyDensities <- function(datasetsDir) {
  b <- list.files(datasetsDir, pattern=paste(broaMetrics$powerC, "[a-z]*", sep=""))
  r <- list.files(datasetsDir, pattern=paste(broaMetrics$relNum, "[a-z]*", sep=""))
  d <- list.files(datasetsDir, pattern=paste(broaMetrics$dupMsg, "[a-z]*", sep=""))
  br<- list.files(datasetsDir, pattern=paste(broaMetrics$broSeT, "[a-z]*", sep=""))
  cl<- list.files(datasetsDir, pattern=paste("collisions_", "[a-z]*", sep=""))
  cn<- list.files(datasetsDir, pattern=paste("graphConnectivity_", "[a-z]*", sep=""))
  if ( length(pmax(r, b, d, br, cl, cn)) != length(pmin(r, b, d, br, cl, cn)) ) {
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
  cl<- paste(datasetsDir, cl,sep='/')
  cn<- paste(datasetsDir, cn,sep='/')
  l <- list(b, r, d, br, cl, cn)
  names(l) <- c("powerC", "relNum", "dupMsg", "broSeT", "collis", "connec")
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
      #if (metric == "powerC") {
      #  ds <- fixPowerConsDs(ds)
      #}
      yLabel <- plotInfo[[metric]][3]
      yLimit <- yLimits[[metric]]
      plotList[[length(plotList) + 1]] <- positionPlot(ds, yLabel, yLimit, d, deNo, i, metric)
      i <- i + 1
    }
    for (otherM in c("collisions_", "graphConnectivity_")) {
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
  pdf(paste(args$datasets_dir, "plot.pdf", sep = "/"),width=100, height=50)
  noMetrics <- length(names(broaMetrics))
  multiplot(
    plotlist=plotList,
    layout=matrix(seq(1, length(plotList)), nrow=noMetrics*2 + noMetrics, byrow=TRUE)
  )
}
broaMetrics <- data.frame(
  powerC = "batteryConsumption_",
  relNum = "numberOfRelays_",
  dupMsg = "duplicatedMsgs_",
  broSeT = "broadcastSessionTime_"
)
main(get.arguments())
