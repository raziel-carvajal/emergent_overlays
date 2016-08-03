
import.data <- function(fileName) {
  data <- readLines(fileName)
  closeAllConnections()
  start <- grep("n_", data)
  mark <- vector('integer', length(data))
  mark[start] <- 1
  # determine limits of each table
  mark <- cumsum(mark)
  split(data, mark)
  # split the data for reading
  df <- lapply(split(data, mark), function(.data) {
    .input <- read.table(textConnection(.data), header=TRUE)
    attr(.input, 'name') <- .data[1]  # save the name
    .input
  })
  # rename the list
  names(df) <- sapply(df, attr, 'name')
  df
}

get.attrSet <- function(dfNames, attri) {
  set <- unique (
    lapply(dfNames, function(name) {
      header <- unlist(strsplit(name, '\"'))
      item <- unlist(strsplit(header, '_'))
      if (attri == "p") {
        i <- tail(grep(attri, item), 1)
        if (i %% 2 == 1) { i <- i + 1 }
      } else { i <- head(grep(attri, item), 1) + 1 }
      item[i]
    })
  )
}

plot.cdfs <- function(df, dfNames, sizes, algos, plotTitle) {
  for (d in c('sparse', 'medium', 'dense')) {
    for (s in sizes) {
      pos <- grep(paste("n_", s, "_d_", d, sep=''), dfNames)
      if (length(pos) != 0) {
        keys <- unlist( lapply(pos, function(i) { dfNames[i] }) )
        for (a in algos) {
          i <- grep(a, keys)
          if (length(i) != 0){
            # TODO plot ECDF and add it to file per page
            print(keys[i]) 
          }
        }
      }
    }
  }
}

#x <- lapply(c('sparse', 'medium', 'dense'), function(d){ grep(d, dfNames) })
#names(x) <- c('sparse', 'medium', 'dense')
#df[[ dfNames[ x$dense ] ]]

args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 1) {
  df <- import.data(args[1])
  dfNames <- names(df)
  sizes <- get.attrSet(dfNames, "n")
  algos <- get.attrSet(dfNames, "p")
  plot.cdfs(df, dfNames, sizes, algos, "Broadcasting")
  
  #lapply(names(df), function(n){
  #  x <- unlist(strsplit( unlist(strsplit(n, '\"'))[2], '_' ))
  #  x
  #})
}
