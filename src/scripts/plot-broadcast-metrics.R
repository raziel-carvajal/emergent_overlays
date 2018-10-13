library(ggplot2)
library(plyr)
library(argparse)
library(e1071)
library(grid)
library(reshape2)

get_arguments <- function() {
  parser <- ArgumentParser(description='Plot broadcast metrics.')

  parser$add_argument('resultsDir',  type="character")

  parser$add_argument('--plot-energy-consumption', dest='pc', action='store_true')
  parser$add_argument('--plot-coverage', dest='co', action='store_true')
  parser$add_argument('--plot-packet-err', dest='pe', action='store_true')
  parser$add_argument('--plot-sent-msgs', dest='sm', action='store_true')
  parser$add_argument('--plot-recv-msgs', dest='rm', action='store_true')

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

if (args$pc) {
  print('Plotting power consumption')
  ds <- read.table(
    paste(args$resultsDir, 'batteryConsumptionDistribution', sep=''),
    header=F
  )
  names(ds) <- c('data', 'algorithm')
  plot.data.using.boxes(ds, 'Energy consumption', 'Algorithm', 'Milli Joules (mJ)')
  plot.dist.as.cdf(
    ds, 'Energy consumption',
    'Milli Joules (mJ)', 'CDF over nodes'
  )
  print('DONE')
}

if (args$co) {
  print('Ploting network coverage')
  ds <- read.table(
    paste(args$resultsDir, 'coverage', sep=''),
    header=F
  )
  names(ds) <- c('data', 'algorithm')
  plot.dist.as.cdf(
    ds, 'Network Coverage',
    'Broadcast sessions (%)', 'Nodes'
  )
  print('DONE')
}

if (args$pe) {
  print('Ploting packet error rate')
  ds <- read.table(
    paste(args$resultsDir, 'packetErrorRate', sep=''),
    header=F
  )
  names(ds) <- c('data', 'algorithm')
  plot.dist.as.cdf(
    ds, 'Packet error rate',
    'Dropped packets (%)', 'Nodes'
  )
  print('DONE')
}

if (args$sm) {
  print("Plotting received broadcast messages")
  ds <- read.table(
    paste(args$resultsDir, 'recvBroadcastMsgsDistribution', sep=''),
    header=F
  )
  # names(ds) <- c('data', 'zone', 'algorithm')
  # msgAtDenseZ  <- subset(ds, zone == 'DENSE')
  # msgAtSparseZ <- subset(ds, zone == 'SPARSE')
  # plot.dist.as.cdf(
  #   msgAtDenseZ, 'Received Broadcast Messages within Dense Zone',
  #   'Number of Messages', 'CDF over broadcast sessions'
  # )
  # plot.dist.as.cdf(
  #   msgAtSparseZ, 'Received Broadcast Messages within Sparse Zone',
  #   'Number of Messages', 'CDF over broadcast sessions'
  # )
  print('DONE')
}

if (args$rm) {
  print('Plotting sent broadcast messages')
  ds <- read.table(
    paste(args$resultsDir, 'sentBroadcastMsgsDistribution', sep=''),
    header=F
  )
  # TODO
  # names(ds) <- c('data', 'zone', 'algorithm')
  # msgAtDenseZ  <- subset(ds, zone == 'DENSE')
  # msgAtSparseZ <- subset(ds, zone == 'SPARSE')
  # plot.dist.as.cdf(
  #   msgAtDenseZ, 'Sent Broadcast Messages within Dense Zone',
  #   'Number of Messages', 'CDF over broadcast sessions'
  # )
  # plot.dist.as.cdf(
  #   msgAtSparseZ, 'Sent Broadcast Messages within Sparse Zone',
  #   'Number of Messages', 'CDF over broadcast sessions'
  # )
  print('DONE')
}


# TODO
# if (!is.null(args$nodes_roles)) {
#   print('Plotting distribution of nodes roles')
#   ds <- read.table( paste(args$path, args$nodes_roles, sep=''), header=F)
#   plot.nodes.roles.distribution(ds)
#   print('DONE')
# }
# if (!is.null(args$sent_ctrl)) {
#   print('Ploting sent ctrl messages')
#   ds <- read.table( paste(args$path, args$sent_ctrl, sep=''), header=F)
#   names(ds) <- c('data', 'algorithm')
#   plot.dist.as.cdf(
#     ds, 'Sent Ctrl Messages (dense & sparse area)',
#     'Number of Messages', 'CDF over Ctrl sessions'
#   )
#   print('DONE')
# }
# if (!is.null(args$recv_ctrl)) {
#   print('Plotting received ctrl messages')
#   ds <- read.table( paste(args$path, args$recv_ctrl, sep=''), header=F)
#   names(ds) <- c('data', 'algorithm')
#   plot.dist.as.cdf(
#     ds, 'Received Ctrl Messages (dense & sparse area)',
#     'Number of Messages', 'CDF over Ctrl sessions'
#   )
#   print('DONE')
# }
# if (!is.null(args$dre)) {
#   print('Plotting density relative error')
#   ds <- read.table( paste(args$path, args$dre, sep=''), header=F)
#   names(ds) <- c('data', 'zone', 'algorithm')
#   msgAtDenseZ  <- subset(ds, zone == 'DENSE')
#   msgAtSparseZ <- subset(ds, zone == 'SPARSE')
#   plot.dist.as.cdf(
#     msgAtDenseZ, 'Relative Error of Nodes Neighbors No in Dense Zone',
#     'Relative Error', 'CDF over nodes'
#   )
#   plot.dist.as.cdf(
#     msgAtSparseZ, 'Relative Error of Nodes Neighbors No in Sparse Zone',
#     'Relative Error', 'CDF over nodes'
#   )
#   print('DONE')
# }
