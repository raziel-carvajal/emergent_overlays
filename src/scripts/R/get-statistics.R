dataSet <- read.table(
	paste("../../../results/", 'coverage-HYBRID1', sep=''),
	header=T
)

meanDs <- data.frame(
	globalCoverageAtAll    =	mean(dataSet$globalCoverageAtAll, na.rm = T) ,
	gloablCoverageAtSparse =	mean(dataSet$gloablCoverageAtSparse, na.rm = T) ,
	globalCoverageAtDense  =	mean(dataSet$globalCoverageAtDense, na.rm = T),
	localCoverageAtAll     =	mean(dataSet$localCoverageAtAll, na.rm = T),
	localCoverageAtSparse  =	mean(dataSet$localCoverageAtSparse, na.rm = T),
	localCoverageAtDense   =	mean(dataSet$localCoverageAtDense, na.rm = T),
	collisionsAtAll        =	mean(dataSet$collisionsAtAll, na.rm = T),
	collisionsAtSparse     =	mean(dataSet$collisionsAtSparse, na.rm = T),
	collisionsAtDense      =	mean(dataSet$collisionsAtDense, na.rm = T)
)

print(meanDs)

# stdDs <- data.frame(
# 	globalCoverageAtAll    = sqrt(var(dataSet$globalCoverageAtAll, na.rm = T)) ,
# 	gloablCoverageAtSparse = sqrt(var(dataSet$gloablCoverageAtSparse, na.rm = T)) ,
# 	globalCoverageAtDense  = sqrt(var(dataSet$globalCoverageAtDense, na.rm = T)),
# 	localCoverageAtAll     = sqrt(var(dataSet$localCoverageAtAll, na.rm = T)),
# 	localCoverageAtSparse  = sqrt(var(dataSet$localCoverageAtSparse, na.rm = T)),
# 	localCoverageAtDense   = sqrt(var(dataSet$localCoverageAtDense, na.rm = T)),
# 	collisionsAtAll        = sqrt(var(dataSet$collisionsAtAll, na.rm = T)),
# 	collisionsAtSparse     = sqrt(var(dataSet$collisionsAtSparse, na.rm = T)),
# 	collisionsAtDense      = sqrt(var(dataSet$collisionsAtDense, na.rm = T))
# )
