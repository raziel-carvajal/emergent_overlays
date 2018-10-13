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

get.plot.theme.style <- function() {
  theme(plot.title=element_text(hjust = 0.5)) +
  theme(text=element_text(size=14)) +
  theme(
    panel.background = element_rect(fill = 'white', colour = 'black'),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border     = element_blank()
  )
}

# TODO plot DENSE and SPARSE distribution in one plot
# + scale_alpha_manual(values = c(0.3, 1))
# guides(fill=guide_legend(title='Type:'), alpha=guide_legend(title='Zone:'))
plot.nodes.roles.distribution <- function(ds) {
  names(ds) <- c('count', 'fw_type', 'zone', 'algorithm')
  denseDs <- subset(ds, zone == 'DENSE')
  sparsDs <- subset(ds, zone == 'SPARSE')
  sparsP <- ggplot(sparsDs)
  denseP <- ggplot(denseDs)
  p1 <- sparsP + geom_col(aes(x=algorithm, y=count, fill=fw_type)) +
    ggtitle('Forwarding nodes in sparse zone') + get.plot.theme.style() +
    xlab('Algorithm') + ylab('Nodes (%)') + guides(fill=guide_legend(title='Type'))
  p2 <- denseP + geom_col(aes(x=algorithm, y=count, fill=fw_type)) +
    ggtitle('Forwarding nodes in dense zone') + get.plot.theme.style() +
    xlab('Algorithm') + ylab('Nodes (%)') + guides(fill=guide_legend(title='Type'))
  print(p1)
  print(p2)
}

plot.dist.as.cdf <- function(ds, title, xlabel, ylabel) {
	p <- ggplot(ds, aes(x=data, colour=algorithm, linetype=algorithm)) +
		stat_ecdf(geom="step", lwd=1.5) +
		ggtitle(title) + labs(x=xlabel, y=ylabel) +
		scale_x_continuous(expand=c(0,0), limits=c(0, max(ds$data))) +
		scale_y_continuous(expand=c(0,0), limits=c(0, 1)) + get.plot.theme.style()
	print(p)
}

plot.data.using.boxes <- function(ds, title, xlabel, ylabel) {
	p <- ggplot(data=ds, aes(x=algorithm, y=data, colour=algorithm))
  p <- p + geom_boxplot() +
    stat_summary(
      fun.y=mean, colour="blue", geom="point", shape=18, size=3, show_guide = FALSE
    )
  p <- p + ggtitle(title) + labs(x=xlabel, y=ylabel) + get.plot.theme.style() +
    theme(legend.position='none')
  print(p)
}

args <- get_arguments()
metadata = NULL
separate_dist = TRUE

if (!is.null(args$pc)) {
  print('Plotting power consumption')
  ds <- read.table( paste(args$path, args$pc, sep=''), header=F)
  names(ds) <- c('data', 'algorithm')
  plot.data.using.boxes(ds, 'Energy consumption', 'Algorithm', 'Milli Joules (mJ)')
  plot.dist.as.cdf(
    ds, 'Energy consumption',
    'Milli Joules (mJ)', 'CDF over nodes'
  )
  print('DONE')
}

if (!is.null(args$nodes_roles)) {
  print('Plotting distribution of nodes roles')
  ds <- read.table( paste(args$path, args$nodes_roles, sep=''), header=F)
  plot.nodes.roles.distribution(ds)
  print('DONE')
}

if (!is.null(args$sent_bro)) {
  print('Plotting sent broadcast messages')
  ds <- read.table( paste(args$path, args$sent_bro, sep=''), header=F)
  names(ds) <- c('data', 'zone', 'algorithm')
  msgAtDenseZ  <- subset(ds, zone == 'DENSE')
  msgAtSparseZ <- subset(ds, zone == 'SPARSE')
  plot.dist.as.cdf(
    msgAtDenseZ, 'Sent Broadcast Messages within Dense Zone',
    'Number of Messages', 'CDF over broadcast sessions'
  )
  plot.dist.as.cdf(
    msgAtSparseZ, 'Sent Broadcast Messages within Sparse Zone',
    'Number of Messages', 'CDF over broadcast sessions'
  )
  print('DONE')
}

if (!is.null(args$recv_bro)) {
  print("Plotting received broadcast messages")
  ds <- read.table( paste(args$path, args$recv_bro, sep=''), header=F)
  names(ds) <- c('data', 'zone', 'algorithm')
  msgAtDenseZ  <- subset(ds, zone == 'DENSE')
  msgAtSparseZ <- subset(ds, zone == 'SPARSE')
  plot.dist.as.cdf(
    msgAtDenseZ, 'Received Broadcast Messages within Dense Zone',
    'Number of Messages', 'CDF over broadcast sessions'
  )
  plot.dist.as.cdf(
    msgAtSparseZ, 'Received Broadcast Messages within Sparse Zone',
    'Number of Messages', 'CDF over broadcast sessions'
  )
  print('DONE')
}

if (!is.null(args$sent_ctrl)) {
  print('Ploting sent ctrl messages')
  ds <- read.table( paste(args$path, args$sent_ctrl, sep=''), header=F)
  names(ds) <- c('data', 'algorithm')
  plot.dist.as.cdf(
    ds, 'Sent Ctrl Messages (dense & sparse area)',
    'Number of Messages', 'CDF over Ctrl sessions'
  )
  print('DONE')
}

if (!is.null(args$recv_ctrl)) {
  print('Plotting received ctrl messages')
  ds <- read.table( paste(args$path, args$recv_ctrl, sep=''), header=F)
  names(ds) <- c('data', 'algorithm')
  plot.dist.as.cdf(
    ds, 'Received Ctrl Messages (dense & sparse area)',
    'Number of Messages', 'CDF over Ctrl sessions'
  )
  print('DONE')
}

if (!is.null(args$cv)) {
  print('Ploting network coverage')
  ds <- read.table( paste(args$path, args$cv, sep=''), header=F)
  names(ds) <- c('data', 'algorithm')
  plot.dist.as.cdf(
    ds, 'Network Coverage of Broadcast Sessions',
    '% of Covered Nodes', 'CDF over broadcast sessions'
  )
  print('DONE')
}


if (!is.null(args$dre)) {
  print('Plotting density relative error')
  ds <- read.table( paste(args$path, args$dre, sep=''), header=F)
  names(ds) <- c('data', 'zone', 'algorithm')
  msgAtDenseZ  <- subset(ds, zone == 'DENSE')
  msgAtSparseZ <- subset(ds, zone == 'SPARSE')
  plot.dist.as.cdf(
    msgAtDenseZ, 'Relative Error of Nodes Neighbors No in Dense Zone',
    'Relative Error', 'CDF over nodes'
  )
  plot.dist.as.cdf(
    msgAtSparseZ, 'Relative Error of Nodes Neighbors No in Sparse Zone',
    'Relative Error', 'CDF over nodes'
  )
  print('DONE')
}

if (!is.null(args$cre)) {
  print('Plotting relative error of collisions')
  ds <- read.table( paste(args$path, args$cre, sep=''), header=F)
  names(ds) <- c('data', 'zone', 'algorithm')
  msgAtDenseZ  <- subset(ds, zone == 'DENSE')
  msgAtSparseZ <- subset(ds, zone == 'SPARSE')
  plot.dist.as.cdf(
    msgAtDenseZ, 'Collisions of Recieved Broadcast Messages in Dense Zone',
    'Relative Error', 'CDF over broadcast sessions'
  )
  plot.dist.as.cdf(
    msgAtSparseZ, 'Collisions of Recieved Broadcast Messages in Sparse Zone',
    'Relative Error', 'CDF over broadcast sessions'
  )
  print('DONE')
}

# TODO deal with old format to store broadcast session time
# if (!is.null(args$bs)) {
#   print("Importing broadcast time dataset")
#   r <- load.dataset.with.metadata(args$path, args$bs, metadata, args$excluded.densities)
#   metadata <- r$metadata
#   print("Plotting broadcast time")
#   plot.dist.as.cdf(r$data, "Broadcast session time (ms)")
# }
# if (!is.null(args$run_algo)) {
#   print("Importing distribution of running algorithms")
#   r <- load.dataset.with.metadata(args$path, args$run_algo, metadata, args$excluded.densities)
#   print("Plotting distribution of running algorithms")
#   plot.running.algorithms.distri(r$data)
# }
