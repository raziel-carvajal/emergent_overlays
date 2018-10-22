library(ggplot2)
library(argparse)
library(gridExtra)

get_arguments <- function() {
  parser <- ArgumentParser(description='Arrange plots of one metric within a grid.')

  parser$add_argument('-d', '--datasets', dest='d', type="character",
    help='File with list of datasets of one broadcast metric.')
  parser$add_argument('-n', '--name', dest='name', type="character",
    help='Name of plots grid.')

  parser$parse_args()
}

args <- get_arguments()
dsList <- read.table(args$d, header=F)
names(dsList) <- c('file', 'title', 'minLim', 'maxLim')

plots <- list()
for (i in 1:length(dsList$file)) {
  ds <- read.table(
    toString(dsList$file[i]), header=F
  )
  names(ds) <- c('data', 'algorithm')
  p <- ggplot(data=ds, aes(x=algorithm, y=data, colour=algorithm)) +
    geom_boxplot() +
    scale_y_continuous(limits=c(dsList$minLim[i], dsList$maxLim[i])) +
    stat_summary(
      fun.y=mean, colour="blue", geom="point", shape=18, size=3,
      show_guide = FALSE
    ) +
    ggtitle(dsList$title[i])
  if(i != length(dsList$file) ){
    plots[[i]] <- p + theme(legend.position='none')
  }else{
    plots[[i]] <- p
  }
}

pdf(paste(args$name, '.pdf', sep=''), width=15)
do.call("grid.arrange", c(plots, ncol=length(plots) ))
dev.off()
