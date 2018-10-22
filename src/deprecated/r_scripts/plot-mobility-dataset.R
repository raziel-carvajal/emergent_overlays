library(reshape2)
library(ggplot2)

ds <- read.table("topologies/distribution-per-density", sep=" ")
names(ds) <- c("nodeId", "xPos", "yPos", "zone")
ds <- subset(subset(ds, zone == 1), nodeId <= 100)
pdf("x-dist.pdf")
px <- ggplot(data=ds, aes(x=xPos, group=nodeId, colour=nodeId)) + 
	stat_ecdf(geom = "step") + 
	labs(x="Abscissa", y="CDF of abscissas", 
	title="Node positions over time (where peers moves every 100 ms)")
plot(px)

pdf("y-dist.pdf")
px <- ggplot(data=ds, aes(x=yPos, group=nodeId, colour=nodeId)) + 
	stat_ecdf(geom = "step") + 
	labs(x="Ordinates", y="CDF of ordinates", 
	title="Node positions over time (where peers moves every 100 ms)")
plot(px)


