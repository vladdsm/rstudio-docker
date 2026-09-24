param(
    [string]$Tag = "rstudio-local:4.5.0"
)

# Switch to repo root
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)

docker build -t $Tag .