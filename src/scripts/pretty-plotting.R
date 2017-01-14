library(ggplot2)
library(plyr)
library(argparse)


#
# Used to define the arguments of the script
#
get_arguments <- function() {
  parser <- ArgumentParser(description='Plots the aggregated results of the experiments')
  parser$add_argument('path', metavar='path', type="character",
                      help='Path to result files')
  parser$add_argument('-pc', '--power-consumption-file', dest='pc', type="character",
                      help='Power consumption file name')
  parser$add_argument('-dm', '--duplicated-messages-file', dest='dm', type="character",
                      help='Duplicated messages file name')
  parser$add_argument('-bs', '--broadcast-session-file', dest='bs', type="character",
                      help='Broadcast session file name')
  parser$add_argument('-rf', '--relays-file', dest='rf', type="character",
                      help='Relays file name')
  parser$add_argument('-cv', '--coverage-file', dest='cv', type="character",
                      help='Coverage file name')
  parser$add_argument('-sf', '--summary-file', dest='sf', type="character",
                      help='Summary file name (should be * csv)')
  parser$add_argument('-pctime', '--power-consumption-time-file', dest='pctime', type="character",
                      help='useless')

  parser$add_argument('-final', '--final-version', dest='final', action="store_true",
                      help='If used, the script generates a version good enough for the paper')

  parser$add_argument('-ed', '--excluded-density', dest='excluded.densities', type='integer', action='append')

  # parser$print_help()
  parser$parse_args()
}


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


get.plot.theme.style <- function() {
  theme(plot.title=element_text(size=15, vjust=3)) +
  theme(plot.margin = unit(c(0.4,0.4,0.4,0.4), "cm")) +
  # all this is to remove the beautiful grid (not good for the paper :-( )
  theme(
    panel.background = element_rect(fill = 'white', colour = 'black')
    ,panel.grid.major = element_blank()
    ,panel.grid.minor = element_blank()
    ,panel.border = element_blank()
  )
}


plot.broadcasting.time2 <- function(df, densities, pal){
  print('Plotting ECDF of broadcasting time ...')
  data.list <- lapply(densities, function(density) {
	  dd <- df[grepl(paste("d", density, "tr", sep="_"), sapply(df, function(e) colnames(e) ))]
	  dd <- lapply(dd, function(e) {
    	cn <- colnames(e)[1]
    	s <- unlist( strsplit(cn,'_'))
        cn <- as.character(s[which(s == "p") + 1])
        cn <- toupper(gsub("[[:digit:]]", "", cn))
        cn <- replace(cn, cn == "CDS", "NODE-DEGREE")
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

  caption <- "Maximum delay time"

  p <- ggplot( data, aes(dat, ecdf, colour = alg) ) +
      facet_grid(. ~ density) +
      theme(legend.position="top", text=element_text(size=18)) +
      xlab("Time (ms)") +
      (if (print.titles)
 		   labs(title=caption, colour="Algorithms")
      else
        labs(colour="Algorithms")
      ) +
      get.plot.theme.style() +
      geom_step()

  print(p)
}

plot.data.using.boxes <- function(data, densities, ylabel, caption) {
  data.list <- lapply(densities, function(density) {

		dd <- data[grepl(paste("d",density, "tr",sep="_"), sapply(data, function(e) colnames(e) ))]
		dd <- lapply(dd, function(e) {
			cn <- colnames(e)[1]
			s <- unlist( strsplit(cn,'_'))
	  	    cn <- as.character(s[which(s == "p") + 1])
            cn <- toupper(gsub("[[:digit:]]", "", cn))
            cn <- replace(cn, cn == "CDS", "NODE-DEGREE")
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
		#  geom_boxplot(aes(x=alg, y=dat)) +
		 geom_boxplot(aes(x=alg, y=dat, fill=alg)) +
		 facet_grid(. ~ density) +
		 ylab(ylabel) +
    #  xlab("Algorithm") +
    #  theme(legend.position="none") +
     theme(legend.position="top", text=element_text(size=18)) +
     (if (print.titles)
      #  labs(title=caption, x=NULL)
       labs(title=caption, fill="Algorithms")
     else
       labs(fill="Algorithms")
     ) +
    #  theme(axis.title.x=element_blank(),axis.text.x = element_text(), axis.ticks.x=element_blank()) +
     get.plot.theme.style() +
     theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())
    if (!print.titles) {
        p <- p + scale_fill_grey(start = 0, end = .9)
    }
	print(p)
}

plot.data.using.lines <- function(data, densities, ylabel, caption, transformation) {
  data.list <- lapply(densities, function(density) {
		dd <- data[grepl(paste("d", density, "tr",sep="_"), sapply(data, function(e) colnames(e) ))]
		dd <- lapply(dd, function(e) {
			cn <- colnames(e)[1]
			s <- unlist( strsplit(cn,'_'))
	  	cn <- s[which(s == "p") + 1]
      cn <- toupper(gsub("[[:digit:]]", "", cn))
      cn <- replace(cn, cn == "CDS", "NODE-DEGREE")
      nr.nodes <- as.numeric(s[which(s == "n") + 1])
      y <- transformation(e[,1], nr.nodes)
      x <- 1:length(y)
      p <- data.frame( x = x, y = y )
      p <- lowess(x, y, f=1/10)
			data.frame( dat = p$y,
						alg = rep(cn, length(y)),
            idx = p$x,
						density=rep(as.factor(paste("Density", density)), length(y))
			)
		})

		do.call("rbind", dd)
	})

	data <- do.call("rbind", data.list)

	p <- ggplot(data) +
		 geom_line(aes(x=idx, y=dat, colour=alg)) +
		 facet_grid(. ~ density) +
		 theme(legend.position="top", text=element_text(size=18)) +
		 ylab(ylabel) + xlab("Broadcast Session") +
     (if (print.titles)
		   labs(title=caption, colour="Algorithms")
     else
       labs(colour="Algorithms")
     ) +
     get.plot.theme.style()

     if (!print.titles) {
         p <- p + scale_colour_grey(start = 0, end = .9)
     }

	print(p)
}


plot.saved_rebroadcast.per.session <- function(data, densities) {
  plot.data.using.lines(data, densities,
    "Saved rebroadcast messages", "Saved rebroadcast messages per session",
    function(d, nr.nodes) {
      rep(nr.nodes, length(d)) -  d
    }
  )
}

plot.coverage.per.session <- function(data, densities) {
  plot.data.using.lines(data, densities,
    "Coverage (%)", "Coverage per session",
    function(d, nr.nodes) {
      d/rep(nr.nodes, length(d))*100
    }
  )
}


plot.power.consumption <- function(df, densities) {
  plot.data.using.boxes(df, densities,
                        "Power Consumption (J)",
                        "Power consumption for different algorithms")
}

plot.time.power.consumption <- function(df, densities) {
  plot.data.using.boxes(df, densities,
                        "Last Time Power Consumption was reported (S)",
                        "Last time power consumption was reported (DEBUG ONLY)")
}

plot.duplicated.messages <- function(df, densities) {
  plot.data.using.boxes(df, densities,
                        "Duplicated messages",
                        "Distribution of duplicated messages along the experiment")
}

plot.saved.rebroadcasts <- function(df, algos) {
  ylabel <- "Saved Rebroadcasts"
  df <- do.call("rbind", lapply(algos, function(a) { df[which(df$alg == a),]  }))
  df$alg <- toupper(gsub("[[:digit:]]", "", df$alg))
  df$alg <- replace(df$alg, df$alg == "CDS", "NODE-DEGREE")

  df <- df[df$alg!="FLOODING",]


  caption <- "Saved rebroadcasts"
  p <- ggplot(df) +
		 geom_line(aes(x=density, y=saved.rebroadcasts, colour=alg), size=1.2) +
         geom_point(aes(x=density, y=saved.rebroadcasts, shape=alg, colour=alg), size = 4) +        # Large points
		 theme(legend.position="top", text=element_text(size=17)) +
		 ylab(ylabel) + xlab("Density") +
         (if (print.titles)
    		   labs(title=caption, colour="Algorithms", shape="Algorithms")
         else
           labs(colour="Algorithms", shape="Algorithms")
         ) +
		 get.plot.theme.style()


     if (!print.titles) {
         p <- p + scale_colour_grey(start = 0, end = .9)
     }

	print(p)
}


plot.simple.coverage <- function(df, algos) {
  ylabel <- "Coverage (%)"
  df <- do.call("rbind", lapply(algos, function(a) { df[which(df$alg == a),]  }))
  df$alg <- toupper(gsub("[[:digit:]]", "", df$alg))
  df$alg <- replace(df$alg, df$alg == "CDS", "NODE-DEGREE")
  caption <- "Coverage"
  p <- ggplot(df) +
		 geom_line(aes(x=density, y=coverage, colour=alg), size=1.2) +
         geom_point(aes(x=density, y=coverage, shape=alg, colour=alg),size = 4) +        # Large points
         theme(legend.position="top", text=element_text(size=14)) +
		 ylab(ylabel) + xlab("Density") +
         (if (print.titles)
    		   labs(title=caption, colour="Algorithms", shape="Algorithms")
         else
           labs(colour="Algorithms", shape="Algorithms")
         ) +
		 get.plot.theme.style()

     if (!print.titles) {
         p <- p + scale_colour_grey(start = 0, end = .9)
     }

	print(p)
}




#
# Extract metadata such as the protocols, the densities and a palette for plotting
#
extract.metadata <- function(data, excluded.densities) {
  dfNames <- names(data)
  algos <- get.attrSet(dfNames, "p")
  densities <- as.numeric(unlist(get.attrSet(dfNames, "d")))
  densities <- densities[order(densities)]
  f <- Vectorize(function(d) {  !(d %in% excluded.densities)  })
  densities <- densities[f(densities)]
  print (densities)
  print("mierda")
  pal <- rainbow( length(algos) )
  names(pal) <- algos
  l <- list(algos, densities, pal)
  names(l) <- c("algos","densities", "pal")
  l
}

load.dataset.with.metadata <- function(path, filename, metadata, excluded.densities=c()) {
  file <- paste(path, filename, sep = '') # load battery consumption
  data <- import.data(file)
  if (is.null(metadata)) {
    metadata = extract.metadata(data, excluded.densities)
    pdf(paste(path, "Pretty-Results.pdf", sep = ""), width=3.5*length(metadata$densities), height=4)
  }
  l <- list(data, metadata)
  names(l) <- c("data", "metadata")
  l
}

load.summary <- function(path, filename) {
  file <- paste(path, filename, sep = '')
  data <- read.csv(file, header=F)
  colnames(data) <- c("config", "protocols_fancy_name", "nodes", "density", "coverage", "bt", "pc", "dm", "relays")
  algos <- sapply(data$config, function(s) {
    s <- as.character(s)
    pp <- unlist(strsplit(s, split="_"))
    idx <- which(pp == "p")[1] + 1
    pp[idx]
  })
  data$alg <- algos
  data$saved.rebroadcasts <- data$nodes - data$relays
  data
}


args <- get_arguments()
metadata = NULL


# should plot titles?
print.titles <- !args$final


if (!is.null(args$pc)) {
  print("Importing power consumption dataset")
  r <- load.dataset.with.metadata(args$path, args$pc, metadata, args$excluded.densities)
  metadata <- r$metadata
  print("Plotting power consumption")
  plot.power.consumption(r$data, metadata$densities)
}


if (!is.null(args$rf)) {
  print("Importing relays dataset")
  r <- load.dataset.with.metadata(args$path, args$rf, metadata, args$excluded.densities)
  metadata <- r$metadata
  print("Plotting saved rebroadcasts")
  plot.saved_rebroadcast.per.session(r$data, metadata$densities)
}

if (!is.null(args$cv)) {
  print("Importing coverage dataset")
  r <- load.dataset.with.metadata(args$path, args$cv, metadata, args$excluded.densities)
  metadata <- r$metadata
  print("Plotting coverage")
  plot.coverage.per.session(r$data, metadata$densities)
}

if (!is.null(args$dm)) {
  print("Importing duplicated messages dataset")
  r <- load.dataset.with.metadata(args$path, args$dm, metadata, args$excluded.densities)
  metadata <- r$metadata
  print("Plotting duplicated messages")
  plot.duplicated.messages(r$data, metadata$densities)
}

if (!is.null(args$bs)) {
  print("Importing broadcast time dataset")
  r <- load.dataset.with.metadata(args$path, args$bs, metadata, args$excluded.densities)
  metadata <- r$metadata
  print("Plotting broadcast time")
  plot.broadcasting.time2(r$data, metadata$densities, metadata$pal)
}

# this most be the last
if (!is.null(args$sf)) {
  print("Importing summary CSV file")
  r <- load.summary(args$path, args$sf)
  print("Plotting Simple Saved Rebroadcasts")
  aa <- metadata$algos
  if (is.null(aa)) {
    aa <- unique(r$alg)
    pdf(paste(args$path, "Pretty-Results.pdf", sep = ""), width=7, height=4)
  }
  plot.saved.rebroadcasts(r, aa)
  print("Plotting Simple Coverage")
  plot.simple.coverage(r, aa)
}
