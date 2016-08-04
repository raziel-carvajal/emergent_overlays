import.data <- function(fileName) {
  data <- readLines(fileName)
  closeAllConnections()
  start <- grep("n_", data)
  mark <- vector('integer', length(data))
  mark[start] <- 1
  # determine limits of each table
  mark <- cumsum(mark)
  split(data, mark)
  # split the data for reading
  df <- lapply(split(data, mark), function(.data) {
    .input <- read.table(textConnection(.data), header=TRUE)
    attr(.input, 'name') <- .data[1]  # save the name
    .input
  })
  # rename the list
  names(df) <- sapply(df, attr, 'name')
  df
}

get.attrSet <- function(dfNames, attri) {
  set <- unique (
    lapply(dfNames, function(name) {
      header <- unlist(strsplit(name, '\"'))
      item <- unlist(strsplit(header, '_'))
      if (attri == "p") {
        i <- tail(grep(attri, item), 1)
        if (i %% 2 == 1) { i <- i + 1 }
      } else { i <- head(grep(attri, item), 1) + 1 }
      item[i]
    })
  )
}

plot.errorBars <- function(matriz, pal, d) {
  algos <- matriz[, 1]
  y <- as.numeric( matriz[, 2] )
  sd <-as.numeric( matriz[, 3] )
  plot(y, ylim = range( c(y - sd, y + sd) ),
    pch = 19, xlab="Protocol", ylab="Mean +/- SD",
    main = paste("Density ", d), axes = FALSE
  )
  axis(2)
  axis(1, at = seq_along(y),labels = algos)
  arrows(1:length(algos), y - sd, 1:length(algos), y + sd, length = 0.05, angle = 90, code = 3)
  box()
}

plot.cdf <- function(df, key, it, c, d){
  H <- ecdf( df[[ key ]][, 1] )
  X <- df[[ key ]][, 1]
  Y <- H(X)
  if (it == 0) {
    plot( y = Y, x = X, type = 'p', col = c, xlab = "Time (ms)", main = paste("Density ", d))
  } else {
    lines(y = Y, x = X, type = 'p', col = c)
  }
}

plot.metric <- function(df, metric, dfNames, sizes, algos, pal, plotHeader) {
  for (s in sizes) {
    for (d in c('sparse', 'medium', 'dense')) {
      pos <- grep(paste("n_", s, "_d_", d, sep = ''), dfNames)
      keys <- unlist( lapply(pos, function(i) { dfNames[i] }) )
      it <- 0
      avgs <- c()
      stds <- c()
      tmp <- matrix(0, length(algos), 3)
      for (a in algos) {
        j <- head(grep(a, keys), 1)
        if (metric == "broadcastSessTime") { plot.cdf(df, keys[j], it, pal[a], d) }
        if (metric == "batteryConsuption" || metric == "duplBroadcastMsgs") {
          avg <- df[[ keys[j] ]][, 1][1]
          std <- df[[ keys[j] ]][, 1][2]
          tmp[it + 1, ] <- c(a, avg, std)
        }
        it <- it + 1
      }
      if (metric == "batteryConsuption" || metric == "duplBroadcastMsgs") { plot.errorBars(tmp, pal, d) }
      legend(x="topright", legend=algos, col=rainbow( length(algos) ), lty=sapply(algos, function(d) 1 ))
    }
    mtext(plotHeader, outer = TRUE, cex = 1, line = -2 )
  }
}

args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 4) {
  bcFile <- paste(args[1], args[2], sep = '')
  dmFile <- paste(args[1], args[3], sep = '')
  bsFile <- paste(args[1], args[4], sep = '')
  
  dfBc <- import.data(bcFile)
  dfDm <- import.data(dmFile)
  dfBs <- import.data(bsFile)

  # datasets headers, algorithms and number of peers are the same for each
  # dataset file
  dfNames <- names(dfBs)
  sizes <- get.attrSet(dfNames, "n")
  algos <- get.attrSet(dfNames, "p")

  # setting attributes to plot
  m_layout <- matrix(1:3, 1, 3, byrow=TRUE)
  pal <- rainbow( length(algos) )
  names(pal) <- algos
  pdf(paste(args[1], "Results", sep = ""), width=17, height=8)
  # create layout for this metric
  layout(m_layout, heights=c(0.8,0.8,0.8))
  par(mai = c(0.7,0.6,1.2,0.6))
  
  plot.metric(dfBc, "batteryConsuption", dfNames, sizes, algos, pal, "AVG power consumption")
  #plot.metric(dfDm, "duplBroadcastMsgs", dfNames, sizes, algos, pal, "AVG duplicated messages")
  plot.metric(dfBs, "broadcastSessTime", dfNames, sizes, algos, pal, "CDF of broadcasting session time")
}
