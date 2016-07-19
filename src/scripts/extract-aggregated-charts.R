

args <- commandArgs(trailingOnly=TRUE)
print(args)
if (length(args) == 2) {
	A <- read.table(args[1], sep=',')
	
	# sort base on the numbert of nodes
	A <- A[order(A$V3), ]

	# find protocols
	protocols <- unique(A$V2)
	print(protocols)

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
	col_factor <- c(0.1, 0.1, 0.005, 0.1)
	
	m.to.col <- data.frame( m = metrics, c = col_idx, f = col_factor )

	for (m in metrics) {

		# create layout for this metric
		layout(m_layout, heights=c(0.8,0.8,0.8))
		# get column name
		cn <- m.to.col[ m.to.col$m == m ,]$c
		factor <- m.to.col[ m.to.col == m, ]$f
		
		print(paste("============================", m, "=========================", sep=" "))
		# plot
		for (d in densities) {
			
			mi <- min(d[[cn]])
			ma <- max(d[[cn]])

			yrange <- c(mi - factor*mi, ma + factor*ma )
			par(mai = c(0.7,0.6,1.2,0.6))
			idx <- 0	
			for (p in protocols) {
				nr_nodes <- unique(d[ d$V2 == p, ]$V3)
				avg_values <- sapply(nr_nodes, function(n) mean(d[d$V2 == p & d$V3==n, ][[cn]])  )
				print(p)
				print(avg_values)
				if (idx == 0) {
					plot(y=avg_values, x=nr_nodes, type="b",ylim=yrange, col=pal[pal$p == p ,]$color, xlab="nr nodes", main=paste("Density", d[1,]$V4), ylab=m)
				} else {	
					lines(y=avg_values, x=nr_nodes, type="b", col=pal[pal$p == p ,]$color)
				}
				idx <- idx + 1
				#print(pal[pal$p==p,]$color)
				#par(new=T)
			}
			legend(x="topright", legend=pal$p, col=pal$color, lty=sapply(pal$p, function(d) 1 ))
			#par(new=F)
		}

		mtext(paste("Charts showing the average", m), outer=TRUE,  cex=1, line=-2)

	}

	# close pdf
	dev.off()

}


