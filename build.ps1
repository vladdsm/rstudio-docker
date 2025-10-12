param(
    [string]$Tag = "rstudio-local:latest"
)

# Switch to repo root
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)

docker build -t $Tag .