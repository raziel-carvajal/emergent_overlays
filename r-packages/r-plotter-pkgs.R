## Create the personal library if it doesn't exist. Ignore a warning if the directory already exists.
dir.create(
  Sys.getenv("R_LIBS_USER"),
  showWarnings = FALSE,
  recursive = TRUE
)
## Install one package.
install.packages(
  "argparse",
  Sys.getenv("R_LIBS_USER"),
  repos = "http://cloud.r-project.org",
  dependencies = TRUE
)
install.packages(
  "gtable",
  Sys.getenv("R_LIBS_USER"),
  repos = "http://cloud.r-project.org",
  dependencies = TRUE
)
install.packages(
  "Rcpp",
  Sys.getenv("R_LIBS_USER"),
  repos = "http://cloud.r-project.org",
  dependencies = TRUE
)
install.packages(
  "/usr/emrg-ovrl/r-packages/plyr_1.8.1.tar.gz",
  Sys.getenv("R_LIBS_USER"),
  repos = NULL
)
install.packages(
  "/usr/emrg-ovrl/r-packages/reshape2_1.4.2.tar.gz",
  Sys.getenv("R_LIBS_USER"),
  repos = NULL
)
install.packages(
  "scales",
  Sys.getenv("R_LIBS_USER"),
  repos = "http://cloud.r-project.org",
  dependencies = TRUE
)
install.packages(
  "/usr/emrg-ovrl/r-packages/ggplot2_1.0.1.tar.gz",
  Sys.getenv("R_LIBS_USER"),
  repos = NULL
)
install.packages(
  "e1071",
  Sys.getenv("R_LIBS_USER"),
  repos = "http://cloud.r-project.org",
  dependencies = TRUE
)
