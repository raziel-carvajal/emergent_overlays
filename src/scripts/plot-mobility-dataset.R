library(reshape2)
library(ggplot2)

ds <- read.table("topologies/distribution-per-density", sep=" ")
names(ds) <- c("xPos", "yPos", "zone")

px <- ggplot(data=ds, aes(x=xPos, group=zone, colour=zone)) + stat_ecdf(geom = "step") + labs(x="Abscissa", y="Proportion of positions", title="CDF of abscissas of nodes positions over time (where peers moves every 100 ms)")
plot(px)

py <- ggplot(data=ds, aes(x=yPos, group=zone, colour=zone)) + stat_ecdf(geom = "step") + labs(x="Ordinates", y="Proportion of positions", title="CDF of ordinates of nodes positions over time (where peers moves every 100 ms)")
plot(py)
