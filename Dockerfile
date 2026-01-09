FROM rocker/tidyverse:latest

RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    git \
    libpoppler-cpp-dev \
    texlive-latex-base \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-extra \
    texlive-xetex \
    lmodern \
    && rm -rf /var/lib/apt/lists/*

COPY install-packages.txt /tmp/install-packages.txt

RUN R -e "pkgs <- scan('/tmp/install-packages.txt', what = character()); \
          if (length(pkgs) > 0) install.packages(pkgs, repos='https://cloud.r-project.org', dependencies = TRUE)"

RUN chown -R rstudio:rstudio /home/rstudio

EXPOSE 8787

USER rstudio