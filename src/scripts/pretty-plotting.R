library(ggplot2)
library(plyr)

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
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)

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

      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
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


plot.broadcasting.time2 <- function(df, densities, pal){
  print('Plotting ECDF of broadcasting time ...')
  data.list <- lapply(densities, function(density) {
	  dd <- df[grepl(paste("d", density, "tr", sep="_"), sapply(df, function(e) colnames(e) ))]
	  dd <- lapply(dd, function(e) {
			cn <- colnames(e)[1]
			s <- unlist( strsplit(cn,'_'))
	  	cn <- s[which(s == "p") + 1]
			data <-e[,1]
      den <-rep(as.factor(paste("Density", density)), length(data))
			data.frame( dat = data, alg = rep(cn, length(data)), density=den  )
	  })
	  dd <- unname(dd)
	  data <- do.call("rbind", dd)

	  data <- arrange(data, density, alg, dat)
	  data.ecdf <- ddply(data, .(alg), transform, ecdf=ecdf(dat)(dat) )

    data.ecdf
  })

  data <- do.call("rbind", data.list)

  p <- ggplot( data, aes(dat, ecdf, colour = alg) ) +
      facet_grid(. ~ density) +
      theme(legend.position="bottom") +
      xlab("Time (ms)") +
      labs(title="Maximum delay time", colour="Algorithms") +
      theme(plot.title=element_text(size=15, vjust=3)) +
      theme(plot.margin = unit(c(1,1,1,1), "cm")) +
      geom_step()

  print(p)
}

plot.power.consumption <- function(df, algos, densities, pal) {
	data.list <- lapply(densities, function(density) {

		dd <- df[grepl(paste("d",density, "tr",sep="_"), sapply(df, function(e) colnames(e) ))]
		dd <- lapply(dd, function(e) {
			cn <- colnames(e)[1]
			s <- unlist( strsplit(cn,'_'))
	  	cn <- s[which(s == "p") + 1]
			data <- -1*e[,1]
			data.frame( dat = data,
						alg = rep(cn, length(data)),
						density=rep(as.factor(paste("Density", density)), length(data))
					  )
		})

		do.call("rbind", dd)
	})

	data <- do.call("rbind", data.list)

	p <- ggplot(data) +
		 geom_boxplot(aes(x=alg, y=dat, fill=alg)) +
		 facet_grid(. ~ density) +
		 theme(legend.position="bottom") +
		 ylab("Power Consumption (J)") + xlab("Algortihm") +
		 labs(title="Power consumption for different algorithms", fill="Algorithms") +
		 theme(plot.title=element_text(size=15, vjust=3)) +
		 theme(plot.margin = unit(c(1,1,1,1), "cm"))

	print(p)
}

plot.time.power.consumption <- function(df, algos, densities, pal) {
	data.list <- lapply(densities, function(density) {

		dd <- df[grepl(paste("d",density, "tr",sep="_"), sapply(df, function(e) colnames(e) ))]
		dd <- lapply(dd, function(e) {
			cn <- colnames(e)[1]
			s <- unlist( strsplit(cn,'_'))
	  	cn <- s[which(s == "p") + 1]
			data <- e[,1]
			data.frame( dat = data,
						alg = rep(cn, length(data)),
						density=rep(as.factor(paste("Density", density)), length(data))
					  )
		})

		do.call("rbind", dd)
	})

	data <- do.call("rbind", data.list)

	p <- ggplot(data) +
		geom_boxplot(aes(x=alg, y=dat, fill=alg)) +
		facet_grid(. ~ density) +
		theme(legend.position="bottom") +
		ylab("Last Time Power Consumption was reported (S)") +
		xlab("Algortihm") +
		labs(title="Last time power consumption was reported (DEBUG ONLY)", fill="Algorithms") +
		theme(plot.title=element_text(size=15, vjust=3)) +
		theme(plot.margin = unit(c(1,1,1,1), "cm"))

	print(p)
}

plot.duplicated.messages <- function(df, densities) {
	data.list <- lapply(densities , function(density) {
		dd <- df[grepl(paste("d", density, "tr", sep="_"), sapply(df, function(e) colnames(e) ))]
		dd <- lapply(dd, function(e) {
			cn <- colnames(e)[1]
			s <- unlist( strsplit(cn,'_'))
	  	cn <- s[which(s == "p") + 1]
			data <- e[,1]
			data.frame( dat = data,
						alg = rep(cn, length(data)),
						density=rep(as.factor(paste("Density", density)), length(data))
					  )
		})

		do.call("rbind", dd)
	})

	data <- do.call("rbind", data.list)

	p <- ggplot(data) +
		 geom_boxplot(aes(x=alg, y=dat, fill=alg)) +
		 facet_grid(. ~ density) +
		 theme(legend.position="bottom") +
		 ylab("AVG duplicated messages") +
		 xlab("Algortihm") +
		 labs(title="AVG duplicated messages", fill="Algorithms") +
		 theme(plot.title=element_text(size=15, vjust=3)) +
		 theme(plot.margin = unit(c(1,1,1,1), "cm"))

	print(p)
}

args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 5) {
  bcDFile <- paste(args[1], args[2], sep = '') # load battery consumption
  dmFile <- paste(args[1], args[3], sep = '') # duplicated messages file
  bsFile <- paste(args[1], args[4], sep = '') # broadcastting time
  tbcDFile <- paste(args[1], args[5], sep = '') # load time of battery consumption

  print('Importing datasets...')
  dfBcD <- import.data(bcDFile)
  dfDm <- import.data(dmFile)
  dfBs <- import.data(bsFile)
  dftbcD <- import.data(tbcDFile)

  print(paste('Metrics to plot:',
    'broadcasting session time (CDF),',
    'avg of power consumption &',
    'avg of duplicated messages', sep = ' '
  ))
  # datasets headers, algorithms and number of peers are the same for each
  # dataset file
  dfNames <- names(dfBcD)
  sizes <- get.attrSet(dfNames, "n")
  print('Broadcast protocols: ')
  algos <- get.attrSet(dfNames, "p")
  densities <- as.numeric(unlist(get.attrSet(dfNames, "d")))
  densities <- densities[order(densities)]
  print(unlist(algos))
  # setting attributes to plot
  #m_layout <- matrix(1:3, 1, 3, byrow=TRUE)
  pal <- rainbow( length(algos) )
  names(pal) <- algos
  pdf(paste(args[1], "Pretty-Results.pdf", sep = ""), width=4*length(densities), height=8)
  # create layout for this metric
  #layout(m_layout, heights=c(0.8,0.8,0.8))
  #par(mai = c(0.7,0.6,1.2,0.6))

  plot.power.consumption(dfBcD, algos, densities, pal)

  plot.time.power.consumption(dftbcD, algos, densities, pal)

  plot.duplicated.messages(dfDm, densities)

  plot.broadcasting.time2(dfBs, densities, pal)

}
