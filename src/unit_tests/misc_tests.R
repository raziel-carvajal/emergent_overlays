require(omnetpp)
library(argparse)

TOLERANCE <- 1e-8
SENT_RECV_PKG_TOLERANCE <- 1.5e-03

getStatistics <- function(dataset_path, scalar_name, stat="mean"){
  all_stats <- loadDataset(
    paste(dataset_path, sep= ".", "sca"),
    add(select=paste("name", "(", scalar_name, ")", sep=""))
  )

  node_ids <- toString(all_stats$statistics$module)
  node_ids <- strsplit(unlist(strsplit(node_ids, "\\.")), "host")
  node_ids <-unlist(
    lapply(node_ids, function(id_str){
      tmp <- ifelse( length(id_str) == 2, id_str[2], NA )
      tmp[!is.na(tmp)]
    })
  )

  key_id_map <- data.frame(
    key = all_stats$statistics$resultkey,
    node_id = as.numeric(node_ids)
  )

  scalar <- subset(all_stats$fields, fieldname == stat)
  data.frame(
    node_id = key_id_map$node_id,
    data = subset(scalar, resultkey == key_id_map$key)$fieldvalue
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

getEnergyConsumption <- function(dataset_loc, node_ids){

  radio_mode <- getVector(dataset_loc, "radioMode:vector")
  e_consump  <- getVector(dataset_loc, "residualCapacity:vector")

  sapply(node_ids, function(id){
    # timestamps of radio in tranceiver mode
    transciever_timestamp <- subset(
      subset(radio_mode, node_id == id),
      value == 2
    )$time
    e_consump_all_modes <- subset(e_consump, node_id == id)
    # get energy consumption of tranceiver mode per node
    e_consump_transcv_m <- sapply(transciever_timestamp, function(t){
      # energy at node when radio switch to tranceiver mode
      c0 <- subset(e_consump_all_modes, time == t)$value
      i  <- match(c0, e_consump_all_modes$value) + 1
      # energy at node when radio changed of mode (sleep, etc..)
      c1 <- e_consump_all_modes$value[i]
      c0 - c1
    })
    sum(
      e_consump_transcv_m[ !is.na(e_consump_transcv_m) ]
    ) * 1000 # convert to milli-Joules
  })

}

parser <- ArgumentParser(
  description="Unit test of methods before they are part to the framework"
)
parser$add_argument('dataset', metavar='dataset', type="character")

args <- parser$parse_args()

print(
  getStatistics(args$dataset, "packetErrorRate:histogram")
)

node_ids <- unique(
  getVector(args$dataset, "radioMode:vector")$node_id
)
#
print(
  sum(getEnergyConsumption(args$dataset, node_ids))
)
