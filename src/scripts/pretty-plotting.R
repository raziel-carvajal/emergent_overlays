library(ggplot2)
library(plyr)
library(argparse)
library(e1071)
library(grid)
library(reshape2)

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
  parser$add_argument('-dre', '--density-error-file', dest='dre', type="character",
                      help='File with the density relative error for each experiment')
  parser$add_argument('-cre', '--collisions-error-file', dest='cre', type="character",
                      help='File with the collisions relative error for each experiment')
  parser$add_argument('-ds', '--density-distribution', dest='ds', type="character",
                      help='Distribution of nodes density')

  parser$add_argument('-sent_bro', '--sent-broadcast-msgs', type="character",
                      help='Distribution of sent broadcast messages')
  parser$add_argument('-recv_bro', '--recv-broadcast-msgs', type="character",
                      help='Distribution of received broadcast messages')
  parser$add_argument('-nodes_roles', '--nodes-roles', type="character",
                      help='Distribution of nodes behaviour (relay or receiver)')

  parser$add_argument('-sent_ctrl', '--sent-control-msgs', dest="sent_ctrl",
                      type="character", help='Distribution of sent control messages')
  parser$add_argument('-recv_ctrl', '--recv-control-msgs', dest="recv_ctrl",
                      type="character", help='Distribution of received control messages')
  parser$add_argument('-run_algo', '--running-algorithms', dest="run_algo",
                      type="character", help='Distribution of running algorithm per nodes')
  parser$add_argument('-sf', '--summary-file', dest='sf', type="character",
                      help='Summary file name (should be * csv)')
  parser$add_argument('-pctime', '--power-consumption-time-file', dest='pctime', type="character",
                      help='useless')

  parser$add_argument('-final', '--final-version', dest='final', action="store_true",
                      help='If used, the script generates a version good enough for the paper')
  parser$add_argument('-violin', '--use-violin', dest='violin', action="store_true",
                      help='If used, the script generates a violin plots instead of box plots')

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
  theme(plot.margin = unit(c(0.5,0.5,0.5,0.5), "cm")) +
  # scale_fill_brewer(palette="RdBu") + theme_minimal()
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
        cn <- replace(cn, cn == "CDS", "CDS-based")
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


  # p <- ggplot( data, aes(dat, ecdf, colour = alg) ) +
  p <- ggplot( data ) +
      geom_line(aes(x=dat, y=ecdf, colour=alg, linetype=alg), size=1.1) +
      theme(legend.position="top", text=element_text(size=18)) +
      xlab("Broadcast session time (ms)") + ylab("Cumulative Probability") +
      scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0)) +
      (if (print.titles)
 		   labs(title=caption, colour="", linetype="")
      else
        labs(colour="", linetype="")
      ) +
      get.plot.theme.style() +
      scale_fill_brewer(palette="Set1") + scale_color_brewer(palette="Set1")

  N = length(unique(data$density))
  if (N > 1) {
    p <- p + facet_grid(. ~ density)
  }

  if (print.titles) {
      p <- p + scale_colour_grey(start = 0.3, end = .85)
  }

  print(p)
}

##
plot.nodes.roles.distribution <- function(data) {

	ds <- unname(lapply(data,
    function(e) {
  		ds_name <- unlist(strsplit(colnames(e), '_'))
      algo_name <- toupper(ds_name[ length(ds_name) ])
      data.frame(
        dist=unlist(e, use.names=F),
        algo=rep(algo_name, 3),
        type=c('Relay', 'Receiver', 'Unreachable'),
        stringsAsFactors=FALSE
      )
	  }
  ))
  ds <- do.call('rbind', ds)
  p <- ggplot(ds, aes(algo))
  p <- p + geom_bar(aes(weight=dist, fill=type)) + xlab('Algorithm') +
    theme(legend.position="top", text=element_text(size=18)) +
    ylab('Nodes (%)') + guides(fill=guide_legend(title='Type: '))

	print(p)
}

plot.running.algorithms.distri <- function(data) {

	data_t <- unname(unlist(sapply(data, function(e) {
		cn <- colnames(e)[1]
		s <- unlist( strsplit(cn,'_'))
		cn <- toupper(as.character(s[which(s == "p") + 1]))
		data <- e[,1]
		algos <- unique(data)
		unlist(sapply(algos, function(a){
			paste(cn, toString(a), length(data[data == a]), sep="_")
		}))
	})))

	data_t <- unname(t(as.data.frame(unname(sapply(data_t, function(d){
		strsplit(d, "_")
	})))))

	new_df <- data.frame(Experiment=data_t[,1], Nodes=as.numeric(data_t[,3]), Algorithm=data_t[,2])
	p <- ggplot(data=new_df, aes(x=Experiment, y=Nodes, fill=Algorithm, colour=Algorithm)) +
		geom_bar(stat="identity") + theme(legend.position="top", text=element_text(size=18)) +
		get.plot.theme.style() + scale_fill_brewer(palette="Set1") + scale_color_brewer(palette="Set1")

	print(p)
}

plot.data.using.lines <- function(data, densities, ylabel, caption, transformation, is_coverage=FALSE) {
  data.list <- lapply(densities, function(density) {
		dd <- data[grepl(paste("d", density, "tr",sep="_"), sapply(data, function(e) colnames(e) ))]
		dd <- lapply(dd, function(e) {
			cn <- colnames(e)[1]
			s <- unlist( strsplit(cn,'_'))
	  	cn <- s[which(s == "p") + 1]
      cn <- toupper(gsub("[[:digit:]]", "", cn))
      cn <- replace(cn, cn == "CDS", "CDS-based")
      cn <- replace(cn, cn == "MPRT", "MPR")
      nr.nodes <- as.numeric(s[which(s == "n") + 1])
      y <- transformation(e[,1], nr.nodes)
      x <- 1:length(y)
      p <- data.frame( x = x, y = y )
      p <- lowess(x, y, f=1/10)
      print(cn)
      print(summary(p$y))
			data.frame( dat = p$y,
						Algorithm = rep(cn, length(y)),
            idx = p$x,
						density=rep(as.factor(paste("Density", density)), length(y))
			)
		})

    dd <- unname(dd)
	  data <- do.call("rbind", dd)

    data <- arrange(data, density, Algorithm, dat)
	  data.ecdf <- ddply(data, .(Algorithm), transform, ecdf=ecdf(dat)(dat) )
    data.ecdf
	})
	data <- do.call("rbind", data.list)

  #N = length(unique(data$density))
  if (is_coverage)
    scale_x <- scale_x_continuous(expand=c(0,0))
  else
    scale_x <- scale_x_continuous(expand=c(0,0), limits=c(0, max(data$dat)))

	p <- ggplot(data, aes(x=dat, y=ecdf, colour=Algorithm, linetype=Algorithm)) +
		stat_ecdf(geom="step", lwd=1.5) + theme(legend.position="top", text=element_text(size=18)) +
		scale_x + scale_y_continuous(expand=c(0,0), limits=c(0, 1)) + get.plot.theme.style() +
		ylab("Nodes") + xlab(ylabel) + get.plot.theme.style()
	print(p)
}

###
plot.dist.as.cdf <- function(data, xlabel) {

	dd <- lapply(data, function(e) {
		cn <- colnames(e)[1]
		s <- unlist( strsplit(cn,'_'))
		cn <- toupper(as.character(s[which(s == "p") + 1]))
		dist <- e[,1]
		data.frame( dat = dist,
			Algorithm = rep(cn, length(dist))
		)
	})

  dd <- unname(dd)
  data <- do.call("rbind", dd)

	p <- ggplot(data, aes(x=dat, colour=Algorithm, linetype=Algorithm)) +
		stat_ecdf(geom="step", lwd=1.5) + theme(legend.position="top", text=element_text(size=18)) +
		labs(x=xlabel, y="Nodes") +
		scale_x_continuous(expand=c(0,0), limits=c(0, max(data$dat))) +
		scale_y_continuous(expand=c(0,0), limits=c(0, 1)) + get.plot.theme.style()

	print(p)
}
###
plot.neighbors.as.cdf <- function(data, run_algo_data, xlabel) {

	run_algo_ds <- lapply(run_algo_data, function(e) {
		cn <- colnames(e)[1]
		s <- unlist( strsplit(cn,'_'))
		cn <- toupper(as.character(s[which(s == "p") + 1]))
		if (cn == "HYBRID") {
			dist <- paste("HYBRID", e[,1], sep="-")
			data.frame( to_replace = dist)
		}
	})
	run_algo_ds <- unname(run_algo_ds)
	run_algo_ds <- do.call("rbind", run_algo_ds)

	dd <- lapply(data, function(e) {
		cn <- colnames(e)[1]
		s <- unlist( strsplit(cn,'_'))
		cn <- toupper(as.character(s[which(s == "p") + 1]))
		dist <- e[,1]
		data.frame( dat = dist,
			Algorithm = rep(cn, length(dist))
		)
	})

  dd <- unname(dd)
  data <- do.call("rbind", dd)
  indx <- which(data$Algorithm == "HYBRID")
  tmp <- as.character(data$Algorithm)
  data$Algorithm <- replace(tmp, indx, as.character(run_algo_ds$to_replace))

	p <- ggplot(data, aes(x=dat, colour=Algorithm, linetype=Algorithm)) +
		stat_ecdf(geom="step", lwd=1.5) + theme(legend.position="top", text=element_text(size=18)) +
		labs(x=xlabel, y="Nodes") +
		scale_x_continuous(expand=c(0,0), limits=c(0, max(data$dat))) +
		scale_y_continuous(expand=c(0,0), limits=c(0, 1)) + get.plot.theme.style()

	print(p)
}
###

plot.data.using.boxes <- function(data, densities, ylabel, caption, usebox=TRUE) {
  data.list <- lapply(densities, function(density) {

		dd <- lapply(data, function(e) {
			cn <- colnames(e)[1]
			s <- unlist( strsplit(cn,'_'))
	  	cn <- toupper(as.character(s[which(s == "p") + 1]))
			data <- e[,1]

      print(summary(data))
      print(var(data))
      print(skewness(data))

			data.frame( dat = data,
						Algorithm = rep(cn, length(data)),
						density=rep(as.factor(paste("Density", density)), length(data))
			)
		})
		do.call("rbind", dd)
	})

	data <- do.call("rbind", data.list)

	p <- ggplot(data=data, aes(x=Algorithm, y=dat, colour=Algorithm, fill=Algorithm, ymin=0, ymax=0))
  if (!usebox) {
    p <- p + geom_violin() +
          stat_summary(fun.y=mean, geom="point", size=4, fill="white", aes(x=alg, y=dat, shape=alg))
  }
  else {
	  meanV <- aggregate(dat ~ Algorithm, data, mean)
    p <- p + geom_boxplot() +
					stat_summary(fun.y=mean, colour="blue", geom="point", shape=18, size=3, show_guide = FALSE)
#					geom_text(data=meanV, aes(label=round(dat, digits=2), y = dat + 2))
  }

  p <- p +
		 ylab(ylabel) + scale_y_continuous(expand=c(0,0), limits=c(0, max(data$dat))) +
     theme(legend.position="top", text=element_text(size=18)) +
     get.plot.theme.style() +
     theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())
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
    	d
#      d/rep(nr.nodes, length(d)) * 100
    },
    TRUE
  )
}


plot.mac.frames.sent <- function(data, densities) {
  plot.data.using.lines(data, densities,
    "MAC frames sent", "MAC frames sent",
    function(d, nr.nodes) {
      d
    }
  )
}


plot.mac.frames.received <- function(data, densities) {
  plot.data.using.lines(data, densities,
    "MAC frames received", "MAC frames received",
    function(d, nr.nodes) {
      d
    }
  )
}

plot.time.power.consumption <- function(df, densities) {
  plot.data.using.boxes(df, densities,
                        "Last Time Power Consumption was reported (S)",
                        "Last time power consumption was reported (DEBUG ONLY)")
}

plot.duplicated.messages <- function(df, densities) {
  plot.data.using.boxes(df, densities,
                        "Duplicate messages",
                        "Distribution of duplicate messages along the experiment")
}

plot.saved.rebroadcasts <- function(df, algos) {
  ylabel <- "SRB (%)"
  df <- do.call("rbind", lapply(algos, function(a) { df[which(df$alg == a),]  }))
  df$alg <- toupper(gsub("[[:digit:]]", "", df$alg))
  df$alg <- replace(df$alg, df$alg == "CDS", "CDS-based")
  df$alg <- replace(df$alg, df$alg == "MPRT", "MPR")

  df <- df[df$alg!="FLOODING",]

  caption <- "% of Saved Rebroadcast"
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
		 get.plot.theme.style()+ scale_colour_brewer(palette="Set1") + scale_fill_brewer(palette="Set1")


     if (print.titles) {
         p <- p + scale_colour_grey(start = 0.3, end = .85)
     }

	print(p)
}


plot.simple.coverage <- function(df, algos) {
  ylabel <- "Coverage (%)"
  df <- do.call("rbind", lapply(algos, function(a) { df[which(df$alg == a),]  }))
  df$alg <- toupper(gsub("[[:digit:]]", "", df$alg))
  df$alg <- replace(df$alg, df$alg == "CDS", "CDS-based")
  df$alg <- replace(df$alg, df$alg == "MPRT", "MPR")
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
		 get.plot.theme.style()+ scale_colour_brewer(palette="Set1") + scale_fill_brewer(palette="Set1")

     if (print.titles) {
         p <- p + scale_colour_grey(start = 0.3, end = .85)
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
    metadata <- extract.metadata(data, excluded.densities)
    nr.elements <- length(metadata$densities)
    if (nr.elements < 2) {
      nr.elements <- 2;
    }
    pdf(paste(path, "Pretty-Results.pdf", sep = ""), width=4*nr.elements, height=4)
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
  nr.nodes <- data$nodes * data$coverage/100
  data$saved.rebroadcasts <- (nr.nodes - data$relays)/nr.nodes*100
  data
}

args <- get_arguments()
metadata = NULL
separate_dist = TRUE

if (!is.null(args$pc)) {
  print("Importing power consumption dataset")
  r <- load.dataset.with.metadata(args$path, args$pc, metadata, args$excluded.densities)
  metadata <- r$metadata
  print("Plotting power consumption")
  plot.data.using.boxes(r$data, metadata$densities,
                        "Energy Consumption (mJ)",
                        "Empirical Cumulative Distribution Function")

  plot.dist.as.cdf(r$data, "Energy Consumption (mJ)")
}

if (!is.null(args$nodes_roles)) {
  print("Importing distribution of nodes roles")
  r <- load.dataset.with.metadata(args$path, args$nodes_roles, metadata, args$excluded.densities)
  print("Plotting distribution of sent broadcast messages")
  plot.nodes.roles.distribution(r$data)
}

if (!is.null(args$sent_bro)) {
  print("Importing distribution of sent broadcast messages")
  r <- load.dataset.with.metadata(args$path, args$sent_bro, metadata, args$excluded.densities)
  print("Plotting distribution of sent broadcast messages")
  plot.dist.as.cdf(r$data, "No of Sent Broadcast Messages")
}



if (!is.null(args$sent_ctrl)) {
  print("Importing distribution of sent control messages")
  r <- load.dataset.with.metadata(args$path, args$sent_ctrl, metadata, args$excluded.densities)
  print("Plotting distribution of sent control messages")
  plot.dist.as.cdf(r$data, "Sent control messages")
}

if (!is.null(args$recv_bro)) {
  print("Importing distribution of received broadcast messages")
  r <- load.dataset.with.metadata(args$path, args$recv_bro, metadata, args$excluded.densities)
  print("Plotting distribution of received broadcast messages")
  plot.dist.as.cdf(r$data, "Received broadcast messages")
}

if (!is.null(args$recv_ctrl)) {
  print("Importing distribution of received control messages")
  r <- load.dataset.with.metadata(args$path, args$recv_ctrl, metadata, args$excluded.densities)
  print("Plotting distribution of received control messages")
  plot.dist.as.cdf(r$data, "Received control messages")
}

if (!is.null(args$cv)) {
  print("Importing coverage dataset")
  r <- load.dataset.with.metadata(args$path, args$cv, metadata, args$excluded.densities)
  metadata <- r$metadata
  print("Plotting coverage")
  plot.coverage.per.session(r$data, metadata$densities)
}

if (!is.null(args$rf)) {
  print("Importing relays dataset")
  r <- load.dataset.with.metadata(args$path, args$rf, metadata, args$excluded.densities)
  metadata <- r$metadata
  print("Plotting saved rebroadcasts")
  plot.saved_rebroadcast.per.session(r$data, metadata$densities)
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
  plot.dist.as.cdf(r$data, "Broadcast session time (ms)")
}

if (!is.null(args$dre)) {
  print("Importing density relative error dataset")
  r <- load.dataset.with.metadata(args$path, args$dre, metadata, args$excluded.densities)
  print("Plotting density relative error")
  plot.dist.as.cdf(r$data, "Approximation technique")
}

if (!is.null(args$cre)) {
  print("Importing collisions relative error dataset")
  r <- load.dataset.with.metadata(args$path, args$cre, metadata, args$excluded.densities)
  print("Plotting collisions relative error")
  plot.dist.as.cdf(r$data, "Relative error of received broadcast messages")
}

if (!is.null(args$ds)) {
	print("Importing distribution of density dataset")
  r <- load.dataset.with.metadata(args$path, args$ds, metadata, args$excluded.densities)
	print("Plotting distribution of density")
	if (!is.null(args$run_algo) & !is.null(args$run_algo) & separate_dist) {
	  rds <- load.dataset.with.metadata(args$path, args$run_algo, metadata, args$excluded.densities)
		plot.neighbors.as.cdf(r$data, rds$data, "Nodes' neighbors")
	} else {
		plot.dist.as.cdf(r$data, "Nodes' neighbors")
	}
}

if (!is.null(args$run_algo)) {
  print("Importing distribution of running algorithms")
  r <- load.dataset.with.metadata(args$path, args$run_algo, metadata, args$excluded.densities)
  print("Plotting distribution of running algorithms")
  plot.running.algorithms.distri(r$data)
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
