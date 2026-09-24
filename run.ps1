param(
    [string]$Tag = "rstudio-local:4.5.0",   # CHANGED: pin to match build.ps1
    [int]$Port = 8787
)

# Switch to repo root
$repoRoot = (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location -Path $repoRoot

# Load .env
$envPath = Join-Path $repoRoot ".env"
if (-Not (Test-Path $envPath)) {
    Write-Error ".env not found. Create it before running."
    exit 1
}

# Parse .env
$envContent = Get-Content $envPath | Where-Object { $_ -match "=" -and $_ -notmatch "^\s*#" }
$envVars = @{}
foreach ($line in $envContent) {
    $parts = $line -split "=", 2
    $envVars[$parts[0].Trim()] = $parts[1].Trim()
}

$workspaceHost = Join-Path $repoRoot $envVars["WORKSPACE"]
if (-Not (Test-Path $workspaceHost)) {
    New-Item -ItemType Directory -Path $workspaceHost | Out-Null
}

# CHANGED: ensure the docker network exists before trying to connect
docker network inspect ppwr-net *>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Creating docker network 'ppwr-net'..."
    docker network create ppwr-net | Out-Null
}

# CHANGED: remove any previous container with the same name so `docker run` doesn't fail
$existing = docker ps -a --filter "name=^rstudio-local$" --format "{{.Names}}"
if ($existing) {
    Write-Host "Removing existing container 'rstudio-local'..."
    docker rm -f rstudio-local | Out-Null
}

# Run container
docker run `
  --name rstudio-local `
  -d `
  -p ${Port}:8787 `
  -e USER=$($envVars["RSTUDIO_USER"]) `
  -e PASSWORD=$($envVars["RSTUDIO_PASSWORD"]) `
  -e TZ=$($envVars["TZ"]) `
  -v "${workspaceHost}:/home/rstudio/workspace" `
  -v "${env:USERPROFILE}\Documents\GitHub:/home/rstudio/github" `
  --restart unless-stopped `
  $Tag

# CHANGED: check the docker run result before connecting to the network
if ($LASTEXITCODE -ne 0) {
    Write-Error "docker run failed. Check the output above."
    exit 1
}

docker network connect ppwr-net rstudio-local

# Compose URL
$url = "http://localhost:$Port"

Write-Host "RStudio is available at $url"
Write-Host "Login with username '$($envVars["RSTUDIO_USER"])' and your password from .env"

# Wait for RStudio to respond
$maxTries = 30   # CHANGED: 30 tries * ~2s = up to 60s (RStudio Server can be slow on first boot)
$ready = $false
for ($i = 0; $i -lt $maxTries; $i++) {
    try {
        $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 2
        if ($resp.StatusCode -eq 200) { $ready = $true; break }
    } catch { Start-Sleep -Seconds 2 }
}

if ($ready) {
    Write-Host "RStudio is ready. Opening browser..."
    Start-Process $url
} else {
    Write-Warning "RStudio did not respond within $($maxTries * 2)s. Check logs with: docker logs rstudio-local"
}