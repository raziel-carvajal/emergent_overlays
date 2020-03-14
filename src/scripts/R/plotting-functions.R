library(ggplot2)
library(plyr)
library(e1071)
library(grid)
library(reshape2)
library(Cairo)

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

plot.dist.as.cdf <- function(ds, title, xlabel, ylabel, xLim) {
	p <- ggplot(ds, aes(x = data, linetype = region))
  p <- p + stat_ecdf(aes(y = ..y..*100), size = 0.5)
	p <- p + scale_linetype_manual(
		labels = c("All", "At PoI", "Out of PoI"),
		values = c('dotdash', 'solid', 'dotted')
	)
	# p <- p + scale_x_continuous(breaks = seq(0, ceiling(max(ds$data)), by = 1))
	p <- p + labs(y = ylabel, x = xlabel)
	p <- p + ylim(0, 100) + xlim(xLim[1], xLim[2])
  p + ggtitle(title)
}

plotCDFset <- function(ds, title, xlabel, ylabel, xLim) {
	p <- ggplot(ds, aes(x = data, color = sample))
  p <- p + stat_ecdf(aes(y = ..y..*100), size = 0.5)
	p <- p + labs(y = ylabel, x = xlabel)
	p <- p + ylim(0, 100) + xlim(xLim[1], xLim[2])
  p + ggtitle(title)
}

plotRunAlgoOverTime <- function(ds, xlabel, ylabel){
	p <- ggplot(
		data = ds,
		aes(x = time, y = nodes, group = algo)
	)
	p <- p + geom_col(aes(fill = algo), colour = 'black')
	p <- p + geom_text(
		aes(label = c('100\nCF', nodes[2:(length(nodes)-1)], '67\nMPR') ),
		position = position_stack(vjust = 0.5),
		size = 3
	)
	p <- p + scale_fill_manual(
		values = c("#ffffff", "grey90")
	)
	# p <- p + geom_text(
	# 	data = ds,
	# 	aes(x = time, y = nodes, label = paste0(nodes,"%")),
  # 	size = 4, position = position_stack(vjust = 0.5)
	# )
	p <- p + scale_x_continuous(
		# limits = c(0, 125),
		breaks = seq(0, 120, by = 20)
	)

	p <- p + labs(x = xlabel, y = ylabel)
	p + theme0()
}

plotOverTime <- function(ds, title, xlabel, ylabel, xLims, yLims){
	p <- ggplot(data = ds, aes(x = time, y = data, linetype = region))
	p <- p + geom_line()
	p <- p + geom_point()

	p <- p + scale_x_continuous(
		limits = c(xLims$min, xLims$max),
		breaks = seq(xLims$min, xLims$max, by = xLims$step)
	)
	p <- p + scale_y_continuous(
		limits = c(yLims$min, yLims$max),
		breaks = seq(yLims$min, yLims$max, by = yLims$step)
	)

	p + labs(x = xlabel, y = ylabel) + ggtitle(title)
}

plotOverTimeAlg <- function(ds, xlabel, ylabel, ylim, ybr){
	p <- ggplot(data = ds, aes(
		x = time, y = data, linetype = algo
	))
	p <- p + geom_line()
	p <- p + geom_point()

	p <- p + scale_x_continuous(
		limits = c(0, 120),
		breaks = seq(0, 120, by = 20)
	)
	p <- p + scale_y_continuous(
		limits = ylim,
		breaks = ybr
	)

	p <- p + labs(x = xlabel, y = ylabel)
	p + theme2()
}

plot.data.using.boxes <- function(ds, title, xlabel, ylabel) {
	p <- ggplot(data = ds, aes(x = algorithm, y = data, fill = region) )
	p <- p + geom_boxplot()
	p <- p + scale_fill_manual(
		labels = c("All", "At PoI", "Out of PoI"),
		values = c("#cccccc", "#666666", "#ffffff")
	)
	# "MPR3" = expression(MPR['\u0394=30']))
	p <- p + scale_x_discrete(
		labels = c(
			"HYBRID1" = expression('Emerg Ovl'),
			"ADAPTIVECF" = expression('Adaptive CF'),
			"SCOPEDHYPFLOOD" = expression('S-H Flood')
		)
	)
	p <- p + theme_Publication() + labs(y = ylabel) + ylim(0, max(ds$data))
	cairo_pdf(file="plot.pdf")
  print(p)
	dev.off()
}
