# Start from Rocker's tidyverse image with RStudio
FROM rocker/tidyverse:latest

# Install system dependencies you might need
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy the package list into the image
COPY install-packages.txt /tmp/install-packages.txt

# Install packages listed in install-packages.txt
RUN R -e "pkgs <- scan('/tmp/install-packages.txt', what = character()); \
          if (length(pkgs) > 0) install.packages(pkgs, repos='https://cloud.r-project.org')"

# Ensure correct ownership for the rstudio user
RUN chown -R rstudio:rstudio /home/rstudio

EXPOSE 8787