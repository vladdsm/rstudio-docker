param(
    [string]$Tag = "rstudio-local:latest",
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
  
# Compose URL
$url = "http://localhost:$Port"


Write-Host "RStudio is available at http://localhost:$Port"
Write-Host "Login with username '$($envVars["RSTUDIO_USER"])' and your password from .env"

# Wait for RStudio to respond
$maxTries = 20
for ($i=0; $i -lt $maxTries; $i++) {
    try {
        $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 2
        if ($resp.StatusCode -eq 200) { break }
    } catch { Start-Sleep -Seconds 2 }
}

# Open default browser
Start-Process $url

Read-Host "Press Enter to exit"