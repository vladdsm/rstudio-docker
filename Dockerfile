FROM rocker/tidyverse:4.5.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    git \
    libpoppler-cpp-dev \
    texlive-latex-base \
    texlive-fonts-recommended \
    texlive-latex-extra \
    lmodern \
    && rm -rf /var/lib/apt/lists/*

COPY install-packages.txt /tmp/install-packages.txt
COPY install.R /tmp/install.R

RUN R -e "pkgs <- scan('/tmp/install-packages.txt', what = character()); \
          if (length(pkgs) > 0) install.packages(pkgs, repos='https://cloud.r-project.org', dependencies = TRUE)"

EXPOSE 8787
# NOTE: do NOT add USER rstudio — the base image handles this in /init