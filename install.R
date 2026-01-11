#!/usr/bin/env Rscript

# List of R packages to install
packages <- c(
  "reshape2",
  "data.table",
  "shinythemes",
  "imager",
  "jpeg",
  "plotly",
  "rgl",
  "qrcode",
  "DT",
  "openxlsx",
  "shinydashboard",
  "TTR",
  "quantmod",
  "FrF2",
  "pdftools",
  "rmarkdown",
  "kableExtra",
  "writexl",
  "shiny",
  "glue",
  "digest",
  "uuid",
  "httr",
  "jsonlite",
  "shinyjs",
  "dotenv",
  "purrr"
)

# Install CRAN packages
install.packages(packages, repos = "https://cloud.r-project.org", dependencies = TRUE)

# Force install TinyTeX (overrides any existing LaTeX)
if (requireNamespace("tinytex", quietly = TRUE)) {
  tinytex::install_tinytex(force = TRUE)
} else {
  install.packages("tinytex", repos = "https://cloud.r-project.org")
  tinytex::install_tinytex(force = TRUE)
}

