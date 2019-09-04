require(omnetpp)
#
build.filename <- function(path, filename, id, seP="-") {
  filename <- paste(path, filename, sep="/")
  paste(filename, id, sep=seP)
}
#
saveDataFrame <- function(df, dstPath, fileName, expeConfig){
  write.table(
    df, file = build.filename(dstPath, fileName, expeConfig),
    row.names=F
  )
}
# This method replace the column [resultkey] of a dataset with a string
# obtained from the field [module], which refers to the node identifier
getVector <- function(dataset_file, vec_name){
  dataset <- loadVectors(
    loadDataset(
      paste(dataset_file, "vec", sep= "."),
      add(select=paste("name", "(", vec_name, ")", sep=""))
    ),
    NULL
  )
  # getting node identifier from column [vectors$module]
  tmp <- toString(dataset$vectors$module)
  tmp <- strsplit(unlist(strsplit(tmp, "\\.")), "host")
  node_ids <- unlist(lapply(tmp, function(itm){ if(length(itm) == 2) {itm[2]} }))
  # map of node identifier per resultkey
  key_id_mapping <- data.frame(
    key = dataset$vectors$resultkey,
    node_id = as.numeric(node_ids)
  )

  # get column [resultkey]
  keys <- dataset$vectordata$resultkey
  # new values for column [resultkey]
  transf <- unlist(lapply(keys, function(k){
    key_id_mapping[key_id_mapping$key == k, ]$node_id
  }))
  # update column
  dataset$vectordata$resultkey <- transf
  # update headers of dataset
  data.frame(
    node_id = dataset$vectordata$resultkey,
    time = dataset$vectordata$x,
    value = dataset$vectordata$y
  )
}
#
