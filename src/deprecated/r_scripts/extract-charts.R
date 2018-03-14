
####### BEGIN TODO check if this funtion is still useful
# collect.duplicated.messages <- function(msgDs, broDs, simulation.time) {
#   # create a separate list for each msg_sent vector
#   list_of_sent <- lapply(msgDs$vectors$resultkey, function(p) subset(msgDs$vectordata, resultkey == p))
#
#   # recover list of msg id
#   id_msgs <- msgDs$vectordata[[4]][!duplicated(msgDs$vectordata[[4]])]
#
#   # create a separate list for each broadcast_msg_received vector
#   list_of_received <- lapply(broDs$vectors$resultkey, function(p) subset(broDs$vectordata, resultkey == p))
#
#   l.recp <- lapply(id_msgs, function (id) {
# 						tmp.list <- lapply(list_of_received, function(d)  d[d$y == id,]$x )
# 						data.frame(dm = sapply(tmp.list, function(d) length(d)) )
# 			}
#   )
#
#   do.call("rbind", l.recp)
# }
# save.duplicated.messages <- function(data, outputPath, expeId){
#   dm <- data$dm[data$dm > 0] # only data from nodes that received the messages
#   df <- data.frame( whatever = dm)
#   colnames(df) <- c(expeId)
#   write.table(
#             df,
#             file = build.filename(outputPath, "duplicatedMsgsDistribution", expeId),
#             row.names = F, append = F
#   )
# }
# countmsgsperradiomode <- function(radiomodeds, msgsds, algo){
#   keys <- subset(msgsds$vectordata, !duplicated(resultkey))$resultkey
#   headers <- vector()
#   for (i in 1:length(keys)) {
#     a <- subset(radiomodeds, resultkey == keys[i])
#     tmp <- subset(msgsds$vectordata, resultkey == keys[i])
#     for (j in 1:length(tmp$resultkey)) {
#       v <- tmp[j, ]
#       t <- nrow( subset(a, x <= v$x) )
#       if (na %in% headers[t]) {
#         headers <- c(headers, t)
#       }
#     }
#   }
#   headers <- c(headers, "algorithm")
#   nrow <- length(keys)
#   ncol <- length(headers)
#   r <- as.data.frame(matrix(0, nrow=nrow, ncol=ncol))
#   names(r) <- headers
#   for (i in 1:length(keys)) {
#     a <- subset(radiomodeds, resultkey == keys[i])
#     tmp <- subset(msgsds$vectordata, resultkey == keys[i])
#     for (j in 1:length(tmp$resultkey)) {
#       v <- tmp[j, ]
#       t <- nrow( subset(a, x <= v$x) )
#       r[i, t] <- r[i, t] + 1
#     }
#   }
#   r[,"algorithm"] = algo
#   r
# }
# exportDataset <- function(ds, dst){
#   if (!file.exists(dst)) write.table(ds, file = dst, col.names = T, row.names = F, append = F, sep=",")
#   else write.table(ds, file = dst, col.names = F, row.names = F, append = T, sep=",")
# }
# compute.time.per.protocol <- function(changes.of.protocol) {
#
#   d <- changes.of.protocol$vectordata
#   df <- data.frame(node=d$resultkey, t=d$x, v=d$y)
#
#   nodes <- unique(df$node)
#
#   protocol.changes <- lapply(nodes, function(n) { df[df$node==n,] } )
#
#   max.time = max(df$t)
#
#   my.shift.left <- function (x, shift, emptyvalue=NA) c(x[(1+shift):(length(x))], rep(emptyvalue, shift))
#
#   my.shift.left <- function (x, shift, emptyvalue=NA) {
#   	if (length(x) > shift ) (c(x[(1+shift):(length(x))], rep(emptyvalue, shift)))	else (rep(emptyvalue, length(x)))
#   }
#
#   df <- lapply(protocol.changes, function (pc) {
#   	times = pc$t
#   	tmp <- my.shift.left(times, 1, max.time)
#   	data.frame(node = pc$node, t=times, v=pc$v, elapsed=(tmp - times))
#   })
#
#   times <- lapply(df, function (pc) {
#   	tmp <- unique(pc$v)
#   	node <- unique(pc$node)
#   	dd <- sapply(tmp, function(pro) sum(pc[pc$v == pro,]$elapsed))
#   	protocols <- sapply(tmp, intToUtf8)
#   	dd <- data.frame(node=rep(node, length(tmp)), protocol=protocols, elapsed.time=dd)
#     dd[dd$protocol!='E',]
#   })
#
#   tt <-do.call("rbind",lapply(times, function(pc) pc[max(pc$elapsed.time) == pc$elapsed.time,]))
#
#   print("Count of nodes executing a protocol")
#   print(lapply(unique(tt$protocol), function(t) data.frame(pro = t, count=length(tt[tt$protocol==t,]$protocol)) ))
#
#   tt
# }
# compute.median.density.per.node <- function(density.over.time) {
#   df <- density.over.time$vectordata
#   df <- data.frame(node=df$resultkey, t=df$x, v=df$y)
#   nodes <- unique(df$node)
#   # densities.total <- lapply(nodes, function(n) { df[df$node==n,] } )
#   densities <- lapply(nodes, function(n) { median(df[df$node==n,]$v) } )
#   sapply(densities, function(d) if (d>15) 'dense' else 'sparse')
# }
####### END TODO check if this funtion is still useful

main <- function(args) {

  # protocol.per.node <- NULL
  # median.density.per.node <- NULL
  # if (args$splitted) {
  #   print(paste("Loading changes of protocol over time", args$file))
  #   changes.of.protocol <- load.datafile(args$file, "name(protocol_change:vector)")
  #   protocol.per.node <- compute.time.per.protocol(changes.of.protocol)
  #   print(paste("Loading density over time", args$file))
  #   density.over.time <- load.datafile(args$file, "name(density_approximation:vector)")
  #   median.density.per.node <- compute.median.density.per.node(density.over.time)
  #   print("DONE!")
  # }


#  save.duplicated.messages(dm, args$outputPath, args$configuration)
  #######################
  # optional behavior
  # if (args$computeRadioMode) {
  #   print("Ohhh ... this is a debug session. Ok, reading radio modes")
  #   # get the intervals of time of two radio modes where:
  #   # - 2 means reception mode
  #   # - 3 means transmission mode
  #   # this script was tested with a dataset of ABBA and Floding just for reception mode
  #   #TODO: for protocols that send control messages (like CDS) this script gets an error
  #   #TODO: figure out why an error occurs when the transmission mode is analyzed
  #   radioMode <- load.datafile(args$file, "name(radioMode:vector)" )
  #   rcvM <- subset(radioMode$vectordata, y == 2)
  #   trsM <- subset(radioMode$vectordata, y == 3)
  #   r <- countMsgsPerRadioMode(rcvM, recv_msgs, args$algorithm)
  #   filename <- build.filename(args$outputPath, "RadioModeReception", args$density)
  #   exportDataset(r, filename)
  # }
}
