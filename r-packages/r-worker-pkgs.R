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
  repos = "http://cran.us.r-project.org",
  dependencies = TRUE
)
install.packages(
  "digest",
  Sys.getenv("R_LIBS_USER"),
  repos = "http://cran.us.r-project.org",
  dependencies = TRUE
)
install.packages(
  "gtable",
  Sys.getenv("R_LIBS_USER"),
  repos = "http://cran.us.r-project.org",
  dependencies = TRUE
)
install.packages(
  "igraph",
  Sys.getenv("R_LIBS_USER"),
  repos = "http://cran.us.r-project.org",
  dependencies = TRUE
)
install.packages(
  "/usr/emrg-ovrl/omnetpp_0.2-1.tar.gz",
  Sys.getenv("R_LIBS_USER"),
  repos = NULL
)
