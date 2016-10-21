args <- commandArgs(trailingOnly=TRUE)

print("Argument 1 is reception and argument 2 is transmission")

print(args[1])
reception <- read.csv(file=args[1], header=TRUE, sep=",")

print(args[2])
transmission <- read.csv(file=args[2], header=TRUE, sep=",")

# consumption.receiving <- sapply( reception[,2], function(mode) if (mode==1) 0.002 else 0.01 )
# consumption.transmitting <- sapply( transmission[,2], function(mode) if (mode==1) 0.002 else 0.35 )

r.idle.time <- sapply( reception[,2], function(mode) if (mode==1) 1 else 0 )
r.recv.time <- sapply( reception[,2], function(mode) if (mode==1) 0 else 1 )

t.idle.time <- sapply( transmission[,2], function(mode) if (mode==1) 1 else 0 )
t.tx.time <- sapply( transmission[,2], function(mode) if (mode==1) 0 else 1 )

# delta.t.trans <- transmission[,1] - ( c(c(0), transmission[,1])[-length(c( c(0), transmission[,1]))] )
# delta.t.recep <- reception[,1] - ( c(c(0), reception[,1])[-length(c( c(0), reception[,1]))] )

# consumption.receiving <- c(c(0), consumption.receiving)[-length(c( c(0), consumption.receiving))]
# consumption.transmitting <- c(c(0), consumption.transmitting)[-length(c( c(0), consumption.transmitting))]


delta.t.recep <- c(reception[,1][-1], c(reception[,1][length(reception[,1])])) - reception[,1]
delta.t.trans <- c(transmission[,1][-1], c(transmission[,1][length(transmission[,1])])) - transmission[,1]


r.i <- sum(delta.t.recep * r.idle.time) 
r.r <- sum(delta.t.recep * r.recv.time) 
t.i <- sum(delta.t.trans * t.idle.time) 
t.t <- sum(delta.t.trans * t.tx.time)


c.r <- 0.002*r.i + 0.01*r.r
c.t <- 0.002*t.i  + 0.35*t.t
total <- c.r + c.t


print(paste("Time receiver idle", r.i, r.i*0.002))
print(paste("Time receiver receiving", r.r, r.r*0.01))
print(paste("Time transmitter idle", t.i, t.i*0.002))
print(paste("Time transmitter transmitting", t.t, t.t*0.35))
print(paste("Consumptions: receiving", c.r, "transmitting", c.t, "total", total))


