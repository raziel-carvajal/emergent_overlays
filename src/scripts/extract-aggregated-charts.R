

args <- commandArgs(trailingOnly=TRUE)
print(args)
if (length(args) == 2) {
	A <- read.table(args[1], sep=',')
	
	# sort base on the numbert of nodes
	A <- A[order(A$V3), ]

	# separate base on densities
	densities<- lapply( unique(A$V4), function(d) A[ A$V4 == d ,])

	# matrix for layout
	m_layout <- matrix(1:length(unique(A$V4)), 1, length(unique(A$V4)), byrow=TRUE)

	# create palette
	pal <- data.frame(
		p = unique(A$V2),
		color = rainbow(length(unique(A$V2)))
	)

	# create pdf
	pdf(args[2], width=17, height=8)

	# enumarate metrics
	metrics <- c("Coverage", "Broadcasting Time", "Power Level", "Duplicated Messages")
	col_idx <- c(5, 6, 7, 8)
	
	m.to.col <- data.frame( m = metrics, c = col_idx )

	for (m in metrics) {

		# create layout for this metric
		layout(m_layout, heights=c(0.8,0.8,0.8))

		# get column name
		cn <- m.to.col[ m.to.col$m == m ,]$c

		# plot
		for (d in densities) {
			
			mi <- min(d[[cn]])
			ma <- max(d[[cn]])

			yrange <- c(mi - 0.1*mi, ma + 0.1*ma )
			
			for (p in unique(d$V2)) {
				if (p == d[1,]$V2) {
					plot(d[ d$V2 == p,][[cn]], x=d[ d$V2 == p, ]$V3, type="b",ylim=yrange, col=pal[pal$p == p ,]$color, xlab="nr nodes", main=paste("Density", d[1,]$V4), ylab=m)
				} else {	
					lines(d[ d$V2 == p,][[cn]], x=d[ d$V2 == p, ]$V3, type="b", col=pal[pal$p == p ,]$color)
				}
				#print(pal[pal$p==p,]$color)
				#par(new=T)
			}
			legend(x="topright", legend=pal$p, col=pal$color, lty=sapply(pal$p, function(d) 1 ))
			#par(new=F)
		}

		mtext(paste("Charts showing the average", m), outer=TRUE,  cex=1, line=-0.5)

	}

	# close pdf
	dev.off()

}


