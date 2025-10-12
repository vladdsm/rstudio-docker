# Stop and remove the container
docker stop rstudio-local 2>$null
docker rm rstudio-local 2>$null
Write-Host "Stopped and removed container 'rstudio-local'."
Read-Host "Press Enter to exit"