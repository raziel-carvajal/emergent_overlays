require(ggplot2)
require(reshape2)

doPlot <- function(ds, title, xLabel, yLabel, yLim){
	ds.m <- melt(ds, id.var="Algorithm")
	p <- ggplot(data = ds.m, aes(x=variable, y=value, color=Algorithm)) + geom_boxplot(aes(fill=Algorithm))	+
	  ggtitle(title) + ylab(yLabel) + xlab(xLabel) + ylim(yLim)
        print(p)
}

#  pdf(paste(args[1], "Results.pdf", sep = ""), width=17, height=8)
#    # create layout for this metric
#    layout(m_layout, heights=c(0.8,0.8,0.8))
#    par(mai = c(0.7,0.6,1.2,0.6))


#m_layout <- matrix(1:3, 1, 3, byrow=T)
pdf(paste("../../results/", "Results.pdf", sep = ""), width=8, height=8)
# create layout for this metric
#layout(m_layout, heights=c(0.8,0.8, 0.8))
#par(mai = c(0.7,0.6,1.2,0.6))

yLim = c(0, 5)
bc <- read.csv("../../results/RadioModeReception-Zero", header=T)
doPlot(bc, "Received messages per interval of reception - Small Network (7 nodes)", "Interval of reception", "Number of received messages", yLim)

stop()
yLim = c(48, 50)
bc <- read.csv("../../results/batteryConsumption-Zero", header=T)
doPlot(bc, "Residual energy - Small Network (7 nodes)", "Time (s)", "Joules (J)", yLim)
#bc <- read.csv("../../results/batteryConsumption-CDSpaper", header=T)
#doPlot(bc, "Battery consumption - CDS Paper Network (15 nodes)", "Time (s)", "Joules (J)", yLim)

yLim = c(0, 350)
bs <- read.csv("../../results/broadcastSessionTime-Zero", header=T)
doPlot(bs, "Broadcast Dissemination Delay - Small Network (7 nodes)", "Broadcast ID", "Time (ms)", yLim)
#bs <- read.csv("../../results/broadcastSessionTime-CDSpaper", header=T)
#doPlot(bs, "Broadcast Dissemination Delay - CDS Paper Network (15 nodes)", "Broadcast ID", "Time (ms)", yLim)

yLim = c(0, 6)
dm <- read.csv("../../results/duplicatedMsgs-Zero", header=T)
doPlot(dm, "Duplicated Broadcast Msgs - Small Network (7 nodes)", "Broadcast ID", "Duplicated Msgs", yLim)

#dm <- read.csv("../../results/duplicatedMsgs-CDSpaper", header=T)
#doPlot(dm, "Duplicated Broadcast Msgs - CDS Paper Network (15 nodes)", "Broadcast ID", "Duplicated Msgs", yLim)

yLim = c(0, 10)
nr <- read.csv("../../results/numberOfRelays-Zero", header=T)
doPlot(nr, "Number Of Relays Per Broadcast Msg - Small Network (7 nodes)", "Broadcast ID", "Relays", yLim)

#nr <- read.csv("../../results/numberOfRelays-CDSpaper", header=T)
#doPlot(nr, "Number Of Relays Per Broadcast Msg - CDS Paper Network (15 nodes)", "Broadcast ID", "Relays", yLim)
