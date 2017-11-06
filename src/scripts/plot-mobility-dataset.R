library(reshape2)
library(ggplot2)

filter.data <- function(ds, node_id) {
	subSet <- subset(ds, nodeId == node_id)
	subSet$step[ 1 ] <- -1.0
	subset(subSet, step > 0)
	i <- c(0:500)*4 + 0.200000
	subset(subSet, step %in% i)
}

all.data <- function(ds, node_id) {
	subSet <- subset(ds, nodeId == node_id)
	subSet$step[ 1 ] <- -1.0
	subset(subSet, step > 0)
}

ds <- read.table("mobility-dataset", sep=" ")
names(ds) <- c("nodeId", "time", "xPos", "yPos")
#steps <- unique(ds$step)
ds <- subset(ds, time <=200.0)

#xds <- data.frame(posAtx=ds$xPos, groupId=rep(toString(steps[1]), length(ds$xPos)))
#yds <- data.frame(posAty=ds$yPos)
px <- ggplot(data=ds, aes(x=xPos, group=time, colour=time)) + stat_ecdf(geom = "step") + labs(x="Abscissa", y="# of points", title="CDF of abscissas of nodes positions over time (from 0 to 200 seconds \nwhere peers moves every 100 ms)")

py <- ggplot(data=ds, aes(x=yPos, group=time, colour=time)) + stat_ecdf(geom = "step") + labs(x="Ordinate", y="# of points", title="CDF of ordinates of nodes positions over time (from 0 to 200 seconds \nwhere peers move every 100 ms)")

#px <- ggplot(data=xds, aes(x=posAtx)) + stat_ecdf(geom = "step") + labs(x="X", y="ECDF(X)", title="All points in mobility trace")
#py <- ggplot(data=yds, aes(x=posAty)) + stat_ecdf(geom = "step") + labs(x="Y", y="ECDF(Y)", title="All points in mobility trace")
plot(px)
plot(py)
stop()





sds1 <- all.data(ds, 4)

px <- ggplot(data=sds1, aes(x=step, y=xPos, group=nodeId, colour=nodeId)) + geom_line() +
  geom_point(size=0.5) + labs(x="Time [s]", y="Ordinate", title="All points in mobility trace")

py <- ggplot(data=sds1, aes(x=step, y=yPos, group=nodeId, colour=nodeId)) + geom_line() +
  geom_point(size=0.5) + labs(x="Time [s]", y="Abscissa", title="All points in mobility trace")
print(px)
print(py)
stop()

sds2 <- filter.data(ds, 2)


sds3 <- filter.data(ds, 3)
sds4 <- filter.data(ds, 4)
sds5 <- filter.data(ds, 5)
sds6 <- filter.data(ds, 6)
resu <- data.frame(
	nodeId=c(sds1$nodeId, sds2$nodeId, sds3$nodeId, sds4$nodeId, sds5$nodeId, sds6$nodeId),
	xPos=c(sds1$xPos, sds2$xPos, sds3$xPos, sds4$xPos, sds5$xPos, sds6$xPos),
	yPos=c(sds1$yPos, sds2$yPos, sds3$yPos, sds4$yPos, sds5$yPos, sds6$yPos)
)

p <- ggplot(data=resu, aes(x=xPos, y=yPos, group=nodeId, colour=nodeId)) + geom_line() +
  geom_point(size=0.5) + labs(x="ordinate", y="abscissa", title="Using Levy flight of size 5") +
	scale_x_continuous(limits=c(0,400)) +
	scale_y_continuous(limits=c(0,400)) 

print(p)
