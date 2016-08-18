args <- commandArgs(trailingOnly=TRUE)

print("Argument 1 is reception and argument 2 is transmission")

reception <- read.csv(file=arg[1], header=TRUE, sep=",")
transmission <- read.csv(file=arg[2], header=TRUE, sep=",")
consumption.receiving <- sapply( reception[,2], function(mode) if (mode==1) 0.002 else 0.01 )
consumption.transmitting <- sapply( transmission[,2], function(mode) if (mode==1) 0.002 else 0.35 )

delta.t.trans <- transmission[,1] - ( c(c(0), transmission[,1])[-length(c( c(0), transmission[,1]))] )
delta.t.recep <- reception[,1] - ( c(c(0), reception[,1])[-length(c( c(0), reception[,1]))] )

consumption.receiving <- c(c(0), consumption.receiving)[-length(c( c(0), consumption.receiving))]
consumption.transmitting <- c(c(0), consumption.transmitting)[-length(c( c(0), consumption.transmitting))]

sum(delta.t.recep * consumption.receiving)
sum(delta.t.trans * consumption.transmitting)

sum(delta.t.recep * consumption.receiving) + sum(delta.t.trans * consumption.transmitting)
