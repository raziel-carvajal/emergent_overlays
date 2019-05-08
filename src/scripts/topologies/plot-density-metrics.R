library(ggplot2)
# library(plyr)
library(argparse)
# library(e1071) library(grid) library(reshape2)

get_args <- function() {
  p <- ArgumentParser(description = "get clustering coefficient and density of vertex in a graph")
  p$add_argument("dataset", type = "character")
  p$add_argument("--with-clustering-coef", dest = "clu_c", action = "store_true")
  p$add_argument("--with-closure-coef", dest = "clo_c", action = "store_true")
  p$add_argument("--with-density", dest = "den", action = "store_true")
  p$parse_args()
}

#### main ####
args <- get_args()
cc_density_ds <- read.table(args$dataset, header = F)
names(cc_density_ds) <- c("clustering_coef", "closure_coef", "density", "expe_id")

if (args$clu_c) {
  cc <- ggplot(cc_density_ds, aes(x = clustering_coef, colour = expe_id, linetype = expe_id)) + 
    stat_ecdf(geom = "step", lwd = 1.5) + ggtitle("CDF of local clustering coeffient where nodes perform Levy walks.") + 
    labs(x = "Local clustering coefficient", y = "CDF over nodes") + scale_x_continuous(expand = c(0, 
    0), limits = c(0, 1))
  pdf("clusteringCoefficient.pdf")
  plot(cc)
}

if (args$clo_c) {
  cc <- ggplot(cc_density_ds, aes(x = closure_coef, colour = expe_id, linetype = expe_id)) + 
    stat_ecdf(geom = "step", lwd = 1.5) + ggtitle("CDF of local closure coeffient where nodes perform Levy walks.") + 
    labs(x = "Local closure coefficient", y = "CDF over nodes") + scale_x_continuous(expand = c(0, 
    0), limits = c(0, 1))
  pdf("closureCoefficient.pdf")
  plot(cc)
}

if (args$den) {
  den <- ggplot(cc_density_ds, aes(x = expe_id, y = density, colour = expe_id, 
    linetype = expe_id)) + geom_boxplot() + ggtitle("Distribution of nodes density.") + 
    labs(x = "", y = "Density")
  pdf("density.pdf")
  plot(den)
}
