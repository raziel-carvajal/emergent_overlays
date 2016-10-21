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

plot.errorBars <- function(matriz, pal, d, ylimit) {
  print('Doing plotting rigth now...')
  algos <- matriz[, 1]
  y <- as.numeric( matriz[, 2] )
  sd <-as.numeric( matriz[, 3] )
  #plot(y, ylim = range( c(y - sd, y + sd) ),
  plot(y, ylim = ylimit,
    pch = 19, xlab="Protocol", ylab="Mean +/- SD",
    main = paste("Density ", d), axes = FALSE
  )
  axis(2)
  axis(1, at = seq_along(y),labels = algos)
  arrows(1:length(algos), y - sd, 1:length(algos), y + sd, length = 0.05, angle = 90, code = 3)
  box()
}

plot.cdf <- function(df, key, it, c, d){
  print('Doing plotting rigth now...')
  H <- ecdf( df[[ key ]][, 1] )
  X <- df[[ key ]][, 1]
  Y <- H(X)
  if (it == 0) {
    plot( y = Y, x = X, xlim = range(0, 2000), type = 'p', col = c, xlab = "Time (ms)", main = paste("Density ", d))
  } else {
    lines(y = Y, x = X, xlim = range(0, 2000), type = 'p', col = c)
  }
}

plot.metric <- function(df, metric, dfNames, sizes, algos, pal, plotHeader) {
  for (s in sizes) {
    print( paste('Nodes:', s, sep = '') )
    #for (d in c('sparse', 'medium', 'dense')) {
    
	for (d in c('5')) {
	  print( paste('Density:', d, sep = '') )
	  pos <- grep(paste("n_", s, "_d_", d, sep = ''), dfNames)
	  keys <- unlist( lapply(pos, function(i) { dfNames[i] }) )
	  it <- 0
	  tmp <- matrix(0, length(algos), 3)
	  for (a in algos) {
		print( paste('Algorithm:', a, sep = '') )
		j <- head(grep(a, keys), 1)
		if (metric == "broadcastSessTime") { plot.cdf(df, keys[j], it, pal[a], d) }
		if (metric == "batteryConsuption" || metric == "duplBroadcastMsgs") {
		
		  avg <- df[[ keys[j] ]][, 1][1]
		  std <- df[[ keys[j] ]][, 1][2]
		  tmp[it + 1, ] <- c(a, avg, std)
		}
		it <- it + 1
	  }
	  if (metric == "batteryConsuption") { plot.errorBars(tmp, pal, d, range(0, -5)) }
	  if (metric == "duplBroadcastMsgs") { plot.errorBars(tmp, pal, d, range(0 , 8)) }
	  legend(x="topright", legend=algos, col=rainbow( length(algos) ), lty=sapply(algos, function(d) 1 ))
	}
	mtext(plotHeader, outer = TRUE, cex = 1, line = -2 )
  }
}

plot.broadcasting.time <- function(df, pal){
  print('Doing plotting rigth now...')
  for (d in c('5','10','15')) {
	  dd <- df[grepl(paste("d",d,sep="_"), sapply(df, function(e) colnames(e) ))]
	  data <- unname(dd)
	  algos <- lapply(lapply(data, colnames), function(e) {
	  		s <- unlist( strsplit(e,'_'))
	  		s[which(s == "p") + 1]	
	  })  
	  t <- lapply(data, function(e) e[,1] )
	  xli <- range( min(sapply(t, min))  , max(sapply(t, max)))
	  for (i in 1:length(t) ) {
	  	plot.ecdf(t[[i]], xlim = xli, col = pal[algos[[i]]], xlab = "Time (ms)", add=(i>1), main = paste("Density ", d))
	  }
	  legend(x="topright", legend=algos, col=rainbow( length(algos) ), lty=sapply(algos, function(d) 1 ))
  }
  mtext("ECDF Maximal reception delay", outer = TRUE, cex = 1, line = -2 )
}

plot.power.consumption <- function(df, algos, pal) {
	for (d in c('5','10', '15')) {
		dd <- df[grepl(paste("d",d,sep="_"), sapply(df, function(e) colnames(e) ))]
		dd <- lapply(dd, function(e) -1*e[,1])
		#dd[[1]][,1] <- dd[[1]][,1]*-1
		data <- do.call("cbind", dd)
		print(data)
		print(unlist(algos))
		boxplot(data, names=algos, main=(paste("Density", d)))	
	}
	mtext("Box plot of power consumption", outer = TRUE, cex = 1, line = -2 )
}

plot.duplicated.messages <- function(df) {
	for (d in c('5','10', '15')) {
		dd <- df[grepl(paste("d",d,sep="_"), sapply(df, function(e) colnames(e) ))]
		#dd[[1]][,1] <- dd[[1]][,1]*-1
		data <- do.call("cbind", dd)
		print(data)
		print(unlist(algos))
		boxplot(data, names=algos, main=(paste("Density", d)))	
	}
	mtext("Box plot of AVG duplicated messages", outer = TRUE, cex = 1, line = -2 )
	
	#dd <- lapply(df, function(e) {
	#	s <- unlist( strsplit(colnames(e),'_'))
	#	data.frame(
	#		d = s[which(s == "d") + 1],
	#		p = s[which(s == "p") + 1],
	#		m = e[,1][1],
	#		sd = e[,1][2]
	#	)
	#})
	
	#data <- do.call("rbind", dd)
	#for (d in c('5','10', '15')) {
	#	dm <- data[data$d == d,]
	#	print( paste('Density:', d, sep = '') )
	#	y <- as.numeric( dm$m )
	#	sd <-as.numeric( dm$sd )
		#plot(y, ylim = range( c(y - sd, y + sd) ),
	#	yl <- range( min(dm$m) - max(dm$sd), max(dm$m) + max(dm$sd) )
	#	plot(y, ylim = yl,
	#	pch = 19, xlab="Protocol", ylab="Mean +/- SD",
	#	main = paste("Density ", d), axes = FALSE
	#	)
	#	axis(2)
	#	axis(1, at = seq_along(y),labels = dm$p)
	#	arrows(1:length(dm$p), y - sd, 1:length(dm$p), y + sd, length = 0.05, angle = 90, code = 3)
	#	box()
		
	#}
}

args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 4) {
  bcDFile <- paste(args[1], args[2], sep = '') # load battery consumption time
  dmFile <- paste(args[1], args[3], sep = '') # duplicated messages file
  bsFile <- paste(args[1], args[4], sep = '') # broadcastting time
  
  print('Importing datasets...')
  dfBcD <- import.data(bcDFile)
  dfDm <- import.data(dmFile)
  dfBs <- import.data(bsFile)
  
  print(paste('Metrics to plot:',
    'maximal reception delay (CDF),',
    'avg of power consumption &',
    'avg of duplicated messages', sep = ' '
  ))
  # datasets headers, algorithms and number of peers are the same for each
  # dataset file
  dfNames <- names(dfBcD)
  sizes <- get.attrSet(dfNames, "n")
  print('Broadcast protocols: ')
  algos <- get.attrSet(dfNames, "p")
  print(algos)
  # setting attributes to plot
  m_layout <- matrix(1:3, 1, 3, byrow=TRUE)
  pal <- rainbow( length(algos) )
  names(pal) <- algos
  pdf(paste(args[1], "Results.pdf", sep = ""), width=17, height=8)
  # create layout for this metric
  layout(m_layout, heights=c(0.8,0.8,0.8))
  par(mai = c(0.7,0.6,1.2,0.6))
  print('Plotting: avg power consumption')
  
  #plot.metric(dfBc, "batteryConsuption", dfNames, sizes, algos, pal, "AVG power consumption")
  
  plot.power.consumption(dfBcD, algos, pal)
  
  plot.duplicated.messages(dfDm)
  
  plot.broadcasting.time(dfBs,pal)
  #plot.metric(dfBs, "broadcastSessTime", dfNames, sizes, algos, pal, "CDF of broadcasting session time")
}
