library(ggplot2)
library(plyr)
library(argparse)

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

#
# Used to define the arguments of the script
#
get_arguments <- function() {
  parser <- ArgumentParser(description='Process some integers')
  parser$add_argument('-p', '--path', dest='path', type="character",
                      help='Path to result files')
  parser$add_argument('-pc', '--power-consumption-file', dest='pc', type="character",
                      help='Power consumption file name')
  parser$add_argument('-dm', '--duplicated-messages-file', dest='dm', type="character",
                      help='Duplicated messages file name')
  parser$add_argument('-bs', '--broadcast-session-file', dest='bs', type="character",
                      help='Broadcast session file name')
  parser$add_argument('-pctime', '--power-consumption-time-file', dest='pctime', type="character",
                      help='useless')
  # parser$print_help()
  parser$parse_args()
}

#
# Extract metadata such as the protocols, the densities and a palette for plotting
#
extract.metadata <- function(data) {
  dfNames <- names(data)
  algos <- get.attrSet(dfNames, "p")
  densities <- as.numeric(unlist(get.attrSet(dfNames, "d")))
  densities <- densities[order(densities)]
  pal <- rainbow( length(algos) )
  names(pal) <- algos
  l <- list(algos, densities, pal)
  names(l) <- c("algos","densities", "pal")
  l
}

load.dataset.with.metadata <- function(path, filename, metadata) {
  file <- paste(path, filename, sep = '') # load battery consumption
  data <- import.data(file)
  if (is.null(metadata)) {
    metadata = extract.metadata(data)
    pdf(paste(path, "Pretty-Results.pdf", sep = ""), width=4*length(metadata$densities), height=8)
  }
  l <- list(data, metadata)
  names(l) <- c("data", "metadata")
  l
}

args <- get_arguments()
metadata = NULL

if (!is.null(args$pc)) {
  print("Importing power consumption dataset")
  r <- load.dataset.with.metadata(args$path, args$pc, metadata)
  metadata <- r$metadata
  print("Plotting power consumption")
  plot.power.consumption(r$data, metadata$algos, metadata$densities, metadata$pal)
}

if (!is.null(args$pc)) {
  print("Importing duplicated messages dataset")
  r <- load.dataset.with.metadata(args$path, args$dm, metadata)
  metadata <- r$metadata
  print("Plotting duplicated messages")
  plot.duplicated.messages(r$data, metadata$densities)
}

if (!is.null(args$bs)) {
  print("Importing broadcast time dataset")
  r <- load.dataset.with.metadata(args$path, args$bs, metadata)
  metadata <- r$metadata
  print("Plotting broadcast time")
  plot.broadcasting.time2(r$data, metadata$densities, metadata$pal)
}
