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

doPlot <- function(ds, yLabel, yLim, leftPos=NULL, density="Zero"){
  ds.m <- melt(ds, id.var="Algorithm")
  if (is.null(leftPos)) {
    p <- ggplot(data = ds.m, aes(x=variable, y=value)) + geom_boxplot(aes(fill=Algorithm)) +
      theme(legend.position = "none") + ylim(c(0, yLim)) + ylab("") + xlab("") + 
      ggtitle(density)
  } else if (leftPos) {
    p <- ggplot(data = ds.m, aes(x=variable, y=value)) + geom_boxplot(aes(fill=Algorithm)) +
      theme(legend.position = "none") + ylim(c(0, yLim)) + ylab(yLabel) + xlab("") + 
      ggtitle(density)
  } else {
    p <- ggplot(data = ds.m, aes(x=variable, y=value)) + geom_boxplot(aes(fill=Algorithm)) +
      theme(legend.position = "none") + ylim(c(0, yLim)) + ylab("") + xlab("") +
      ggtitle(density)
  }
  p
}

getPlotInfo <- function() {
  title <- "Power consumption of nodes per broadcast session"
  xLabe <- "Broadcast Session ID"
  yLabe <- "Joules (J)"
  pInfo <- as.data.frame(matrix(seq(3*4), nrow=3, ncol=4))
  names(pInfo) <- c("powerC", "relNum", "dupMsg", "broSeT")
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

getYlimits <- function(files) {
  c("powerC", "relNum", "dupMsg", "broSeT")
  yLimits<- vector()
  yLimits<- c(yLimits, getYlimit(files$powerC))
  yLimits<- c(yLimits, getYlimit(files$relNum))
  yLimits<- c(yLimits, getYlimit(files$dupMsg))
  yLimits<- c(yLimits, getYlimit(files$broSeT))
  df <- as.data.frame(matrix(seq(4), nrow=1, ncol=4))
  names(df) <- c("powerC", "relNum", "dupMsg", "broSeT")
  df[1, ] <- yLimits
  df
}

verifyDensities <- function(datasetsDir) {
  b <- list.files(datasetsDir, pattern=paste(broaMetrics$powerC, "[a-z]*", sep=""))
  r <- list.files(datasetsDir, pattern=paste(broaMetrics$relNum, "[a-z]*", sep=""))
  d <- list.files(datasetsDir, pattern=paste(broaMetrics$dupMsg, "[a-z]*", sep=""))
  br<- list.files(datasetsDir, pattern=paste(broaMetrics$broSeT, "[a-z]*", sep=""))
  if ( length(pmax(r, b, d, br)) != length(pmin(r, b, d, br)) ) {
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
  l <- list(b, r, d, br)
  names(l) <- c("powerC", "relNum", "dupMsg", "broSeT")
  l
}

getDensities <- function(files) {
  densities <- lapply(files, function(f) {
    unlist(strsplit(f, "_"))[2]
  })
  sort(unique(unlist(densities)), decreasing=T)
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
      if (i %% deNo == 1) {
        plotList[[length(plotList) + 1]] <- doPlot(ds, yLabel, yLimit, leftPos=T, density=d)
      } else if (i %% deNo == 0) {
        plotList[[length(plotList) + 1]] <- doPlot(ds, yLabel, yLimit, leftPos=F, density=d)
      } else {
        plotList[[length(plotList) + 1]] <- doPlot(ds, yLabel, yLimit, density=d)
      }
      i <- i + 1
    }
  }
  pdf(paste(args$datasets_dir, "plot.pdf", sep = "/"))
  multiplot(
    plotlist=plotList,
    layout=matrix(seq(1, length(plotList)), nrow=length(names(broaMetrics)), byrow=TRUE)
  )
}
broaMetrics <- data.frame(
  powerC = "batteryConsumption_",
  relNum = "numberOfRelays_",
  dupMsg = "duplicatedMsgs_",
  broSeT = "broadcastSessionTime_"
)
main(get.arguments())
